import 'dart:async';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ble/functions.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/dataPage.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/waterdata.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

part 'device_interaction_tab.g.dart';
//ignore_for_file: annotate_overrides

class DeviceInteractionTab extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceInteractionTab({
    required this.device,
    required this.characteristic,
    Key? key,
  }) : super(key: key);
  final QualifiedCharacteristic characteristic;

  @override
  Widget build(BuildContext context) =>
      Consumer4<BleDeviceConnector, ConnectionStateUpdate, BleDeviceInteractor,BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,interactor,
                __) =>
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
              subscribeToCharacteristic: interactor.subScribeToCharacteristic,
            ),
        );

}

@immutable
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
    required this.subscribeToCharacteristic,
    Key? key,
  }) : super(key: key);
  final DeviceInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;
  final Future<void> Function(
      QualifiedCharacteristic characteristic, List<int> value)
  writeWithResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
  subscribeToCharacteristic;

  @override
  _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
}

class _DeviceInteractionTabState extends State<_DeviceInteractionTab> {
  late List<DiscoveredService> discoveredServices;
  SqlDb sqlDb = SqlDb();
  late String readOutput;
  late String writeOutput;
  late String subscribeOutput;
  late TextEditingController textEditingController;
  StreamSubscription<List<int>>? subscribeStream;
  @override
  void initState() {
    discoveredServices = [];
    readOutput = '';
    writeOutput = '';
    subscribeOutput = '';
    textEditingController = TextEditingController();
    super.initState();
  }

  Future<void> discoverServices() async {
    final result = await widget.viewModel.discoverServices();
    setState(() {
      discoveredServices = result;
    });
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    super.dispose();
  }

  Future<void> subscribeCharacteristic() async {
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
          var newEventData ='';
          newEventData = event.join(', ',);
          // print("newEventData$newEventData");
            if (newEventData != previousEventData) {
              previousEventData = newEventData;
              if (subscribeOutput.length < 229) {
                subscribeOutput += '$newEventData, ';
              }
              else{
                subscribeOutput = '${event.join(', ')}, ';
                callFunctionOnce();
              }
              if(valU == 1){
                clientID = convertToInt(subscribeOutput, 1, 4);
                pulses = convertToInt(subscribeOutput, 9, 2);
                totalCredit = convertToInt(subscribeOutput, 11, 4);
                currentTarrif = convertToInt(subscribeOutput, 15, 1);
                tarrifVersion = convertToInt(subscribeOutput, 16, 2);
                valveStatus = convertToInt(subscribeOutput, 18, 1);
                leackageFlag = convertToInt(subscribeOutput, 19, 1);
                fraudFlag = convertToInt(subscribeOutput, 20, 1);
                fraudHours = convertToInt(subscribeOutput, 21, 1);
                fraudMinutes = convertToInt(subscribeOutput, 22, 1);
                fraudDayOfWeek = convertToInt(subscribeOutput, 23, 1);
                fraudDayOfMonth = convertToInt(subscribeOutput, 24, 1);
                fraudMonth = convertToInt(subscribeOutput, 25, 1);
                fraudYear = convertToInt(subscribeOutput, 26, 1);
                totalDebit = convertToInt(subscribeOutput, 27, 4);
                currentConsumption = convertToInt(subscribeOutput, 31, 4);
                lcHour = convertToInt(subscribeOutput, 35, 1);
                lcMinutes = convertToInt(subscribeOutput, 36, 1);
                lcDayWeek = convertToInt(subscribeOutput, 37, 1);
                lcDayMonth = convertToInt(subscribeOutput, 38, 1);
                lcMonth = convertToInt(subscribeOutput, 39, 1);
                lcYear = convertToInt(subscribeOutput, 40, 1);
                lastChargeValueNumber = convertToInt(subscribeOutput, 41, 5);
                month1 = convertToInt(subscribeOutput, 46, 4);
                month2 = convertToInt(subscribeOutput, 50, 4);
                month3 = convertToInt(subscribeOutput, 54, 4);
                month4 = convertToInt(subscribeOutput, 58, 4);
                month5 = convertToInt(subscribeOutput, 62, 4);
                month6 = convertToInt(subscribeOutput, 66, 4);
                warningLimit = convertToInt(subscribeOutput, 70, 1);
                checkSum = convertToInt(subscribeOutput, 71, 1);
              }
              else if(valU == 2){
                totalCreditWater = convertToInt(subscribeOutput, 11, 4);
              }
            }
        });
    if (kDebugMode) {
      print("subscribeOutput = $subscribeOutput");
    }
    setState(() {
      subscribeOutput = '';
    });
  }


  Future<void> writeCharacteristicWithResponse() async {
    await widget.writeWithResponse(widget.characteristic, [89]);
    setState(() {
      writeOutput = 'Ok';
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        index: 1,
        items: const [
          Icon(
            Icons.electric_bolt_outlined,
            size: 30,
          ),
          Icon(Icons.add_circle_outline, size: 30),
          Icon(Icons.water_drop_outlined, size: 30),
        ],
        color: Colors.deepPurple.shade50,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() async {
            if (index == 0) {
              await Navigator.of(context).pushAndRemoveUntil<void>(
                MaterialPageRoute<void>(builder: (context) => StoreData(device: dataStored,)),
                    (route) => false,
              );
            }
            else if (index == 1) {}
            else if (index == 2) {
              await Navigator.of(context).pushAndRemoveUntil<void>(
                MaterialPageRoute<void>(builder: (context) => WaterData(device: dataStored,)),
                    (route) => false,
              );
            }
          });
        },
      ),
      body:   ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: width * .04,
              right: width * .03,
              top: 10,
            ),
            child: const Text(
              'Your Consumption',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(
              "Connection: ${widget.viewModel.connectionStatus}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: width * 0.07, right: width * 0.07),
            child: SizedBox(
              height: 200,
              width: 400,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil<void>(
                          MaterialPageRoute<void>(builder: (context) => StoreData(device: dataStored,)),
                              (route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.transparent,
                      ),
                      child: Container(
                        height: 200 - 48 / 2, // remove half title box height
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.deepPurple.shade50, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      width: width * .3,
                      height: 35,
                      child: Text(
                        electricSN,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Row(
                          children: [
                            SizedBox(width:width*.08),
                            const Text(
                              'Serial Number: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              "electric",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 1,
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: Image.asset(
                                          'icons/electricityToday.png'),
                                    ),
                                    Text(
                                      totalCredit.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
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
                                const Text(
                                  'This Month',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: Image.asset(
                                          'icons/electricityMonth.png'),
                                    ),
                                    Text(
                                      totalReading.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 1,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Your Balance: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  clientID.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 30),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                backgroundColor: Colors.purple.shade50,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.purple.shade100,
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Recharge',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 1,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: width * 0.07, right: width * 0.07),
            child: SizedBox(
              height: 200,
              width: 400,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                      onPressed: () {

                        Navigator.of(context).pushAndRemoveUntil<void>(
                          MaterialPageRoute<void>(builder: (context) => WaterData(device: dataStored,)),
                              (route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.transparent,
                      ),
                      child: Container(
                        height: 200 - 48 / 2,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.deepPurple.shade50, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      width: width * .3,
                      height: 35,
                      child: Text(
                        waterSN,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Row(
                          children: [
                            SizedBox(width:width*.08),
                            const Text(
                              'Serial Number: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              "electric",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 1,
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: Image.asset(
                                          'icons/electricityToday.png'),
                                    ),
                                    Text(
                                      currentConsumption.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
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
                                const Text(
                                  'This Month',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: Image.asset(
                                          'icons/electricityMonth.png'),
                                    ),
                                    Text(
                                      totalReading.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 1,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Your Balance: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  totalCreditWater.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 30),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                backgroundColor: Colors.purple.shade50,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.purple.shade100,
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Recharge',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 1,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: width*.65/2),
            child: ElevatedButton(
              onPressed: (){
                if(!widget.viewModel.deviceConnected){
                  widget.viewModel.connect();
                }
                else if(widget.viewModel.deviceConnected){
                  subscribeCharacteristic();
                  writeCharacteristicWithResponse();

                }
              },

              child: const Text(
                "update data",
                style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.purple.shade50,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.purple.shade100,
              ),
            ),
          ),
        ]
      ),
    );
  }
}
/*
class _ServiceDiscoveryList extends StatefulWidget {
  const _ServiceDiscoveryList({
    required this.deviceId,
    required this.discoveredServices,
    Key? key,
  }) : super(key: key);

  final String deviceId;
  final List<DiscoveredService> discoveredServices;

  @override
  _ServiceDiscoveryListState createState() => _ServiceDiscoveryListState();
}

class _ServiceDiscoveryListState extends State<_ServiceDiscoveryList> {
  late final List<int> _expandedItems;

  @override
  void initState() {
    _expandedItems = [];
    super.initState();
  }

  String _characteristicsSummary(DiscoveredCharacteristic c) {
    final props = <String>[];
    if (c.isReadable) {
      props.add("read");
    }
    if (c.isWritableWithoutResponse) {
      props.add("write without response");
    }
    if (c.isWritableWithResponse) {
      props.add("write with response");
    }
    if (c.isNotifiable) {
      props.add("notify");
    }
    if (c.isIndicatable) {
      props.add("indicate");
    }

    return props.join("\n");
  }
/*
  Widget _characteristicTile(
          DiscoveredCharacteristic characteristic, String deviceId) =>
      ListTile(
        onTap: () => showDialog<void>(
            context: context,
            builder: (context) => CharacteristicInteractionDialog(
                  characteristic: QualifiedCharacteristic(
                      // characteristicId: characteristic.characteristicId,
                      // serviceId: characteristic.serviceId,
                      characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                      serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                      deviceId: deviceId),
                )),
        title: Text(
          '${characteristic.characteristicId}\n(${_characteristicsSummary(characteristic)})',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      );


  Column buildPanels() {
    final columns = <Column>[];

    widget.discoveredServices.asMap().forEach(
          (index, service) {
        final isExpanded = _expandedItems.contains(index);

        columns.add(
          Column(
            children: [
              // ListTile(
              //   title:
              //   Text(
              //     'Service ID: ${service.serviceId}',
              //     style: const TextStyle(fontSize: 14),
              //   ),
              //   onTap: () {
              //     setState(() {
              //       if (isExpanded) {
              //         _expandedItems.remove(index);
              //       } else {
              //         _expandedItems.add(index);
              //       }
              //     });
              //   },
              // ),
              // if (isExpanded)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Characteristics',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => _characteristicTile(
                        service.characteristics[index],
                        widget.deviceId,
                      ),
                      itemCount: service.characteristicIds.length,
                    ),
                  ],
                ),
              const Divider(),
            ],
          ),
        );
      },
    );
    return Column(children: columns);
  }


  @override
  Widget build(BuildContext context) => widget.discoveredServices.isEmpty
      ? const SizedBox()
      : Padding(
          padding: const EdgeInsetsDirectional.only(
            top: 20.0,
            start: 20.0,
            end: 20.0,
          ),
          child: buildPanels(),
        );
  */
}*/
