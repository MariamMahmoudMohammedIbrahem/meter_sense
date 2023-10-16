import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/functions.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import '../../../t_key.dart';
import '../../ble/ble_device_connector.dart';
import '../../ble/ble_device_interactor.dart';
import '../../ble/constants.dart';
import '../device_detail/device_interaction_tab.dart';

num electricTarrif = 0;
num electricBalance = 0;
num waterTarrif = 0;
num waterBalance = 0;

class MasterInteractionTab extends StatelessWidget {
  const MasterInteractionTab({
    required this.device,
    required this.characteristic,
    Key? key,
  }) : super(key: key);
  final DiscoveredDevice device;
  final QualifiedCharacteristic characteristic;

  @override
  Widget build(BuildContext context) =>
      Consumer4<BleDeviceConnector, ConnectionStateUpdate, BleDeviceInteractor,BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,interactor,
            __) =>
            _MasterStation(
              viewModel: MasterInteractionViewModel(
                  deviceId: device.id,
                  connectableStatus: device.connectable,
                  connectionStatus: connectionStateUpdate.connectionState,
                  deviceConnector: deviceConnector,
                  discoverServices: () => serviceDiscoverer.discoverServices(device.id)),
              characteristic: characteristic,
              writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
              readCharacteristic: interactor.readCharacteristic,
              subscribeToCharacteristic: interactor.subScribeToCharacteristic,
            ),
      );

}

@FunctionalData()
class MasterInteractionViewModel extends $DeviceInteractionViewModel {
  const MasterInteractionViewModel({
    required this.deviceId,
    required this.connectableStatus,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
  });

  @override
  final String deviceId;
  @override
  final Connectable connectableStatus;
  @override
  final DeviceConnectionState connectionStatus;
  @override
  final BleDeviceConnector deviceConnector;
  @override
  @CustomEquality(Ignore())
  final Future<List<DiscoveredService>> Function() discoverServices;

  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

}


class _MasterStation extends StatefulWidget {
  const _MasterStation({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithoutResponse,
    required this.readCharacteristic,
    required this.subscribeToCharacteristic,
    Key? key,
  }) : super(key: key);
  final MasterInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;

  final Future<void> Function(
      QualifiedCharacteristic characteristic, List<int> value)
  writeWithoutResponse;
  final Future<List<int>> Function(
      QualifiedCharacteristic characteristic)
  readCharacteristic;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
  subscribeToCharacteristic;

  @override
  State<_MasterStation> createState() => _MasterStationState();
}

class _MasterStationState extends State<_MasterStation> {
  StreamSubscription<List<int>>? subscribeStream;
  Future<void> writeCharacteristicWithoutResponse() async {
    int chunkSize = 20;
    for (int i = 0; i < myList.length; i += chunkSize) {
      int end = i + chunkSize;
      if (end > myList.length) {
        end = myList.length;
      }
      List<int> chunk = myList.sublist(i, end);
      print("Sending chunk: $chunk");
      await widget.writeWithoutResponse(widget.characteristic, chunk);
    }
  }
  Future<void> subscribeCharacteristic() async {
    if (kDebugMode) {
      print("subscribe in");
    }
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
          //electric tarrif
          testing = event;
          if(event.first == 0xA3 || event.first == 0xA5){
            setState(() {
              tarrif = event.sublist(1,12);
              cond0 = true;
              print(tarrif);
            });
          }
          if(event.first == 0xA4 || event.first == 0xA6){
            setState(() {
              balance = event.sublist(1,5);
              cond = true;
              print(balance);
            });
          }
        });
  }

  void initState() {
    widget.viewModel.connect();
    // testing = [];
    // subscribeCharacteristic();
    // widget.readCharacteristic(widget.characteristic);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: ()=> Future.delayed(
            const Duration(seconds: 1),(){
          setState(() {
            if(!widget.viewModel.deviceConnected){
              widget.viewModel.connect();
            }
            else if(widget.viewModel.deviceConnected){
              subscribeCharacteristic();
              widget.readCharacteristic(widget.characteristic);
            }
          });
        }),
        child: Column(
          children: [
            SizedBox(height:width*.25),
            Center(
              child: DropdownButton<String>(
                hint: Text(
                  TKeys.choose.translate(context),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                value: selectedName,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedName = newValue!;
                    final myInstance = SqlDb();
                    myInstance.getList(selectedName,'none');
                  });
                },
                items: name.map((name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  )).toList(),
              ),

            ),
            Visibility(
              visible: selectedName != null,
              child: Expanded(
                  child: ListView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 16.0),
                          child: Text(
                            "Connection: ${widget.viewModel.connectionStatus}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text("${TKeys.name.translate(context)}: $selectedName"),
                        Text("${TKeys.id.translate(context)}: $listClientId"),
                        ElevatedButton(
                            onPressed: ()async {
                              if(!widget.viewModel.deviceConnected){
                                widget.viewModel.connect();
                              }
                              else{
                                await writeCharacteristicWithoutResponse();
                                if(testing.isEmpty){
                                  Timer(const Duration(seconds: 2), () async{
                                    await widget.writeWithoutResponse(widget.characteristic,[0xAA]);
                                    await subscribeCharacteristic();
                                    await widget.readCharacteristic(widget.characteristic);
                                  });
                                }
                              }
                            },
                            child: Text(TKeys.get.translate(context), style: const TextStyle(color: Colors.black),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal:width*.07,vertical: 10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width:width*.07),
                                  Text(
                                    '${TKeys.tarrif.translate(context)}: ',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    tarrif.toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(width:width*.07),
                                  Text(
                                    '${TKeys.balanceStation.translate(context)}: ',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    balance.toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                                final myInstance = SqlDb();
                                if (balance.isNotEmpty && tarrif.isEmpty){
                                  await myInstance.saveList( balance, int.parse('$listClientId'),'$listName', '$listType' ,'balance');
                                }
                                else if(tarrif.isNotEmpty && balance.isEmpty){
                                  await myInstance.saveList( tarrif, int.parse('$listClientId'),'$listName', '$listType' ,'tarrif');
                                }
                                else {
                                  await myInstance.saveList( balance, int.parse('$listClientId'),'$listName', '$listType' ,'balance');
                                  await myInstance.saveList( tarrif, int.parse('$listClientId'),'$listName', '$listType' ,'tarrif');
                                }
                          },
                          child: Text(TKeys.update.translate(context), style: const TextStyle(color: Colors.black),),
                        ),
                      ],
                    ),
                  ],

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
