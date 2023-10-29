import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ble/functions.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/dataPage.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/waterdata.dart';
import 'package:flutter_reactive_ble_example/src/widgets.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

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
          subscribeToCharacteristic: interactor.subScribeToCharacteristic,
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
    required this.subscribeToCharacteristic,
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
  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;

  @override
  _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
}

class _DeviceInteractionTabState extends State<_DeviceInteractionTab> {
  @override
  void initState() {
    discoveredServices = [];
    subscribeOutput = [];
    write = true;
    setState(() {
      timer = Timer.periodic(interval, (Timer t) {
        if (!widget.viewModel.deviceConnected) {
          widget.viewModel.connect();
        }
        else if (subscribeOutput.length != 72) {
            subscribeCharacteristic();
            widget.writeWithoutResponse(widget.characteristic,[0x59]);
        }
        else if (subscribeOutput.length == 72) {
          setState(() {
            if (paddingType == "Electricity") {
              calculateElectric(subscribeOutput);
            }
            else {
              calculateWater(subscribeOutput);
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
    subscribeStream = widget
        .subscribeToCharacteristic(widget.characteristic)
        .listen((event) async {
      newEventData = event;
      if (event.first == 89 && subscribeOutput.isEmpty) {
        subscribeOutput += newEventData;
        previousEventData = newEventData;
        write = false;
      }
      else if (subscribeOutput.length < 72 && subscribeOutput.isNotEmpty) {
        final equal = (previousEventData.length == newEventData.length) &&
            ListEquality<int>().equals(previousEventData, newEventData);
        if (!equal) {
          subscribeOutput += newEventData;
          previousEventData = newEventData;
        }
        else {
          newEventData = [];
        }
      }
    });
    print("subscribe output: $subscribeOutput");
    print('subscribe end');
  }

  Future<void> writeCharacteristicWithResponse() async {
    print('object');
    await widget.writeWithResponse(widget.characteristic, [0x59]);
  }

  void startTimer() {
    timer = Timer.periodic(interval, (Timer t) async {
      // cond => balance
      if (cond) {
        // Code for sublist 1
        print('cond=> $cond');
        final result = await myInstance.getSpecifiedList(meterName, 'balance');
        print('result => $result');
        if (myList.first == 9) {
          widget
              .subscribeToCharacteristic(widget.characteristic)
              .listen((event) {
            cond = false;
          });
          await widget.writeWithResponse(widget.characteristic, myList);
        }
      }
      // cond0 => tarrif
      else if (cond0) {
        // Code for sublist 2
        myInstance.getSpecifiedList(meterName, 'tarrif');
        if (myList.first == 16) {
          widget
              .subscribeToCharacteristic(widget.characteristic)
              .listen((event) {
            cond0 = false;
          });
          await widget.writeWithResponse(widget.characteristic, myList);
        }
      } else {
        color2 = Colors.grey;
        t.cancel();
      }
    });
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
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  visible = !visible;
                                });

                                print(visible);
                              },
                              child: Text(
                                "Show Devices",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green.shade50),
                              ),
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
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                    builder: (context) => StoreData(
                                          name: meterName,
                                        )),
                              );
                            } else {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                    builder: (context) =>
                                        WaterData(name: meterName)),
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
                                      meterName,
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
                                          ? currentTarrif.toString()
                                          : currentTarrifWater.toString(),
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
                                                  ? currentConsumption
                                                      .toString()
                                                  : currentConsumptionWater
                                                      .toString(),
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
                                                  ? totalReading.toString()
                                                  : totalReadingWater
                                                      .toString(),
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
                                          ? totalCredit.toString()
                                          : totalCreditWater.toString(),
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    backgroundColor: color2,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: color2,
                                  ),
                                  onPressed: () async {
                                    if (!widget.viewModel.deviceConnected) {
                                      widget.viewModel.connect();
                                    } else if (widget
                                        .viewModel.deviceConnected) {
                                      startTimer();
                                    }
                                  },
                                  child: Text(
                                    TKeys.recharge.translate(context),
                                    style: TextStyle(
                                      color: Colors.green.shade50,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: visible,
                        child: FutureBuilder(
                            future: readData(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Map>> snapshot) {
                              if (snapshot.hasData) {
                                final filteredItems = snapshot.data!
                                    .where((item) => item['name'] != meterName)
                                    .toList();
                                return ListView.builder(
                                    itemCount: filteredItems.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, i) {
                                      sqlDb.readMeterData(
                                          filteredItems[i]['name'].toString(),
                                          filteredItems[i]['type'].toString());
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
                                                  color: widget.viewModel
                                                          .deviceConnected
                                                      ? Colors.green.shade100
                                                      : color1),
                                            ),
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            if (filteredItems[i]['type'] ==
                                                "ELectricity") {
                                              Navigator.of(context).push<void>(
                                                MaterialPageRoute<void>(
                                                    builder: (context) =>
                                                        StoreData(
                                                          name: eleName,
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
                                                        )),
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${TKeys.name.translate(context)}: ${filteredItems[i]['name']}',
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade900,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 19,
                                                  ),
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
                                                      (filteredItems[i]
                                                                  ['type'] ==
                                                              'Electricity')
                                                          ? (currentTarrif
                                                              .toString())
                                                          : (currentTarrifWater
                                                              .toString()),
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
                                                                (filteredItems[i]
                                                                            [
                                                                            'type'] ==
                                                                        'Electricity')
                                                                    ? 'icons/electricityToday.png'
                                                                    : 'icons/waterToday.png',
                                                              ),
                                                            ),
                                                            Text(
                                                              (filteredItems[i][
                                                                          'type'] ==
                                                                      'Electricity')
                                                                  ? (currentConsumption
                                                                      .toString())
                                                                  : (currentConsumptionWater
                                                                      .toString()),
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
                                                              child: Image.asset(filteredItems[
                                                                              i]
                                                                          [
                                                                          'type'] ==
                                                                      'Electricity'
                                                                  ? 'icons/electricityMonth.png'
                                                                  : 'icons/waterMonth.png'),
                                                            ),
                                                            Text(
                                                              (filteredItems[i][
                                                                          'type'] ==
                                                                      'Electricity')
                                                                  ? (totalReading
                                                                      .toString())
                                                                  : (totalReadingWater
                                                                      .toString()),
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
                                                      (filteredItems[i]
                                                                  ['type'] ==
                                                              'Electricity')
                                                          ? (totalCredit
                                                              .toString())
                                                          : (totalCreditWater
                                                              .toString()),
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
          setState(() {
            if (!widget.viewModel.deviceConnected) {
              widget.viewModel.connect();
            } else if (widget.viewModel.deviceConnected) {
              write = true;
              subscribeCharacteristic();
              writeCharacteristicWithResponse();
            }
          });
        }),
      ),
    );
  }
}
// if (snapshot.data![i]['type'] == "Electricity") {
//   return MeterButton(
//     name: snapshot.data![i]['name'].toString(),
//     tarrif: currentTarrif.toString(),
//     current: currentConsumption,
//     total: totalReading,
//     totalCredit: totalCredit,
//     color: Colors.deepPurple.shade100,
//     onPressed: () {
//       Navigator.of(context).push<void>(
//         MaterialPageRoute<void>(
//             builder: (context) =>
//             const StoreData()),
//       );
//     },
//     isEnabled: false,
//     color2: Colors.grey,
//     onPressed2: () async {},
//   );
// }
// else if (snapshot.data![i]['type'] == "Water" ){
//   return MeterButton(
//     name: snapshot.data![i]['name'].toString(),
//     tarrif: currentTarrifWater.toString(),
//     current: currentConsumptionWater,
//     total: totalReadingWater,
//     totalCredit: totalCreditWater,
//     color: Colors.deepPurple.shade100,
//     onPressed: (){
//       Navigator.of(context).push<void>(
//         MaterialPageRoute<void>(
//             builder: (context) =>
//             const WaterData()),
//       );
//     },
//     isEnabled: false,
//     color2: Colors.grey,
//     onPressed2: (){},
//   );
// }

/*FutureBuilder(
                          future: readData(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map>> snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    if (snapshot.data![i]['type'] == "Electricity") {
                                      eleName = snapshot.data![i]['name'].toString();
                                      if (eleName == meterName && widget.viewModel.deviceConnected && paddingType == "Electricity") {
                                        color1 = Colors.green.shade300;
                                        if (ids != 'none') {
                                          isEleEnabled = true;
                                          color2 = Colors.deepPurple.shade100;
                                        } else {
                                          isEleEnabled = false;
                                          color2 = Colors.grey;
                                        }
                                      }
                                      else {
                                        color1 = Colors.deepPurple.shade100;
                                        isEleEnabled = false;
                                        color2 = Colors.grey;
                                      }
                                      return MeterButton(
                                        name: eleName,
                                        tarrif: currentTarrif.toString(),
                                        current: currentConsumption,
                                        total: totalReading,
                                        totalCredit: totalCredit,
                                        color: color1,
                                        onPressed: () {
                                          Navigator.of(context).push<void>(
                                            MaterialPageRoute<void>(
                                                builder: (context) =>
                                                    const StoreData()),
                                          );
                                        },
                                        isEnabled: isEleEnabled,
                                        color2: color2,
                                        onPressed2: () async {
                                          if (!widget.viewModel.deviceConnected) {
                                            widget.viewModel.connect();
                                          }
                                          else if (widget.viewModel.deviceConnected) {
                                            if (eleName == meterName) {
                                              startTimer();
                                            }
                                          }
                                        },
                                      );
                                    }
                                    else{
                                        watName =
                                            snapshot.data![i]['name'].toString();
                                        if (watName == meterName &&
                                            widget.viewModel.deviceConnected &&
                                            paddingType == "Water") {
                                          color1 = Colors.green.shade300;
                                          if (ids != 'none') {
                                            isWatEnabled = true;
                                            color3 = Colors.deepPurple.shade100;
                                          } else {
                                            isWatEnabled = false;
                                            color3 = Colors.grey;
                                          }
                                        } else {
                                          color1 = Colors.deepPurple.shade100;
                                          isWatEnabled = false;
                                          color3 = Colors.grey;
                                        }
                                        return MeterButton(
                                          name: watName,
                                          tarrif: currentTarrifWater.toString(),
                                          current: currentConsumptionWater,
                                          total: totalReadingWater,
                                          totalCredit: totalCreditWater,
                                          color: color1,
                                          onPressed: (){
                                            Navigator.of(context).push<void>(
                                              MaterialPageRoute<void>(
                                                  builder: (context) =>
                                                  const WaterData()),
                                            );
                                          },
                                          isEnabled: isWatEnabled,
                                          color2: color2,
                                          onPressed2: (){
                                            if (!widget.viewModel.deviceConnected) {
                                              widget.viewModel.connect();
                                            }
                                            else if (widget.viewModel.deviceConnected) {
                                              if (watName == meterName) {
                                                startTimer();
                                              }
                                            }
                                          },
                                        );
                                    }
                                  });
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }),
                      FutureBuilder(
                          future: sqlDb.readMeterData("Water"),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map>> snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    if (snapshot.data![i]['type'] != "Electricity"){
                                      watName =
                                          snapshot.data![i]['name'].toString();
                                      if (watName == meterName &&
                                          widget.viewModel.deviceConnected &&
                                          paddingType == "Water") {
                                        color1 = Colors.green.shade300;
                                        if (ids != 'none') {
                                          isWatEnabled = true;
                                          color3 = Colors.deepPurple.shade100;
                                        } else {
                                          isWatEnabled = false;
                                          color3 = Colors.grey;
                                        }
                                      } else {
                                        color1 = Colors.deepPurple.shade100;
                                        isWatEnabled = false;
                                        color3 = Colors.grey;
                                      }
                                      return MeterButton(
                                        name: watName,
                                        tarrif: currentTarrifWater.toString(),
                                        current: currentConsumptionWater,
                                        total: totalReadingWater,
                                        totalCredit: totalCreditWater,
                                        color: color1,
                                        onPressed: (){
                                          Navigator.of(context).push<void>(
                                            MaterialPageRoute<void>(
                                                builder: (context) =>
                                                const WaterData()),
                                          );
                                        },
                                        isEnabled: isWatEnabled,
                                        color2: color2,
                                        onPressed2: (){
                                          if (!widget.viewModel.deviceConnected) {
                                            widget.viewModel.connect();
                                          }
                                          else if (widget.viewModel.deviceConnected) {
                                            if (watName == meterName) {
                                              startTimer();
                                            }
                                          }
                                        },
                                      );
                                    }
                                  });
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }),*/
