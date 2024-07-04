import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ble/functions.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/data_page.dart';
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
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.readCharacteristic,
    required this.subscribeToCharacteristic,
    required this.name,
  });
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
              height: height * .8,
              width: width,
              child: Column(children: [
                Flexible(
                  child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width*.07),
                        child: Text(
                          TKeys.welcome.translate(context),
                          style: TextStyle(
                              color: Colors.green.shade900,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width*.07),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                      : Colors.red.shade900),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            sqlDb.editingList(widget.name).then((value) {
                              if (paddingType == "Electricity") {
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                      builder: (context) => StoreData(
                                            name: widget.name,
                                          )),
                                );
                              } else {
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                      builder: (context) => WaterData(
                                            name: widget.name,
                                          )),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //charging button
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const StadiumBorder(),
                                        backgroundColor: (cond || cond0)
                                            ? Colors.green.shade900
                                            : Colors.grey.shade600,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: (cond || cond0)
                                            ? Colors.green.shade900
                                            : Colors.grey.shade600,
                                      ),
                                      onPressed: (cond || cond0)
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
                                        !(cond || cond0)
                                            ? TKeys.recharged.translate(context)
                                            : TKeys.recharge.translate(context),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    //update button
                                    ElevatedButton(
                                      onPressed: () {
                                        subscribeOutput = [];
                                        setState(() {
                                          testingEvent = [];
                                          timer = Timer.periodic(interval,
                                              (Timer t) {
                                            if (start == 15) {
                                              showToast('Time out',
                                                  Colors.red, Colors.white);
                                              timer.cancel();
                                              start = 0;
                                            } else {
                                              setState(() {
                                                start++;
                                              });
                                              if (!widget
                                                  .viewModel.deviceConnected) {
                                                widget.viewModel.connect();
                                              } else if (subscribeOutput
                                                      .length !=
                                                  72) {
                                                subscribeCharacteristic();
                                                widget.writeWithoutResponse(
                                                    widget.characteristic,
                                                    [0x59]);
                                              } else if (subscribeOutput
                                                      .length ==
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
                                                showToast(
                                                    'All Data Are UpToDate',
                                                    const Color(0xFF2196F3),
                                                    Colors.black);
                                              }
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
                        visible: nameList.length != 1 && nameList.isNotEmpty,
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
                                            offset: const Offset(2.0, 2.0)),
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
                                            foregroundColor: Colors.white,
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
                                                          // count: i,
                                                        )),
                                              );
                                            } else {
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${TKeys.name.translate(context)}: ',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .green.shade900,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${filteredItems[i]['name']}',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontSize: 17,
                                                      ),
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
                                                      style: TextStyle(
                                                        color: Colors
                                                            .green.shade900,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    Text(
                                                      ('${filteredItems[i]['name']}'
                                                              .startsWith(
                                                                  'Ele'))
                                                          ? ('${eleMeters['${filteredItems[i]['name']}']?[0]}')
                                                          : ('${watMeters['${filteredItems[i]['name']}']?[0]}'),
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade800,
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
                                                          TKeys.today.translate(
                                                              context),
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
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
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
                                                          TKeys.month.translate(
                                                              context),
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
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
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
                                                    SizedBox(
                                                        width: width * .07),
                                                    Text(
                                                      '${TKeys.balance.translate(context)}: ',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .green.shade900,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 19,
                                                      ),
                                                    ),
                                                    Text(
                                                      ('${filteredItems[i]['name']}'
                                                              .startsWith(
                                                                  'Ele'))
                                                          ? ('${eleMeters['${filteredItems[i]['name']}']?[2]}')
                                                          : ('${watMeters['${filteredItems[i]['name']}']?[2]}'),
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade800,
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
            timer = Timer.periodic(interval, (timer) {
              if (start == 15) {
                showToast('Time out', Colors.red, Colors.white);
                timer.cancel();
                start = 0;
              } else {
                setState(() {
                  start++;
                });
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
                  timer.cancel();
                }
              }
            });
          });
        }),
      ),
    );
  }

  // OverlayEntry? _overlayEntry;
  // AnimationController? _animationController;
  List testingEvent = [];

  /*void _showTimeoutSnackBar(String text, Color bgColor, Color txtColor) {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _overlayEntry = _createOverlayEntry(text, bgColor, txtColor);

    Overlay.of(context).insert(_overlayEntry!);
    _animationController?.forward();

    _animationController?.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (_animationController != null && _animationController!.isAnimating) {
        _animationController?.reverse().whenComplete(() {
          _animationController?.dispose();
          _animationController = null;
        });
      }
    });
  }

  OverlayEntry _createOverlayEntry(String text, Color bgColor, Color txtColor) => OverlayEntry(
        builder: (context) => Positioned(
          bottom: 20.0,
          left: MediaQuery.of(context).size.width * 0.1,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: const Offset(0, 0),
              ).animate(CurvedAnimation(
                parent: _animationController!,
                curve: Curves.easeInOut,
              )),
              child: FadeTransition(
                opacity: _animationController!,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(color: txtColor,fontWeight: FontWeight.bold, fontSize: 18,),
                  ),
                ),
              ),
            ),
          ),
        ),
      );*/
  @override
  void initState() {
    // discoveredServices = [];
    subscribeOutput = [];
    setState(() {
      timer = Timer.periodic(interval, (timer) {
        if (start == 15) {
          if(widget.viewModel.connectionStatus != DeviceConnectionState.connected) {
            widget.viewModel.disconnect();
            showToast('Time out', Colors.red, Colors.white);
          }
          timer.cancel();
          start = 0;
        } else {
          if (!widget.viewModel.deviceConnected && start == 0) {
            widget.viewModel.connect();
          }
          else if (subscribeOutput.length != 72 && widget.viewModel.deviceConnected) {
            subscribeCharacteristic();
            widget.writeWithoutResponse(widget.characteristic, [0x59]);
          }
          else if (subscribeOutput.length == 72 && widget.viewModel.deviceConnected) {
            setState(() {
              if (paddingType == "Electricity") {
                calculateElectric(subscribeOutput, widget.name);
              } else {
                calculateWater(subscribeOutput, widget.name);
              }
            });
            timer.cancel();
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
    subscribeStream = widget
        .subscribeToCharacteristic(widget.characteristic)
        .listen((event) async {
      newEventData = event;
      testingEvent = event;
      print('event $event');
      if (event.first == 89 && subscribeOutput.isEmpty) {
        subscribeOutput += newEventData;
        previousEventData = newEventData;
        print('here 89 $newEventData');
        // write = false;
      } else if (subscribeOutput.length < 72 && subscribeOutput.isNotEmpty) {
        final equal = (previousEventData.length == newEventData.length) &&
            const ListEquality<int>().equals(previousEventData, newEventData);
        print('equal $equal');
        if (!equal) {
          subscribeOutput += newEventData;
          previousEventData = newEventData;
          print('inside equal new $newEventData');
          print('inside equal old $previousEventData');
        } else {
          print('sadly equal');
          newEventData = [];
        }
      }
    });
  }

  Future<void> startTimer() async {
    if (cond && !cond0) {
      await sqlDb.getSpecifiedList(widget.name, 'balance');
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
              // if (recharged) {
              //last edit
              sqlDb.updateData('''
                UPDATE Meters
                SET
                balance = 0
                WHERE name = '${widget.name}'
              ''');
              // recharged = false;
              updated = false;
              Fluttertoast.showToast(
                msg: 'Charged Successfully',
              );
              // }
            }
          });
        });
        await widget.readCharacteristic(widget.characteristic);
      }
    } else if (cond0 && !cond) {
      await sqlDb.getSpecifiedList(widget.name, 'tarrif');
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
              // if (recharged) {
              sqlDb.updateData('''
                UPDATE Meters
                SET
                tarrif = 0
                WHERE name = '${widget.name}'
              ''');
              // recharged = false;
              updated = false;
              Fluttertoast.showToast(
                msg: 'Charged Successfully',
              );
              // }
            }
          });
        });
        await widget.readCharacteristic(widget.characteristic);
      }
    } else if (cond0 && cond) {
      await sqlDb.getSpecifiedList(widget.name, 'tarrif');
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
      await sqlDb.getSpecifiedList(widget.name, 'balance');
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
        // if (recharged && !cond) {
        await sqlDb.updateData('''
          UPDATE Meters
          SET
          balance = 0,
          tarrif = 0
          WHERE name = '${widget.name}'
          ''');
        setState(() {
          // recharged = false;
          updated = false;
        });
        // }
      }
    }
    await subscribeStream?.cancel();
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    timer.cancel();
    Fluttertoast.cancel();
    super.dispose();
  }
}
