import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ble/functions.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/electric_data.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/water_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import '../../../t_key.dart';

part 'device_interaction_tab.g.dart';
//ignore_for_file: annotate_overrides

class DeviceInteractionTab extends StatelessWidget {
  const DeviceInteractionTab({
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
            _DeviceInteractionTab(
          viewModel: DeviceInteractionViewModel(
              deviceId: device.id,
              connectableStatus: device.connectable,
              connectionStatus: connectionStateUpdate.connectionState,
              deviceConnector: deviceConnector,
              discoverServices: () =>
                  serviceDiscoverer.discoverServices(device.id)),
          characteristic: characteristic,
          writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
          subscribeToCharacteristic: interactor.subScribeToCharacteristic,
          name: device.name,
        ),
      );
}

// @immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.connectableStatus,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
  });

  final String deviceId;
  final Connectable connectableStatus;
  final DeviceConnectionState connectionStatus;
  final BleDeviceConnector deviceConnector;
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

class _DeviceInteractionTab extends StatefulWidget {
  const _DeviceInteractionTab({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
    required this.name,
  });
  final DeviceInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;
  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;
  final String name;
  @override
  _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
}

class _DeviceInteractionTabState extends State<_DeviceInteractionTab>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        child: ListView(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: height * .95,
              width: width,
              child: Column(children: [
                Flexible(
                  child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * .07),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              TKeys.welcome.translate(context),
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (widget.viewModel.connectionStatus ==
                                        DeviceConnectionState.connecting ||
                                    widget.viewModel.connectionStatus ==
                                        DeviceConnectionState.connected) {
                                  widget.viewModel.disconnect();
                                } else if (widget.viewModel.connectionStatus ==
                                        DeviceConnectionState.disconnecting ||
                                    widget.viewModel.connectionStatus ==
                                        DeviceConnectionState.disconnected) {
                                  widget.viewModel.connect();
                                }
                              },
                              child: Text((widget.viewModel.connectionStatus ==
                                      DeviceConnectionState.connected)
                                  ? TKeys.disconnect.translate(context)
                                  : (widget.viewModel.connectionStatus ==
                                          DeviceConnectionState.connecting)
                                      ? 'connecting'
                                      : (widget.viewModel.connectionStatus ==
                                              DeviceConnectionState
                                                  .disconnected)
                                          ? TKeys.connect.translate(context)
                                          : 'disconnecting'),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: isLoading,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: width*.5-20),
                          child: const CircularProgressIndicator(
                            color: Color(0xff4CAF50),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * .07, vertical: 10.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                  color: widget.viewModel.deviceConnected
                                      ? const Color(0xff4CAF50)
                                      : Colors.red.shade900),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {
                            sqlDb.editingList(widget.name).then((value) {
                              if (paddingType == "Electricity") {
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (context) => StoreData(
                                      name: widget.name,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (context) => WaterData(
                                      name: widget.name,
                                    ),
                                  ),
                                );
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${TKeys.name.translate(context)}: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      widget.name,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(width: width * .07),
                                    Text(
                                      '${TKeys.currentTarrif.translate(context)}: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      paddingType == 'Electricity'
                                          ? eleMeter[4].toString()
                                          : watMeter[4].toString(),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(
                                      width: 1,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          TKeys.today.translate(context),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 25,
                                              child: Image.asset(
                                                paddingType == 'Electricity'
                                                    ? 'icons/electricityToday.png'
                                                    : 'icons/waterToday.png',
                                              ),
                                            ),
                                            Text(
                                              paddingType == 'Electricity'
                                                  ? eleMeter[1].toString()
                                                  : watMeter[1].toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 30),
                                    Column(
                                      children: [
                                        Text(
                                          TKeys.month.translate(context),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 25,
                                              child: Image.asset(paddingType ==
                                                      'Electricity'
                                                  ? 'icons/electricityMonth.png'
                                                  : 'icons/waterMonth.png'),
                                            ),
                                            Text(
                                              paddingType == 'Electricity'
                                                  ? eleMeter[8].toString()
                                                  : watMeter[8].toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 1,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: width * .07),
                                    Text(
                                      '${TKeys.balance.translate(context)}: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      paddingType == 'Electricity'
                                          ? eleMeter[3].toString()
                                          : watMeter[3].toString(),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Visibility(
                                  visible: balanceCond || tarrifCond,
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: (balanceCond || tarrifCond)
                                            ? () async {
                                          if (widget.viewModel
                                              .connectionStatus !=
                                              DeviceConnectionState
                                                  .connected) {
                                            widget.viewModel.connect();
                                          } else if (widget
                                              .viewModel.deviceConnected) {
                                            await startTimer();
                                          }
                                        }
                                            : null,
                                        child: Text(TKeys.recharge.translate(context),),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: nameList.length != 1 && nameList.isNotEmpty,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AutoSizeText(
                                  TKeys.notConnected.translate(context),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxFontSize: 20,
                                  minFontSize: 18,
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: width * .07,
                                right: width * .07,
                                top: 10,
                              ),
                              child: Divider(
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: nameList.length != 1 && nameList.isNotEmpty,
                        child: FutureBuilder(
                            future: sqlDb.readData('SELECT * FROM Meters'),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Map>> snapshot) {
                              if (snapshot.hasData) {
                                final filteredItems = snapshot.data!
                                    .where(
                                        (item) => item['name'] != widget.name)
                                    .toList();
                                return ListView.builder(
                                    itemCount: filteredItems.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, i) {
                                      sqlDb
                                        ..readMeterData(
                                          '${filteredItems[i]['name']}',
                                        )
                                        ..editingList(
                                          '${filteredItems[i]['name']}',
                                        );
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width * .07,
                                            vertical: 10.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              side: BorderSide(
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                            backgroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            if ('${filteredItems[i]['name']}'
                                                .startsWith('Ele')) {
                                              Navigator.of(context).push<void>(
                                                MaterialPageRoute<void>(
                                                  builder: (context) =>
                                                      StoreData(
                                                    name:
                                                        '${filteredItems[i]['name']}',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              Navigator.of(context).push<void>(
                                                MaterialPageRoute<void>(
                                                  builder: (context) =>
                                                      WaterData(
                                                    name: filteredItems[i]
                                                            ['name']
                                                        .toString(),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${TKeys.name.translate(context)}: ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium,
                                                    ),
                                                    Text(
                                                      '${filteredItems[i]['name']}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                        width: width * .07),
                                                    Text(
                                                      '${TKeys.currentTarrif.translate(context)}: ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium,
                                                    ),
                                                    Text(
                                                      ('${filteredItems[i]['name']}'
                                                              .startsWith(
                                                                  'Ele'))
                                                          ? ('${eleMeters['${filteredItems[i]['name']}']?[0]}')
                                                          : ('${watMeters['${filteredItems[i]['name']}']?[0]}'),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const SizedBox(
                                                      width: 1,
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          TKeys.today.translate(
                                                              context),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium,
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 25,
                                                              child:
                                                                  Image.asset(
                                                                ('${filteredItems[i]['name']}'
                                                                        .startsWith(
                                                                            'Ele'))
                                                                    ? 'icons/electricityToday.png'
                                                                    : 'icons/waterToday.png',
                                                              ),
                                                            ),
                                                            Text(
                                                              ('${filteredItems[i]['name']}'
                                                                      .startsWith(
                                                                          'Ele'))
                                                                  ? ('${eleMeters['${filteredItems[i]['name']}']?[3]}')
                                                                  : ('${watMeters['${filteredItems[i]['name']}']?[3]}'),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 30),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          TKeys.month.translate(
                                                              context),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium,
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 25,
                                                              child: Image.asset('${filteredItems[i]['name']}'
                                                                      .startsWith(
                                                                          'Ele')
                                                                  ? 'icons/electricityMonth.png'
                                                                  : 'icons/waterMonth.png'),
                                                            ),
                                                            Text(
                                                              ('${filteredItems[i]['name']}'
                                                                      .startsWith(
                                                                          'Ele'))
                                                                  ? ('${eleMeters['${filteredItems[i]['name']}']?[1]}')
                                                                  : ('${watMeters['${filteredItems[i]['name']}']?[1]}'),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      width: 1,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                        width: width * .07),
                                                    Text(
                                                      '${TKeys.balance.translate(context)}: ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium,
                                                    ),
                                                    Text(
                                                      ('${filteredItems[i]['name']}'
                                                              .startsWith(
                                                                  'Ele'))
                                                          ? ('${eleMeters['${filteredItems[i]['name']}']?[2]}')
                                                          : ('${watMeters['${filteredItems[i]['name']}']?[2]}'),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
        onRefresh: () => Future.delayed(const Duration(seconds: 1), () {
          subscribeOutput = [];
          setState(() {
            timer = Timer.periodic(interval, (timer) {
              if (start == 15) {
                showToast('Time out', Colors.red, Colors.white);
                timer.cancel();
                setState(() {
                  start = 0;
                  isLoading = false;
                });
              } else {
                setState(() {
                  start++;
                });
                if (!widget.viewModel.deviceConnected) {
                  widget.viewModel.connect();
                } else if (subscribeOutput.length != 72) {
                  isLoading = true;
                  subscribeCharacteristic();
                  widget.writeWithoutResponse(widget.characteristic, [0x59]);
                } else if (subscribeOutput.length == 72) {
                  setState(() {
                    if (paddingType == "Electricity") {
                      isFunctionCalled = false;
                      calculateElectric(subscribeOutput, widget.name);
                    } else {
                      calculateWater(subscribeOutput, widget.name);
                    }
                    isLoading = false;
                  });
                  showToast(
                      'All Data Are UpToDate',
                      const Color(0xFF2196F3),
                      Colors.black);
                  timer.cancel();
                }
              }
            });
          });
        }),
      ),
    );
  }
  @override
  void initState() {
    subscribeOutput = [];
    setState(() {
      timer = Timer.periodic(interval, (timer) {
        if (start == 15) {
          if (widget.viewModel.connectionStatus !=
              DeviceConnectionState.connected) {
            widget.viewModel.disconnect();
            showToast('Time out', Colors.red, Colors.white);
          }
          timer.cancel();
          setState(() {
            start = 0;
            isLoading = false;
          });
        } else {
          if (!widget.viewModel.deviceConnected && start == 0) {
            widget.viewModel.connect();
          } else if (subscribeOutput.length != 72 &&
              widget.viewModel.deviceConnected) {
            isLoading = true;
            subscribeCharacteristic();
            widget.writeWithoutResponse(widget.characteristic, [0x59]);
          } else if (subscribeOutput.length == 72 &&
              widget.viewModel.deviceConnected) {
            setState(() {
              if (paddingType == "Electricity") {
                calculateElectric(subscribeOutput, widget.name);
              } else {
                calculateWater(subscribeOutput, widget.name);
              }
            });
            timer.cancel();
            isLoading = false;
            showToast(
                'All Data Are UpToDate', const Color(0xFF2196F3), Colors.black);
          }
          setState(() {
            start++;
          });
        }
      });
    });
    super.initState();
  }

  Future<void> subscribeCharacteristic() async {
    var newEventData = <int>[];
    subscribeOutput = [];
    await balanceTarrif?.cancel();
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
      newEventData = event;
      if (event.first == 89 && subscribeOutput.isEmpty) {
        subscribeOutput += newEventData;
        previousEventData = newEventData;
      } else if (subscribeOutput.length < 72 && subscribeOutput.isNotEmpty) {
        final equal = (previousEventData.length == newEventData.length) &&
            const ListEquality<int>().equals(previousEventData, newEventData);
        if (!equal) {
          subscribeOutput += newEventData;
          previousEventData = newEventData;
        } else {
          newEventData = [];
        }
      } else if (subscribeOutput.length == 72) {
        subscribeStream?.cancel();
      }
    });
  }

  Future<void> startTimer() async {
    await subscribeStream?.cancel();
    await balanceTarrif?.cancel();
    if (balanceCond && !tarrifCond) {
      await sqlDb.getSpecifiedList(widget.name, 'balance');
      if (myList.first == 9) {
        if (kDebugMode) {
          print('balancehere1 $myList');
        }
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTarrif = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          if (kDebugMode) {
            print('event $event');
          }
          setState(() {
            if (event.length == 1) {
              if (event.first == 9) {
                balanceCond = false;
                sqlDb.updateData('''
                UPDATE Meters
                SET
                balance = 0
                WHERE name = '${widget.name}'
              ''');
                balanceTarrif?.cancel();
                Fluttertoast.showToast(
                  msg: 'Charged Successfully',
                );
              }
            }
          });
        });
      }
    } else if (tarrifCond && !balanceCond) {
      await sqlDb.getSpecifiedList(widget.name, 'tarrif');
      if (myList.first == 16) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTarrif = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          if (kDebugMode) {
            print('event $event');
          }
          setState(() {
            if (event.length == 1) {
              if (event.first == 0x10) {
                tarrifCond = false;
                sqlDb.updateData('''
                UPDATE Meters
                SET
                tarrif = 0
                WHERE name = '${widget.name}'
              ''');
                balanceTarrif?.cancel();
                Fluttertoast.showToast(
                  msg: 'Charged Successfully',
                );
              }
            }
          });
        });
      }
    } else if (tarrifCond && balanceCond) {
      await sqlDb.getSpecifiedList(widget.name, 'tarrif');
      if (myList.first == 16) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTarrif = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          if (kDebugMode) {
            print('balanceherevent $event');
          }
          setState(() {
            if (event.length == 1) {
              if (event.first == 0x10) {
                tarrifCond = false;
                sqlDb.getSpecifiedList(widget.name, 'balance').then((value) => {
                      widget.writeWithoutResponse(widget.characteristic, myList)
                    });
              }
              if (event.first == 9) {
                balanceCond = false;
                sqlDb.updateData('''
              UPDATE Meters
              SET
              balance = 0,
              tarrif = 0
              WHERE name = '${widget.name}'
              ''');
                balanceTarrif?.cancel();
                Fluttertoast.showToast(
                  msg: 'Charged Successfully',
                );
              }
            }
          });
        });
      }
    } else {
      await balanceTarrif?.cancel();
    }
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    timer.cancel();
    Fluttertoast.cancel();
    watMeter = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    eleMeter = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    super.dispose();
  }
}
