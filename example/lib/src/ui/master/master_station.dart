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
///TODO: Remove
num electricTarrif = 0;
num electricBalance = 0;
num waterTarrif = 0;
num waterBalance = 0;
///TODO: Remove

class MasterInteractionTab extends StatelessWidget {
  const MasterInteractionTab({
    required this.device,
    required this.characteristic,
    super.key,
  });
  final DiscoveredDevice device;
  final QualifiedCharacteristic characteristic;

  @override
  Widget build(BuildContext context) => Consumer4<BleDeviceConnector,
          ConnectionStateUpdate, BleDeviceInteractor, BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
                interactor, __) =>
            _MasterStation(
          viewModel: MasterInteractionViewModel(
              deviceId: device.id,
              connectableStatus: device.connectable,
              connectionStatus: connectionStateUpdate.connectionState,
              deviceConnector: deviceConnector,
              discoverServices: () =>
                  serviceDiscoverer.discoverServices(device.id)),
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
  final Future<List<Service>> Function() discoverServices;

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
  });
  final MasterInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;

  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;

  @override
  State<_MasterStation> createState() => _MasterStationState();
}

class _MasterStationState extends State<_MasterStation> {
  @override
  Widget build(BuildContext context) {
    final nameLabelStyle = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 17,
    );

    final nameValueStyle = TextStyle(
      color: Colors.green.shade900,
      fontWeight: FontWeight.bold,
      fontSize: 19,
    );
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              if (!widget.viewModel.deviceConnected) {
                widget.viewModel.connect();
              } else if (widget.viewModel.deviceConnected) {
                subscribeCharacteristic();
                // widget.readCharacteristic(widget.characteristic);
              }
            });
          }),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .07),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TKeys.welcome.translate(context),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4CAF50),
                      ),
                      onPressed: () {
                        if (widget.viewModel.connectionStatus ==
                                DeviceConnectionState.connecting ||
                            widget.viewModel.connectionStatus ==
                                DeviceConnectionState.connected) {
                          widget.viewModel.disconnect();
                          start = 0;
                          timer.cancel();
                        } else if (widget.viewModel.connectionStatus ==
                                DeviceConnectionState.disconnecting ||
                            widget.viewModel.connectionStatus ==
                                DeviceConnectionState.disconnected) {
                          timer = Timer.periodic(interval, (timer) {
                            if (start == 15 ||
                                widget.viewModel.connectionStatus ==
                                    DeviceConnectionState.connected) {
                              if (widget.viewModel.connectionStatus !=
                                  DeviceConnectionState.connected) {
                                widget.viewModel.disconnect();
                                showToast('Time out', Colors.red, Colors.white);
                              }
                              timer.cancel();
                              start = 0;
                            } else {
                              widget.viewModel.connect();
                              // setState(() {
                                start++;
                              // });
                              print('start$start');
                            }
                          });
                        }
                      },
                      child: Text(
                        (widget.viewModel.connectionStatus ==
                                DeviceConnectionState.connected)
                            ? TKeys.disconnect.translate(context)
                            : (widget.viewModel.connectionStatus ==
                                    DeviceConnectionState.connecting)
                                ? 'connecting'
                                : (widget.viewModel.connectionStatus ==
                                        DeviceConnectionState.disconnected)
                                    ? TKeys.connect.translate(context)
                                    : 'disconnecting',
                        // style: const TextStyle(
                        //     color: Colors.black,
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 18,),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 2,
                        child: Text(
                          TKeys.choose.translate(context),
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )),
                    const Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: 1,
                        )),
                    Flexible(
                      flex: 2,
                      child: SizedBox(
                        height: 55,
                        child: PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              selectedName = value;
                              sqlDb.getSpecifiedList(value, 'none');
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            final items = <PopupMenuEntry<String>>[];
                            for (final item in nameList) {
                              items.add(
                                PopupMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
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
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedName ??
                                        TKeys.meter.translate(context),
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
                const SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: selectedName != null,
                  child: Container(
                    width: width * .86,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(
                        40.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            text: 'Upload Your Meter Readings\n',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Color(0xff4CAF50),
                            ),
                            // children: <TextSpan>[
                            //   TextSpan(
                            //     text:
                            //         'before ${now.day}/${now.month}/${now.year}',
                            //     style: const TextStyle(
                            //         fontSize: 20,
                            //         fontWeight: FontWeight.bold,
                            //         color: Colors.black),
                            //   ),
                            // ],
                          ),
                        ),
                        SizedBox(
                          width: width * .4,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff4CAF50),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              if (!widget.viewModel.deviceConnected) {
                                print('printing connecting');
                                widget.viewModel.connect();
                              } else {
                                print('printing');
                                await writeCharacteristicWithoutResponse();
                                Timer(const Duration(seconds: 2), () async {
                                  await widget.writeWithoutResponse(
                                      widget.characteristic, [0xAA]);
                                  await subscribeCharacteristic();
                                  // await widget.readCharacteristic(
                                  //     widget.characteristic);
                                });
                                setState(() {
                                  charging = true;
                                });
                                await Fluttertoast.showToast(
                                  msg: 'Data Sent Successfully',
                                );
                              }
                            },
                            child: Text(
                              TKeys.submit.translate(context),
                              // style: const TextStyle(
                              //   color: Color(0xff4CAF50),
                              //   fontWeight: FontWeight.bold,
                              //   fontSize: 18,
                              // ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Visibility(
                  visible: charging,
                  child: Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Meter Data:', style: Theme.of(context).textTheme.displayMedium,),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Client ID:',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    '$clientID',
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Readings: ',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    totalReadingsPulses.toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${TKeys.balance.translate(context)}: ',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    '$currentBalance',
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${TKeys.currentTarrif.translate(context)}: ',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    '$currentTarrif',
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tarrif Version: ',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    currentTarrifVersion.toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              Text('Charging Data:', style: Theme.of(context).textTheme.displayMedium,),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${TKeys.balanceStation.translate(context)}: ',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    balanceMaster.toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tarrif Value: ',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    tarrifMaster.toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tarrif Version: ',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    tarrifVersionMaster.toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                (updatingMaster && !updated)?MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: (updatingMaster && !updated)?width * .4:width * .6,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xff4CAF50),
                                      ),
                                      onPressed: () async {
                                        await widget.writeWithoutResponse(
                                            widget.characteristic, [0xAA]);
                                        await subscribeCharacteristic();
                                        setState(() {
                                          updatingMaster = true;
                                        });
                                        // await widget.readCharacteristic(
                                        //     widget.characteristic);
                                      },
                                      child: Text(
                                        TKeys.charge.translate(context),
                                        // style: const TextStyle(
                                        //     color: Colors.black,
                                        //     fontWeight: FontWeight.bold,
                                        //     fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: updatingMaster && !updated,
                                    child: SizedBox(
                                    width: width * .4,
                                    child: ElevatedButton(
                                      // style: ElevatedButton.styleFrom(
                                      //   backgroundColor:
                                      //       const Color(0xff4CAF50),
                                      //   disabledBackgroundColor:
                                      //       Colors.black,
                                      // ),
                                      onPressed: !updated?() async {
                                              final myInstance = SqlDb();
                                              if (balance.isNotEmpty &&
                                                  tarrif.isEmpty) {
                                                await myInstance.saveList(
                                                    balance,
                                                    '$selectedName',
                                                    '$listType',
                                                    'balance');
                                                await myInstance.updateData('''
                                              UPDATE Meters
                                              SET balance = 1
                                              WHERE name = '$selectedName'
                                              ''');
                                                setState(() {
                                                  updated = true;
                                                });
                                              } else if (tarrif.isNotEmpty &&
                                                  balance.isEmpty) {
                                                await myInstance.saveList(
                                                    tarrif,
                                                    '$selectedName',
                                                    '$listType',
                                                    'tarrif');
                                                await myInstance.updateData('''
                                              UPDATE Meters
                                              SET tarrif = 1
                                              WHERE name = '$selectedName'
                                              ''');
                                                setState(() {
                                                  updated = true;
                                                });
                                              } else {
                                                await myInstance.saveList(
                                                    balance,
                                                    '$selectedName',
                                                    '$listType',
                                                    'balance');
                                                await myInstance.saveList(
                                                    tarrif,
                                                    '$selectedName',
                                                    '$listType',
                                                    'tarrif');
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
                                      child: Text(
                                        TKeys.update.translate(context),
                                        style: const TextStyle(
                                          // color: updated
                                          //     ? const Color(0xff4CAF50)
                                          //     : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> writeCharacteristicWithoutResponse() async {
    const chunkSize = 20;
    for (var i = 0; i < myList.length; i += chunkSize) {
      var end = i + chunkSize;
      if (end > myList.length) {
        end = myList.length;
      }
      final chunk = myList.sublist(i, end);
      await widget.writeWithoutResponse(widget.characteristic, chunk);
    }
  }

  Future<void> subscribeCharacteristic() async {
    if (kDebugMode) {}
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
      if (event.first == 0xA3 || event.first == 0xA5) {
        setState(() {
          tarrif = [];
          // updated = false;
          tarrif
            ..insert(0, 0x10)
            ..addAll(event.sublist(1, 12))
            ..add(random.nextInt(255));
          print('tarrif master : $tarrif');
          tarrifMaster = convertToInt(event, 1, 11);
          tarrifVersionMaster = convertToInt(event, 1, 2);
        });
      }
      if (event.first == 0xA4 || event.first == 0xA6) {
        print('balanceMaster $event');
        setState(() {
          balance = [];
          updated = false;
          balance
            ..insert(0, 0x09)
            ..addAll(event.sublist(1, 5))
            ..add(random.nextInt(255));
          print('objectMaster $balance');
          balanceMaster = convertToInt(event, 1, 4) / 100;
        });
      }
    });
  }

  @override
  void initState() {
    timer = Timer.periodic(interval, (timer) {
      if (start == 15 ||
          widget.viewModel.connectionStatus ==
              DeviceConnectionState.connected) {
        if (widget.viewModel.connectionStatus !=
            DeviceConnectionState.connected) {
          widget.viewModel.disconnect();
          showToast('Time out', Colors.red, Colors.white);
        }
        timer.cancel();
        start = 0;
      } else {
        print('start$start');
        print('start${widget.viewModel.connectionStatus}');
        if (widget.viewModel.connectionStatus ==
                DeviceConnectionState.disconnected &&
            start == 0) {
          widget.viewModel.connect();
        }
        start++;
      }
    });
    widget.viewModel.connect();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    timer.cancel();
    start = 0;
    selectedName = null;
    charging = false;
    clientID = 0;
    currentTarrif = 0;
    currentBalance = 0;
    tarrifMaster = 0;
    balanceMaster = 0;
    tarrif = [];
    super.dispose();
  }
}
