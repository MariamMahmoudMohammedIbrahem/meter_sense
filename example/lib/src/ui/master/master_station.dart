import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import '../../ble/ble_device_connector.dart';
import '../../ble/ble_device_interactor.dart';
import '../../ble/constants.dart';
import '../device_detail/device_interaction_tab.dart';

List<int> dataList = [89, 0, 0, 0, 153, 0, 0, 0, 0, 0, 0, 0, 0, 67, 148, 0, 0, 0, 1, 0];

Uint8List byteData = Uint8List.fromList(dataList);

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
              writeWithResponse: interactor.writeCharacteristicWithResponse,
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
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.readCharacteristic,
    required this.subscribeToCharacteristic,
    Key? key,
  }) : super(key: key);
  final MasterInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;
  final Future<void> Function(
      QualifiedCharacteristic characteristic, List<int> value)
  writeWithResponse;
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
  @override
  StreamSubscription<List<int>>? subscribeStream;
  void initState() {
    // if(!widget.viewModel.deviceConnected){
    //   widget.viewModel.connect();
    // }
    final myInstance = SqlDb();
    myInstance.getList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Future<void> subscribeCharacteristic() async {
      // var newEventData =<int>[];
      if (kDebugMode) {
        print("subscribe in");
      }
      subscribeStream =
          widget.subscribeToCharacteristic(widget.characteristic).listen((event) {

              testing = event;
              print("testing$testing");
          });
    }
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(
              "Connection: ${widget.viewModel.connectionStatus}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
              onPressed: ()async {
                try {
                  await widget.writeWithoutResponse(widget.characteristic, myList);
                  print("byteData:$myList");
                  // Data has been sent successfully.
                } catch (e) {
                  // Handle any errors that might occur during the write operation.
                  print("Error sending data: $e");
                }
                if (kDebugMode) {
                  print("Error doesn't exist");
                }
              },
              child: const Text("get data", style: TextStyle(color: Colors.black),),
          ),
          ElevatedButton(
            onPressed: ()async {
              if(!widget.viewModel.deviceConnected){
                widget.viewModel.connect();
              }
              else{
                await subscribeCharacteristic();
                await widget.readCharacteristic(widget.characteristic);
              }
              print("responseread:$testing");
            },
            child: const Text("button 2", style: TextStyle(color: Colors.black),),
          ),
          ElevatedButton(
            onPressed: ()async {},
            child: const Text("button 3", style: TextStyle(color: Colors.black),),
          ),
          SizedBox(
            height: height*.5,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: count,
                    itemBuilder: (BuildContext context, int index) {
                      // Check if the item is a padding item (empty string)
                      if (count == 0) {
                        return const SizedBox(
                          child: Text("There is no data"),
                        );
                      }
                      else{
                        return const SizedBox(
                          child: Text("There is data"),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
