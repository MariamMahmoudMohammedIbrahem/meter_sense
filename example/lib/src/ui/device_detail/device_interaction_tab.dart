import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

                      ///TODO: Remove
                      /*Align(
                        alignment: Alignment.center,
                        child: Text(
                          'summing $summing',
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'echoEvent $echoEvent',
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'balanceCond $balanceCond',
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'tarrifCond $tarrifCond',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: ()async{
                          await widget.writeWithoutResponse(widget.characteristic, [9,0,0,0,0x64,0xAC,0x19]);
                          balanceTarrif = widget
                              .subscribeToCharacteristic(widget.characteristic)
                              .listen((event) {
                            summing.add(event);
                            print('event $event');
                            print('balancehere2 $myList');
                            setState(() {
                              testingEvent = event;
                              if (event.length == 1) {
                                print('inside length 1 in balance');
                                if (event.first == 9) {
                                  print('inside first 9 in balance');
                                  balanceCond = false;
                                  // balanceMaster = 0;
                                  balance = [];
                                  // if (recharged) {
                                  //last edit
                                  sqlDb.updateData('''
                UPDATE Meters
                SET
                balance = 0
                WHERE name = '${widget.name}'
              ''');
                                  balanceTarrif?.cancel();
                                  // recharged = false;
                                  // updated = false;
                                  Fluttertoast.showToast(
                                    msg: 'Charged Successfully',
                                  );
                                  // }
                                }
                              }
                              else{
                                echoEvent = event;
                              }
                            });
                          });
                        },
                        child: const Text('balance testing alone'),
                      ),*/
                      /*
                      Align(
                        alignment: Alignment.center,
                        child: Text('tarrif echo $echoEvent'),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text('balance echo $testingEvent'),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text('balance $balance')),
                      Align(
                          alignment: Alignment.center,
                          child: Text('tarrif $tarrif')),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            balance = [0x09, 0, 0, 0, 100];
                            balance.add(random.nextInt(256));
                            final int sum = balance.fold(
                                0,
                                (previousValue, element) =>
                                    previousValue + element);
                            balance.add(sum);
                            tarrifCond = true;
                          });
                        },
                        child: const Text('balance create list'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            tarrif = [0x10, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 6];
                            tarrif.add(random.nextInt(256));
                            int sum = tarrif.fold(
                                0,
                                (previousValue, element) =>
                                    previousValue + element);
                            tarrif.add(sum);
                            tarrifCond = true;
                          });
                        },
                        child: const Text('tarrif create list'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await widget.writeWithoutResponse(
                              widget.characteristic, balance);
                          subscribeStream = widget
                              .subscribeToCharacteristic(widget.characteristic)
                              .listen((event) {
                            print('event echo$event');
                            setState(() {
                              if (event.length == 1) {
                                testingEvent = event;
                                if (event.first == 9) {
                                  balance = [];
                                }
                              } else {
                                echoEvent = event;
                              }
                            });
                          });
                          // await widget
                          //     .readCharacteristic(widget.characteristic);
                        },
                        child: const Text('balance only'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await subscribeStream?.cancel();
                          await balanceTarrif?.cancel();
                          await widget.writeWithoutResponse(
                              widget.characteristic, tarrif);
                          print('after write');
                          balanceTarrif = widget
                              .subscribeToCharacteristic(widget.characteristic)
                              .listen((event) {
                            print('under tarrifCond $event');
                            setState(() {
                              summing.add(event);
                              if (event.length == 1) {
                                if (event.first == 0x10) {
                                  tarrifCond = false;
                                  tarrif = [];
                                  widget.writeWithoutResponse(
                                      widget.characteristic, balance);
                                } else if (event.first == 9) {
                                  balance = [];
                                  print('under re-setting balance $event');
                                  balanceTarrif?.cancel();
                                }
                              } else {
                                // tarrifCond = false;
                                echoEvent = event;
                              }
                            });
                          });
                          // print('after subscribe$tarrifCond');
                          // await widget
                          //     .readCharacteristic(widget.characteristic);
                          // print('after read figuring out if read is applied before subscribe');
                          // print('after read$tarrifCond');
                          // await balanceTarrif?.cancel();
                          */ /*if (!tarrifCond) {
                            print('inside tarrif condition');
                            await widget.writeWithoutResponse(
                                widget.characteristic, balance);
                            balanceTarrif = widget
                                .subscribeToCharacteristic(
                                    widget.characteristic)
                                .listen((event) {
                              setState(() {
                                summing.add(event);
                                if (event.length == 1) {
                                  if (event.first == 9) {
                                    balance = [];
                                    print('under re-setting balance $event');
                                  }
                                } else {
                                  testingEvent = event;
                                }
                              });
                            });
                            // await widget.readCharacteristic(widget.characteristic);
                          }*/ /*
                        },
                        child: const Text('balance and tarrif'),
                      ),*/
                      /*TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Enter Hexadecimal Value',
                          hintText: 'e.g. 1A2B',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _hexValue = value!;
                            _hex = int.parse(_hexValue);
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // if (_formKey.currentState!.validate()) {
                            //   _formKey.currentState!.save();
                              // Process the hexadecimal value here (e.g., send it to an API or use it in your application)
                            _hexValue = '';
                            _testingStream?.cancel();
                              print('Hexadecimal Value: $_hexValue');
                              widget.writeWithoutResponse(widget.characteristic, [_hex]);
                              _testingStream = widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
                                setState(() {
                                  responseAndroidLists.add(event);
                                  responseAndroid = event;
                                  print('event android testing $event');
                                });
                              });
                              // widget.readCharacteristic(widget.characteristic);
                            // }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                      Text('Response : $responseAndroid'),
                      Text('responseAndroidLists: $responseAndroidLists'),*/
                      ///TODO: Remove
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //charging button
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
                                      child: Text(
                                        !(balanceCond || tarrifCond)
                                            ? TKeys.recharged.translate(context)
                                            : TKeys.recharge.translate(context),
                                      ),
                                    ),
                                    //update button
                                    ElevatedButton(
                                      onPressed: () {
                                        start = 0;
                                        subscribeOutput = [];
                                        setState(() {
                                          testingEvent = [];
                                          timer = Timer.periodic(interval,
                                              (Timer t) {
                                            if (start == 15) {
                                              showToast('Time out', Colors.red,
                                                  Colors.white);
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
                                                setState(() {
                                                  isLoading = true;
                                                });

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
                                                setState(() {
                                                  isLoading = false;
                                                });
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
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                            // foregroundColor: Colors.white,
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
                start = 0;
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

  ///TODO: Remove
  // OverlayEntry? _overlayEntry;
  // AnimationController? _animationController;
  List testingEvent = [];
  List echoEvent = [];

  List<List> summing = [];
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
  ///TODO: Remove
  @override
  void initState() {
    // discoveredServices = [];
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
          start = 0;
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
      print('event subscribe $event');
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
        print('balancehere1 $myList');
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTarrif = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          summing.add(event);
          print('event $event');
          print('balancehere2 $myList');
          setState(() {
            testingEvent = event;
            if (event.length == 1) {
              print('inside length 1 in balance');
              if (event.first == 9) {
                print('inside first 9 in balance');
                balanceCond = false;
                // balanceMaster = 0;
                // balance = [];
                // if (recharged) {
                //last edit
                sqlDb.updateData('''
                UPDATE Meters
                SET
                balance = 0
                WHERE name = '${widget.name}'
              ''');
                balanceTarrif?.cancel();
                // recharged = false;
                // updated = false;
                Fluttertoast.showToast(
                  msg: 'Charged Successfully',
                );
                // }
              }
            } else {
              echoEvent = event;
            }
          });
        });
        // await widget.readCharacteristic(widget.characteristic);
      }
    } else if (tarrifCond && !balanceCond) {
      await sqlDb.getSpecifiedList(widget.name, 'tarrif');
      if (myList.first == 16) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTarrif = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          print('event $event');
          setState(() {
            testingEvent = event;
            if (event.length == 1) {
              if (event.first == 0x10) {
                tarrifCond = false;
                // tarrif = [];
                // tarrifMaster = 0;
                // if (recharged) {
                sqlDb.updateData('''
                UPDATE Meters
                SET
                tarrif = 0
                WHERE name = '${widget.name}'
              ''');
                // recharged = false;
                // updated = false;
                balanceTarrif?.cancel();
                Fluttertoast.showToast(
                  msg: 'Charged Successfully',
                );
                // }
              }
            }
          });
        });
        // await widget.readCharacteristic(widget.characteristic);
      }
    } else if (tarrifCond && balanceCond) {
      await sqlDb.getSpecifiedList(widget.name, 'tarrif');
      if (myList.first == 16) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTarrif = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          summing.add(event);
          print('balanceherevent $event');
          setState(() {
            if (event.length == 1) {
              print('inside length 1 in tarrif');
              if (event.first == 0x10) {
                print('inside first 10 in tarrif');
                tarrifCond = false;
                sqlDb.getSpecifiedList(widget.name, 'balance').then((value) => {
                      widget.writeWithoutResponse(widget.characteristic, myList)
                    });
                // tarrifMaster = 0;
                // tarrif = [];
              }
              if (event.first == 9) {
                print('inside first 9 in balance after  tarrif $myList');
                balanceCond = false;
                // balanceMaster = 0;
                // balance = [];
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
            } else {
              echoEvent = event;
            }
          });
        });
        // await widget.readCharacteristic(widget.characteristic);
      }
      /*await sqlDb.getSpecifiedList(widget.name, 'balance');
      if (myList.first == 9 && !tarrifCond) {
        print('balancehere $myList');
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTarrif = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          setState(() {
            testingEvent = event;
            if (event.length == 1) {
              if (event.first == 9) {
                balanceCond = false;
                balanceMaster = 0;
                balance = [];
                sqlDb.updateData('''
              UPDATE Meters
              SET
              balance = 0,
              tarrif = 0
              WHERE name = '${widget.name}'
              ''');
              }
            }
          });
        });*/
      // await widget.readCharacteristic(widget.characteristic);
      // if (recharged && !cond) {
      // setState(() {
      // recharged = false;
      // updated = false;
      // });
      // }
    } else {
      await balanceTarrif?.cancel();
    }
    // }
    // await subscribeStream?.cancel();
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    timer.cancel();
    Fluttertoast.cancel();
    watMeter = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    eleMeter = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    super.dispose();
  }
}
