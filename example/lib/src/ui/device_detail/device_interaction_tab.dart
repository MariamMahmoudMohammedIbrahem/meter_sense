import 'dart:async';
import 'dart:math';

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
  final Future<List<int>> Function(
      QualifiedCharacteristic characteristic)
  readCharacteristic;
  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;
  final String name;
  @override
  _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
}

class _DeviceInteractionTabState extends State<_DeviceInteractionTab> {
  final dataStreamController = StreamController<List<Map>>();

  Stream<List<Map>> get dataStream => dataStreamController.stream;
  void fetchDataAndAddToStream() async {
    // Simulate data retrieval (replace with your data fetching logic)
    // await Future.delayed(Duration(seconds: 2));

    // Add data to the stream
    final data = await readData();
    dataStreamController.sink.add(data);
  }

  @override
  void initState() {
    discoveredServices = [];
    subscribeOutput = [];
    fetchDataAndAddToStream();
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
              calculateElectric(subscribeOutput, widget.name);
              tarrifVersion = convertToInt(subscribeOutput, 16, 2);
            }
            else {
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
    dataStreamController.close();
    super.dispose();
    timer.cancel();
  }

  Future<void> subscribeCharacteristic() async {
    var newEventData = <int>[];
    subscribeOutput=[];
    subscribeStream = widget
        .subscribeToCharacteristic(widget.characteristic)
        .listen((event) async {
      newEventData = event;
      if (event.first == 89 && subscribeOutput.isEmpty) {
        subscribeOutput += newEventData;
        previousEventData = newEventData;
        // write = false;
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

  Future<void> startTimer() async {
    // timer = Timer.periodic(interval, (Timer t) async {
      // cond => balance && cond0 => tarrif
      if (cond && !cond0) {
        // Code for sublist 1
        print('cond=> $cond');
        final result = await myInstance.getSpecifiedList(widget.name, 'balance');
        print('result => $result');
        // if (myList.first == 9) {
        //   subscribeStream = widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
        //     setState(() {
        //       cond = false;
        //     });
        //   });
        //   if(!recharged){
        //     await widget.writeWithoutResponse(widget.characteristic, myList);
        //     print('hi i am repeated');
        //     setState(() {
        //       recharged = true;
        //     });
        //   }
        // }
        if (myList.first == 9) {
          await widget.writeWithoutResponse(widget.characteristic, myList);
          subscribeStream = widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
            setState(() {
              print('balance $event');
              if(event.first == 9){
                cond = false;
                balanceMaster = 0;
              }
            });
          });
          await widget.readCharacteristic(widget.characteristic);
          if(!recharged){
            print('hi i am repeated');
            setState(() {
              recharged = true;
            });
          }
        }
      }
      else if (cond0 && !cond) {
        // Code for sublist 2
        final result = await myInstance.getSpecifiedList(widget.name, 'tarrif');
        print('result => $result');
        if (myList.first == 16) {
          await widget.writeWithoutResponse(widget.characteristic, myList);
          subscribeStream =  widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
            print('tarrif $event');
            if(event.first == 0x10){
              setState(() {
                cond0 = false;
                tarrifMaster = 0;
              });
              print('cond $cond0');
            }
          });
          await widget.readCharacteristic(widget.characteristic);
        }
        subscribeStream?.cancel();
      }
      else if(cond0 && cond){
        await myInstance.getSpecifiedList(widget.name, 'tarrif');
        if (myList.first == 16) {
          await widget.writeWithoutResponse(widget.characteristic, myList);
          subscribeStream =  widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
            print('tarrif $event');
            if(event.first == 0x10){
              setState(() {
                cond0 = false;
                tarrifMaster = 0;
              });
              print('cond $cond0');
            }
          });
          await widget.readCharacteristic(widget.characteristic);
        }
        subscribeStream?.cancel();
        Timer(Duration(seconds: 2),(){print('timer is done');});
        await myInstance.getSpecifiedList(widget.name, 'balance');
        if (myList.first == 9 && !cond0) {
          await widget.writeWithoutResponse(widget.characteristic, myList);
          subscribeStream = widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
            setState(() {
              print('balance $event');
              if(event.first == 9){
                cond = false;
                balanceMaster = 0;
              }
            });
          });
          await widget.readCharacteristic(widget.characteristic);
          if(!recharged && !cond){
            print('hi i am repeated');
            setState(() {
              recharged = true;
            });
          }
        }
        subscribeStream?.cancel();
      }
    // });
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
                                          name: widget.name,
                                      count: 0,
                                        )),
                              );
                            } else {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                    builder: (context) =>
                                        WaterData(name: widget.name,count: 0,)),
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
                                                  ? eleMeter[8]
                                                      .toString()
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
                                Text('tarrif version: $tarrifVersion',style: const TextStyle(color:Colors.black),),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const StadiumBorder(),
                                        backgroundColor: (cond || cond0)?Colors.green.shade900: Colors.grey.shade600,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: (cond || cond0)?Colors.green.shade900: Colors.grey.shade600,
                                      ),
                                      onPressed: () async {
                                        if (!widget.viewModel.deviceConnected) {
                                          widget.viewModel.connect();
                                        } else if (widget
                                            .viewModel.deviceConnected) {
                                          await startTimer();
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
                                    ElevatedButton(
                                      onPressed: (){
                                        subscribeOutput = [];
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
                                                  calculateElectric(subscribeOutput, widget.name);
                                                }
                                                else {
                                                  print('why not calculated?');
                                                  calculateWater(subscribeOutput, widget.name);
                                                }
                                              });
                                              t.cancel();
                                            }
                                          });
                                        });
                                      },
                                      child: Text(TKeys.update.translate(context)),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: (){
                                    myList = [16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x0C];
                                    final random = Random();
                                    myList.add(random.nextInt(255));

                                    int sum = myList.fold(0, (previousValue, element) => previousValue + element);
                                    myList.add(sum);
                                    widget.writeWithoutResponse(widget.characteristic,myList);
                                    widget.subscribeToCharacteristic(widget.characteristic).listen((event) {print('write button $event');});
                                    widget.readCharacteristic(widget.characteristic);
                                  },
                                  child: Text('write'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder(
                          future: readData(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map>> snapshot) {
                            if (snapshot.hasData) {
                              final filteredItems = snapshot.data!
                                  .where((item) => (item['name'] != widget.name))
                                  .toList();
                              print('1   $filteredItems');
                              print('2   $widget.name');
                              return ListView.builder(
                                  itemCount: filteredItems.length,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    sqlDb.readMeterData(
                                        '${filteredItems[i]['name']}',
                                        '${filteredItems[i]['type']}',
                                        i,
                                    );
                                    // print('khlsna ${filteredItems[i]['name']}');
                                    // print('khlsna ${filteredItems[i]['type']}');
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
                                          if (filteredItems[i]['type'] == "Electricity") {
                                            Navigator.of(context).push<void>(
                                              MaterialPageRoute<void>(
                                                  builder: (context) =>
                                                      StoreData(
                                                        name: '${filteredItems[i]['name']}',
                                                        count: i,
                                                      )),
                                            );
                                          }
                                          else {
                                            // print('padding type $paddingType');
                                            Navigator.of(context).push<void>(
                                              MaterialPageRoute<void>(
                                                  builder: (context) =>
                                                      WaterData(
                                                        name: filteredItems[i]
                                                                ['name']
                                                            .toString(),
                                                        count: i,
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
                    ],
                  ),
                ),
              ]
              ),
            ),
          ],
        ),
        onRefresh: () => Future.delayed(const Duration(seconds: 1), () {
          subscribeOutput = [];
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
                    calculateElectric(subscribeOutput, widget.name);
                  }
                  else {
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