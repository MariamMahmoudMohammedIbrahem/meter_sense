import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/functions.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

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
          // testing = event;
          if(event.first == 0xA3){
            electricTarrif = convertToInt(event, 0, 1);
            print("electric tarrif:$electricTarrif");
          }
          if(event.first == 0xA4){
            electricBalance = convertToInt(event, 0, 1);
            // testing = addBytesAndHex(myList.sublist(11,15), event.sublist(1,5));
            // if(!enter){
            //   enter = true;
              testing = addBytesAndHex(myList.sublist(11,15), event.sublist(1,5));
            // }
            updateMyList(event.sublist(1,5), 11, 4);
            print("electric balance:$event");
          }
          if(event.first == 0xA5){
            waterTarrif = convertToInt(event, 0, 1);
            print("water tarrif:$waterTarrif");
          }
          if(event.first == 0xA6){
            waterBalance = convertToInt(event, 0, 1);
            print("water balance:$waterBalance");
          }
        });
  }
  void initState() {
    widget.viewModel.connect();
    subscribeCharacteristic();
    widget.readCharacteristic(widget.characteristic);
    final myInstance = SqlDb();
    myInstance.getList(1);
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
                Text("list name: $listName"),
                Text("listClientId: $listClientId"),
                ElevatedButton(
                    onPressed: ()async {
                      if(!widget.viewModel.deviceConnected){
                        widget.viewModel.connect();
                      }
                      else{
                        await writeCharacteristicWithoutResponse();
                        print("byteData:$myList");
                      }
                    },
                    child: const Text("get data", style: TextStyle(color: Colors.black),),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal:width*.07,vertical: 10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width:width*.07),
                          const Text(
                            'ele Tarrif: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            electricTarrif.toString(),
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
                          const Text(
                            'ele Balance: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            electricBalance.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width:width*.07),
                          const Text(
                            'water Tarrif: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            waterTarrif.toString(),
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
                          const Text(
                            'water Balance: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            waterBalance.toString(),
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
                  onPressed: ()async {
                    final myInstance = SqlDb();
                    await myInstance.saveList(2, myList, int.parse('$listClientId'),'$listName', '$listType');
                  },
                  child: const Text("update", style: TextStyle(color: Colors.black),),
                ),
                ElevatedButton(
                  onPressed: ()async {
                    // await widget.subscribeToCharacteristic(widget.characteristic);
                    await widget.writeWithoutResponse(widget.characteristic,[0xAA]);
                  },
                  child: const Text("update", style: TextStyle(color: Colors.black),),
                ),
                // ElevatedButton(
                //   onPressed: ()async {
                //     // await readEle();
                //     // final myInstance = SqlDb();
                //     // await myInstance.saveList(myList, int.parse('$listClientId'), '$listName', '$listType');
                //   },
                //   child: const Text("update", style: TextStyle(color: Colors.black),),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
