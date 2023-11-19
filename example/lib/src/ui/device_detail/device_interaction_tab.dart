import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ble/functions.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/dataPage.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/waterdata.dart';
import 'package:functional_data/functional_data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../t_key.dart';

part 'device_interaction_tab.g.dart';
//ignore_for_file: annotate_overrides

class DeviceInteractionTab extends StatelessWidget {
  const DeviceInteractionTab({
    required this.device,
    required this.characteristic,
    Key? key,
  }) : super(key: key);
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
          writeWithResponse: interactor.writeCharacteristicWithResponse,
          writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
          readCharacteristic: interactor.readCharacteristic,
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

class _DeviceInteractionTab extends StatefulWidget {
  const _DeviceInteractionTab({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.readCharacteristic,
    required this.subscribeToCharacteristic,
    required this.name,
    Key? key,
  }) : super(key: key);
  final DeviceInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;
  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;
  final String name;
  @override
  _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
}

class _DeviceInteractionTabState extends State<_DeviceInteractionTab> {

  @override
  void initState() {
    discoveredServices = [];
    subscribeOutput = [];
    print('device interaction tab');
    now = DateTime.now();
    monthList.clear();
    for (int i = 0; i < 6; i++) {
      final previousMonth = DateTime(now.year, now.month - i, now.day);
      final formattedMonth = DateFormat.MMM().format(previousMonth);
      monthList.add(formattedMonth);
    }
    setState(() {
      timer = Timer.periodic(interval, (Timer t) {
        if (!widget.viewModel.deviceConnected) {
          widget.viewModel.connect();
        } else if (subscribeOutput.length != 72) {
          subscribeCharacteristic();
          widget.writeWithoutResponse(widget.characteristic, [0x59]);
        } else if (subscribeOutput.length == 72) {
          setState(() {
            if (paddingType == "Electricity") {
              calculateElectric(subscribeOutput, widget.name);
            } else {
              calculateWater(subscribeOutput, widget.name);
            }
          });
          t.cancel();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    super.dispose();
    timer.cancel();
  }

  Future<void> subscribeCharacteristic() async {
    var newEventData = <int>[];
    subscribeOutput = [];
    subscribeStream = widget
        .subscribeToCharacteristic(widget.characteristic)
        .listen((event) async {
      newEventData = event;
      if (event.first == 89 && subscribeOutput.isEmpty) {
        subscribeOutput += newEventData;
        previousEventData = newEventData;
        // write = false;
      } else if (subscribeOutput.length < 72 && subscribeOutput.isNotEmpty) {
        final equal = (previousEventData.length == newEventData.length) &&
            const ListEquality<int>().equals(previousEventData, newEventData);
        if (!equal) {
          subscribeOutput += newEventData;
          previousEventData = newEventData;
        } else {
          newEventData = [];
        }
      }
    });
  }

  Future<void> startTimer() async {
    if (cond && !cond0) {
      await myInstance.getSpecifiedList(widget.name, 'balance');
      if (myList.first == 9) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        subscribeStream = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          setState(() {
            if (event.first == 9) {
              cond = false;
              balanceMaster = 0;
              balance = [];
            }
          });
        });
        await widget.readCharacteristic(widget.characteristic);
        if (recharged) {
          await sqlDb.updateData('''
          UPDATE Meters
          SET
          balance = 0
          WHERE name = '${widget.name}'
          ''');
          setState(() {
            recharged = false;
            updated = false;
          });
        }
      }
    } else if (cond0 && !cond) {
      await myInstance.getSpecifiedList(widget.name, 'tarrif');
      if (myList.first == 16) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        subscribeStream = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          setState(() {
            if (event.first == 0x10) {
              cond0 = false;
              tarrif = [];
              tarrifMaster = 0;
            }
          });
        });
        await widget.readCharacteristic(widget.characteristic);
        if (recharged) {
          await sqlDb.updateData('''
          UPDATE Meters
          SET
          tarrif = 0
          WHERE name = '${widget.name}'
          ''');
          setState(() {
            recharged = false;
            updated = false;
          });
        }
      }
    } else if (cond0 && cond) {
      await myInstance.getSpecifiedList(widget.name, 'tarrif');
      if (myList.first == 16) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        subscribeStream = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          setState(() {
            if (event.first == 0x10) {
              cond0 = false;
              tarrifMaster = 0;
              tarrif = [];
            }
          });
        });
        await widget.readCharacteristic(widget.characteristic);
      }
      await myInstance.getSpecifiedList(widget.name, 'balance');
      if (myList.first == 9 && !cond0) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        subscribeStream = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          setState(() {
            if (event.first == 9) {
              cond = false;
              balanceMaster = 0;
              balance = [];
            }
          });
        });
        await widget.readCharacteristic(widget.characteristic);
        if (recharged && !cond) {
          await sqlDb.updateData('''
          UPDATE Meters
          SET
          balance = 0,
          tarrif = 0
          WHERE name = '${widget.name}'
          ''');
          setState(() {
            recharged = false;
            updated = false;
          });
        }
      }
    }
    await subscribeStream?.cancel();
  }

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
              height: height * .8,
              width: width,
              child: Column(children: [
                Flexible(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              TKeys.welcome.translate(context),
                              style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     setState(() {
                            //       visible = !visible;
                            //     });
                            //
                            //     print(visible);
                            //   },
                            //   child: Text(
                            //     "Show Devices",
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 16,
                            //         color: Colors.green.shade50),
                            //   ),
                            // ),
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
                                          DeviceConnectionState.connecting ||
                                      widget.viewModel.connectionStatus ==
                                          DeviceConnectionState.connected)
                                  ? TKeys.disconnect.translate(context)
                                  : TKeys.connect.translate(context)),
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
                          ],
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
                                      ? Colors.green.shade400
                                      : color1),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (paddingType == "Electricity") {
                              sqlDb.editingList(widget.name, 'Electricity');
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                    builder: (context) => StoreData(
                                          name: widget.name,
                                          // count: 0,
                                        )),
                              );
                            } else {
                              sqlDb.editingList(widget.name, 'Water');
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                    builder: (context) => WaterData(
                                          name: widget.name,
                                          // count: 0,
                                        )),
                              );
                            }
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
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                      ),
                                    ),
                                    Text(
                                      widget.name,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(width: width * .07),
                                    Text(
                                      '${TKeys.currentTarrif.translate(context)}: ',
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                      ),
                                    ),
                                    Text(
                                      paddingType == 'Electricity'
                                          ? eleMeter[4].toString()
                                          : watMeter[4].toString(),
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 17,
                                      ),
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
                                          style: TextStyle(
                                            color: Colors.green.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                          ),
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
                                                  ? eleMeter[8].toString()
                                                  : watMeter[8].toString(),
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 17,
                                              ),
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
                                          style: TextStyle(
                                            color: Colors.green.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                          ),
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
                                                  ? eleMeter[1].toString()
                                                  : watMeter[1].toString(),
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 17,
                                              ),
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
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                      ),
                                    ),
                                    Text(
                                      paddingType == 'Electricity'
                                          ? eleMeter[3].toString()
                                          : watMeter[3].toString(),
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                // Text('tarrif version: $tarrifVersion',style: const TextStyle(color:Colors.black),),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const StadiumBorder(),
                                        backgroundColor: recharged
                                            ? Colors.green.shade900
                                            : Colors.grey.shade600,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: recharged
                                            ? Colors.green.shade900
                                            : Colors.grey.shade600,
                                      ),
                                      onPressed: recharged
                                          ? () async {
                                              if (!widget
                                                  .viewModel.deviceConnected) {
                                                widget.viewModel.connect();
                                              } else if (widget
                                                  .viewModel.deviceConnected) {
                                                await startTimer();
                                              }
                                            }
                                          : null,
                                      child: Text(
                                        !recharged
                                            ? TKeys.recharged.translate(context)
                                            : TKeys.recharge.translate(context),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        subscribeOutput = [];
                                        setState(() {
                                          timer = Timer.periodic(interval,
                                              (Timer t) {
                                            if (!widget
                                                .viewModel.deviceConnected) {
                                              widget.viewModel.connect();
                                            } else if (subscribeOutput.length !=
                                                72) {
                                              subscribeCharacteristic();
                                              widget.writeWithoutResponse(
                                                  widget.characteristic,
                                                  [0x59]);
                                            } else if (subscribeOutput.length ==
                                                72) {
                                              setState(() {
                                                if (paddingType ==
                                                    "Electricity") {
                                                  calculateElectric(
                                                      subscribeOutput,
                                                      widget.name);
                                                } else {
                                                  calculateWater(
                                                      subscribeOutput,
                                                      widget.name);
                                                }
                                              });
                                              t.cancel();
                                            }
                                          });
                                        });
                                      },
                                      child: Text(
                                        TKeys.update.translate(context),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: nameList.isNotEmpty,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  TKeys.notConnected.translate(context),
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      shadows: [
                                        Shadow(
                                            color: Colors.grey.shade400,
                                            blurRadius: 2.0,
                                            offset: Offset(2.0, 2.0)),
                                      ]),
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
                                height: 1,
                                thickness: 1,
                                indent: 0,
                                endIndent: 10,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: nameList.isNotEmpty,
                        child: FutureBuilder(
                            future: sqlDb.readData('SELECT * FROM Meters'),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Map>> snapshot) {
                              if (snapshot.hasData) {
                                final filteredItems = snapshot.data!
                                    .where(
                                        (item) => (item['name'] != widget.name))
                                    .toList();
                                return ListView.builder(
                                    itemCount: filteredItems.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, i) {
                                      sqlDb.readMeterData(
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
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            if ('${filteredItems[i]['name']}'
                                                .startsWith('Ele')) {
                                              sqlDb.editingList(
                                                  '${filteredItems[i]['name']}',
                                                  'Electricity');
                                              Navigator.of(context).push<void>(
                                                MaterialPageRoute<void>(
                                                    builder: (context) =>
                                                        StoreData(
                                                          name:
                                                          '${filteredItems[i]['name']}',
                                                          // count: i,
                                                        )),
                                              );
                                            } else {
                                              sqlDb.editingList(
                                                  '${filteredItems[i]['name']}',
                                                  'Water');
                                              Navigator.of(context).push<void>(
                                                MaterialPageRoute<void>(
                                                    builder: (context) =>
                                                        WaterData(
                                                          name: filteredItems[i]
                                                          ['name']
                                                              .toString(),
                                                          // count: i,
                                                        )),
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${TKeys.name.translate(context)}: ',
                                                      style: TextStyle(
                                                        color: Colors.green.shade900,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    Text(
                                                        '${filteredItems[i]['name']}',
                                                      style: TextStyle(
                                                        color: Colors.grey.shade800,
                                                        fontSize: 17,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    SizedBox(width: width * .07),
                                                    Text(
                                                      '${TKeys.currentTarrif.translate(context)}: ',
                                                      style: TextStyle(
                                                        color:
                                                        Colors.green.shade900,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    Text(
                                                      ('${filteredItems[i]['name']}'
                                                          .startsWith('Ele'))
                                                          ? ('${eleMeters['${filteredItems[i]['name']}']?[0]}')
                                                          : ('${watMeters['${filteredItems[i]['name']}']?[0]}'),
                                                      style: TextStyle(
                                                        color:
                                                        Colors.grey.shade800,
                                                        fontSize: 17,
                                                      ),
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
                                                          TKeys.today
                                                              .translate(context),
                                                          style: TextStyle(
                                                            color: Colors
                                                                .green.shade900,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            fontSize: 19,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 25,
                                                              child: Image.asset(
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
                                                              style: TextStyle(
                                                                color: Colors.grey
                                                                    .shade800,
                                                                fontSize: 17,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 30),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          TKeys.month
                                                              .translate(context),
                                                          style: TextStyle(
                                                            color: Colors
                                                                .green.shade900,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            fontSize: 19,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 25,
                                                              child: Image.asset(
                                                                  '${filteredItems[i]['name']}'
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
                                                              style: TextStyle(
                                                                color: Colors.grey
                                                                    .shade800,
                                                                fontSize: 17,
                                                              ),
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
                                                      style: TextStyle(
                                                        color:
                                                        Colors.green.shade900,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    Text(
                                                      ('${filteredItems[i]['name']}'
                                                          .startsWith('Ele'))
                                                          ? ('${eleMeters['${filteredItems[i]['name']}']?[2]}')
                                                          : ('${watMeters['${filteredItems[i]['name']}']?[2]}'),
                                                      style: TextStyle(
                                                        color:
                                                        Colors.grey.shade800,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 17,
                                                      ),
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
            timer = Timer.periodic(interval, (Timer t) {
              if (!widget.viewModel.deviceConnected) {
                widget.viewModel.connect();
              } else if (subscribeOutput.length != 72) {
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
                });
                t.cancel();
              }
            });
          });
          // setState(() {
          //   if (widget.viewModel.deviceConnected) {
          //     // write = true;
          //     subscribeCharacteristic();
          //     widget.writeWithoutResponse(widget.characteristic,[0x59]);
          //   }
          //   else if (subscribeOutput.length == 72) {
          //     setState(() {
          //       if (paddingType == "Electricity") {
          //         calculateElectric(subscribeOutput, widget.name);
          //       }
          //       else {
          //         calculateWater(subscribeOutput, widget.name);
          //       }
          //     });
          //   }
          // });
        }),
      ),
    );
  }
}
// Visibility(
//   visible: visible,
//   child: StreamBuilder(
//       stream: dataStream,
//       builder: (context, AsyncSnapshot<List<Map>> snapshot){
//         if (snapshot.hasData) {
//           final filteredItems = snapshot.data!
//               .where((item) => item['name'] != widget.name)
//               .toList();
//           return ListView.builder(
//               itemCount: filteredItems.length,
//               physics:
//               const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemBuilder: (context, i) {
//                 print(filteredItems[i]['name']);
//                 print(filteredItems[i]['type']);
//                 sqlDb.readMeterData(
//                   filteredItems[i]['name'].toString(),
//                   filteredItems[i]['type'].toString(),
//                   i,
//                 );
//                 return Padding(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: width * .07,
//                       vertical: 10.0),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                         BorderRadius.circular(18.0),
//                         side: BorderSide(
//                             color: widget.viewModel
//                                 .deviceConnected
//                                 ? Colors.green.shade100
//                                 : color1),
//                       ),
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.white,
//                     ),
//                     onPressed: () {
//                       print('khlsna ${filteredItems[i]['name']}');
//                       print('khlsna $i');
//                       print('khlsna ${eleMeters['eleMeter$i']?[0]}');
//                       print('khlsna ${eleMeters['eleMeter$i']?[2]}');
//                       if (filteredItems[i]['type'] ==
//                           "ELectricity") {
//                         Navigator.of(context).push<void>(
//                           MaterialPageRoute<void>(
//                               builder: (context) =>
//                                   StoreData(
//                                     name: '${filteredItems[i]['name']}',
//                                     count: i,
//                                   )),
//                         );
//                       } else {
//                         Navigator.of(context).push<void>(
//                           MaterialPageRoute<void>(
//                               builder: (context) =>
//                                   WaterData(
//                                     name: filteredItems[i]
//                                     ['name']
//                                         .toString(),
//                                     count: i,
//                                   )),
//                         );
//                       }
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8.0),
//                       child: Column(
//                         children: [
//                           Text(
//                             '${TKeys.name.translate(context)}: ${filteredItems[i]['name']}',
//                             style: TextStyle(
//                               color:
//                               Colors.green.shade900,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 19,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Row(
//                             children: [
//                               SizedBox(
//                                   width: width * .07),
//                               Text(
//                                 '${TKeys.currentTarrif.translate(context)}: ',
//                                 style: TextStyle(
//                                   color: Colors
//                                       .green.shade900,
//                                   fontWeight:
//                                   FontWeight.bold,
//                                   fontSize: 19,
//                                 ),
//                               ),
//                               Text(
//                                 (filteredItems[i]
//                                 ['type'] ==
//                                     'Electricity')
//                                     ? ('${eleMeters['eleMeter$i']?[0]}')
//                                     : ('${eleMeters['watMeter$i']?[0]}'),
//                                 style: TextStyle(
//                                   color: Colors
//                                       .grey.shade800,
//                                   fontSize: 17,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment
//                                 .spaceBetween,
//                             children: [
//                               const SizedBox(
//                                 width: 1,
//                               ),
//                               Column(
//                                 children: [
//                                   Text(
//                                     TKeys.today.translate(
//                                         context),
//                                     style: TextStyle(
//                                       color: Colors
//                                           .green.shade900,
//                                       fontWeight:
//                                       FontWeight.bold,
//                                       fontSize: 19,
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       SizedBox(
//                                         width: 25,
//                                         child:
//                                         Image.asset(
//                                           (filteredItems[i]['type'] == 'Electricity')
//                                               ? 'icons/electricityToday.png'
//                                               : 'icons/waterToday.png',
//                                         ),
//                                       ),
//                                       Text(
//                                         (filteredItems[i][
//                                         'type'] ==
//                                             'Electricity')
//                                             ? ('${eleMeters['eleMeter$i']?[3]}')
//                                             : ('${eleMeters['watMeter$i']?[3]}'),
//                                         style: TextStyle(
//                                           color: Colors
//                                               .grey
//                                               .shade800,
//                                           fontSize: 17,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(width: 30),
//                               Column(
//                                 children: [
//                                   Text(
//                                     TKeys.month.translate(
//                                         context),
//                                     style: TextStyle(
//                                       color: Colors
//                                           .green.shade900,
//                                       fontWeight:
//                                       FontWeight.bold,
//                                       fontSize: 19,
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       SizedBox(
//                                         width: 25,
//                                         child: Image.asset(filteredItems[
//                                         i]
//                                         [
//                                         'type'] ==
//                                             'Electricity'
//                                             ? 'icons/electricityMonth.png'
//                                             : 'icons/waterMonth.png'),
//                                       ),
//                                       Text(
//                                         (filteredItems[i][
//                                         'type'] ==
//                                             'Electricity')
//                                             ? ('${eleMeters['eleMeter$i']?[1]}')
//                                             : ('${eleMeters['watMeter$i']?[1]}'),
//                                         style: TextStyle(
//                                           color: Colors
//                                               .grey
//                                               .shade800,
//                                           fontSize: 17,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 width: 1,
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Row(
//                             children: [
//                               SizedBox(
//                                   width: width * .07),
//                               Text(
//                                 '${TKeys.balance.translate(context)}: ',
//                                 style: TextStyle(
//                                   color: Colors
//                                       .green.shade900,
//                                   fontWeight:
//                                   FontWeight.bold,
//                                   fontSize: 19,
//                                 ),
//                               ),
//                               Text(
//                                 (filteredItems[i]
//                                 ['type'] ==
//                                     'Electricity')
//                                     ? ('${eleMeters['eleMeter$i']?[2]}')
//                                     : ('${eleMeters['watMeter$i']?[2]}'),
//                                 style: TextStyle(
//                                   color: Colors
//                                       .grey.shade800,
//                                   fontWeight:
//                                   FontWeight.bold,
//                                   fontSize: 17,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               });
//         }
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//   }),
// ),
