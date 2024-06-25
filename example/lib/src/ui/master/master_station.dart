import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/functions.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
              writeWithResponse: interactor.writeCharacteristicWithResponse,
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
  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}


class _MasterStation extends StatefulWidget {
  const _MasterStation({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithoutResponse,
    required this.writeWithResponse,
    required this.readCharacteristic,
    required this.subscribeToCharacteristic,
    Key? key,
  }) : super(key: key);
  final MasterInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;

  final Future<void> Function(
      QualifiedCharacteristic characteristic, List<int> value)
  writeWithoutResponse;
  final Future<void> Function(
      QualifiedCharacteristic characteristic, List<int> value)
  writeWithResponse;
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
      await widget.writeWithoutResponse(widget.characteristic, chunk);
    }
  }
  Future<void> subscribeCharacteristic() async {
    if (kDebugMode) {
    }
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
          //electric tarrif
          if(event.first == 0xA3 || event.first == 0xA5){
            setState(() {
              tarrif = [];
              updated = false;
              tarrif..insert(0, 0x10)
                ..addAll(event.sublist(1,12))..add(random.nextInt(255));
              tarrifMaster = convertToInt(event, 1, 11);
            });
          }
          if(event.first == 0xA4 || event.first == 0xA6){
            setState(() {
              balance = [];
              updated = false;
              balance..insert(0, 0x09)
              ..addAll(event.sublist(1,5))..add(random.nextInt(255));
              balanceMaster = convertToInt(event, 1, 4)/100;
            });
          }
        });
  }
  @override
  void initState() {
    widget.viewModel.connect();
    fetchData();
    // testing = [];
    // balance =[];
    // tarrif = [];
    // subscribeCharacteristic();
    // widget.readCharacteristic(widget.characteristic);
    super.initState();
  }
  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    selectedName = null;
    super.dispose();
    // timer.cancel();
  }
  // List<DropdownMenuItem<String>> _addDividersAfterItems(Set<String> items) {
  //   final List<DropdownMenuItem<String>> menuItems = [];
  //   for (final String item in items) {
  //     menuItems.addAll(
  //       [
  //         DropdownMenuItem<String>(
  //           value: item,
  //           child: Text(
  //             item,
  //             style: TextStyle(
  //               color: Colors.green.shade800,
  //               fontWeight: FontWeight.bold,
  //               fontSize: 16,
  //             ),
  //           ),
  //         ),
  //         if (item != items.last)
  //           const DropdownMenuItem<String>(
  //             enabled: false,
  //             child: SizedBox(height:2,child: Divider( height:1,thickness: 1,)),
  //           ),
  //       ],
  //     );
  //   }
  //   return menuItems;
  // }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Align(alignment:Alignment.centerLeft,child: Text(TKeys.welcome.translate(context),style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 24),)),
                        Padding(
                          padding: const EdgeInsets.only(
                            // right: 50,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Divider(
                            height: 1,
                            // thickness: 1,
                            // indent: 0,
                            // endIndent: 10,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.viewModel.disconnect();
                        Navigator.pop(context);
                      },
                      child: Text(
                        TKeys.logout.translate(context),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green.shade50),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        if(widget.viewModel.connectionStatus == DeviceConnectionState.connecting || widget.viewModel.connectionStatus == DeviceConnectionState.connected){
                          widget.viewModel.disconnect();
                        }
                        else if(widget.viewModel.connectionStatus == DeviceConnectionState.disconnecting || widget.viewModel.connectionStatus == DeviceConnectionState.disconnected){
                          widget.viewModel.connect();
                        }
                      },
                      child: Text((widget.viewModel.connectionStatus == DeviceConnectionState.connecting || widget.viewModel.connectionStatus == DeviceConnectionState.connected)?TKeys.disconnect.translate(context):TKeys.connect.translate(context)),
                    ),
                    /*Flexible(
                      flex: 2,
                      child: Column(
                        children: [
                          Align(alignment:Alignment.centerLeft,child: Text(TKeys.welcome.translate(context),style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 24),)),
                          Padding(
                            padding: EdgeInsets.only(
                              // right: 50,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Divider(
                              height: 1,
                              // thickness: 1,
                              // indent: 0,
                              // endIndent: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                    ),),
                    Flexible(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: (){
                          if(widget.viewModel.connectionStatus == DeviceConnectionState.connecting || widget.viewModel.connectionStatus == DeviceConnectionState.connected){
                            print("connected");
                            widget.viewModel.disconnect();
                          }
                          else if(widget.viewModel.connectionStatus == DeviceConnectionState.disconnecting || widget.viewModel.connectionStatus == DeviceConnectionState.disconnected){
                            print("disconnected");
                            widget.viewModel.connect();
                          }
                        },
                        child: Text((widget.viewModel.connectionStatus == DeviceConnectionState.connecting || widget.viewModel.connectionStatus == DeviceConnectionState.connected)?TKeys.disconnect.translate(context):TKeys.connect.translate(context)),
                      ),
                    ),*/
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(flex: 2,child: Text(TKeys.choose.translate(context),style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 20),)),
                    const Flexible(flex: 1,child: SizedBox(width: 1,)),
                    Flexible(
                      flex: 2,
                      child: SizedBox(
                        height: 55,
                        child: PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              selectedName = value;
                              myInstance.getSpecifiedList(value, 'none');
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            final List<PopupMenuEntry<String>> items = [];
                            for (String item in nameList) {
                              items.add(
                                PopupMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                              if (item != nameList.last) {
                                items.add(
                                  const PopupMenuDivider(),
                                );
                              }
                            }
                            return items;
                          },
                          offset: const Offset(0, 50),
                          tooltip: 'Select a device',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedName ?? TKeys.meter.translate(context),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: selectedName != null,
                  child: Expanded(
                      child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal:width*.04,vertical: 10.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("${TKeys.name.translate(context)}: ",style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),),
                                  Text('$selectedName',style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 17,
                                  ),),
                                ],
                              ),
                              const SizedBox(height:10),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${TKeys.tarrif.translate(context)}: ',
                                        style: TextStyle(
                                          color: Colors.green.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                      ),
                                      Text(
                                        tarrifMaster.toString(),
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${TKeys.balanceStation.translate(context)}: ',
                                        style: TextStyle(
                                          color: Colors.green.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                      ),
                                      Text(
                                        balanceMaster.toString(),
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height:10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: ()async {
                                      if(!widget.viewModel.deviceConnected){
                                        widget.viewModel.connect();
                                      }
                                      else{
                                        await writeCharacteristicWithoutResponse();
                                        Timer(const Duration(seconds: 2), () async{
                                          await widget.writeWithoutResponse(widget.characteristic,[0xAA]);
                                          await subscribeCharacteristic();
                                          await widget.readCharacteristic(widget.characteristic);
                                        });
                                        await Fluttertoast.showToast(
                                          msg: 'Data Sent Successfully',
                                        );
                                      }
                                    },
                                    child: Text(TKeys.get.translate(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16,),),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: const StadiumBorder(),
                                      backgroundColor: Colors.grey.shade600,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey.shade600,
                                    ),
                                    onPressed: !updated?() async {
                                          final myInstance = SqlDb();
                                          if (balance.isNotEmpty && tarrif.isEmpty){
                                            await myInstance.saveList( balance,'$selectedName', '$listType' ,'balance');
                                            await myInstance.updateData('''
                                            UPDATE Meters
                                            SET balance = 1
                                            WHERE name = '$selectedName'
                                            ''');
                                            setState(() {
                                              updated = true;
                                            });
                                          }
                                          else if(tarrif.isNotEmpty && balance.isEmpty){
                                            await myInstance.saveList( tarrif,'$selectedName', '$listType' ,'tarrif');
                                            await myInstance.updateData('''
                                            UPDATE Meters
                                            SET tarrif = 1
                                            WHERE name = '$selectedName'
                                            ''');
                                            setState(() {
                                              updated = true;
                                            });
                                          }
                                          else {
                                            await myInstance.saveList( balance, '$selectedName', '$listType' ,'balance');
                                            await myInstance.saveList( tarrif, '$selectedName', '$listType' ,'tarrif');
                                            await myInstance.updateData('''
                                            UPDATE Meters
                                            SET 
                                            balance = 1,
                                            tarrif = 1
                                            WHERE name = '$selectedName'
                                            ''');
                                            setState(() {
                                              updated = true;
                                            });
                                          }
                                    }:null,
                                    child: Text(updated?TKeys.updated.translate(context):TKeys.update.translate(context), style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16,),),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await widget.writeWithoutResponse(widget.characteristic,[0xAA]);
                                  await subscribeCharacteristic();
                                  await widget.readCharacteristic(widget.characteristic);
                                },
                                child: Text(TKeys.request.translate(context), style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 16),),
                              ),
                            ],
                          ),
                        ),
                      ],

                    ),
                  ),
                ),
                // ElevatedButton(onPressed: (){
                //   subscribeCharacteristic();
                //   widget.writeWithResponse(widget.characteristic,[0x59]);
                //   // widget.readCharacteristic(widget.characteristic);
                // }, child:const Text('testing') )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
