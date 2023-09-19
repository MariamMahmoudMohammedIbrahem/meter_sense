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
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/waterdata.dart';
import 'package:flutter_reactive_ble_example/src/ui/recharge.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

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
                  discoverServices: () => serviceDiscoverer.discoverServices(device.id)),
              characteristic: characteristic,
              writeWithResponse: interactor.writeCharacteristicWithResponse,
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

// void disconnect() {
//   deviceConnector.disconnect(deviceId);
// }
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
  late List<int> subscribeOutput;
  StreamSubscription<List<int>>? subscribeStream;
  @override
  void initState() {
    discoveredServices = [];
    subscribeOutput = [];
    textEditingController = TextEditingController();
    // Define a duration for the interval
    setState(() {
      const interval = Duration(seconds: 1);
      // Start a periodic timer that calls your function
      timer = Timer.periodic(interval, (Timer t) {
        if(!widget.viewModel.deviceConnected){
          widget.viewModel.connect();
        }
        else if(subscribeOutput.length != 72 ){
          print("setss");
          subscribeCharacteristic();
          writeCharacteristicWithResponse();
        }
        else if(subscribeOutput.length == 72 ){
          t.cancel();
        }

      });
    });

    super.initState();
  }

  Future<void> discoverServices() async {
    final result = await widget.viewModel.discoverServices();
    // setState(() {
    discoveredServices = result;
    // });
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    super.dispose();
    timer.cancel();
  }

  Future<void> subscribeCharacteristic() async {
    var newEventData =<int>[];
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
          newEventData = event;
          setState(() {
            if (subscribeOutput.length < 72) {
              final equal = newEventData.length == previousEventData.length && newEventData.every(previousEventData.contains);
              if (!equal) {
                subscribeOutput += newEventData ;
                previousEventData = newEventData;
              }
              else{
                newEventData= [];
              }
            }
            else{
              print("subscribeOutput$subscribeOutput");
              if(paddingType == "Electricity"){
                print("start");
                calculateElectric(subscribeOutput);
              }
              else if(paddingType == "Water"){
                calculateWater(subscribeOutput);
              }

            }
          });
        });
    // setState(() {
      subscribeOutput = [];
    // });
  }


  Future<void> writeCharacteristicWithResponse() async {
    await widget.writeWithResponse(widget.characteristic, [89]);
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
          if (index == 0) {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                  builder: (context) => const StoreData()),
            );
          }
          else if(index == 1){}
          else if (index == 2) {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                  builder: (context) => const WaterData()),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          sqlDb.mydeleteDatabase();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
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
            Flexible(
              child: ListView(
                children: [
                  FutureBuilder(
                      future: readData(),
                      builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot){
                        if(snapshot.hasData){
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context,i){
                                if(snapshot.data![i]['type'] == "Electricity"){
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal:width*.07,vertical: 10.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                            side: BorderSide(color: Colors.deepPurple.shade100)),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: (){
                                        Navigator.of(context).push<void>(
                                          MaterialPageRoute<void>(builder: (context) => const StoreData()),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width:width*.07),
                                              const Text(
                                                'Meter Name: ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                snapshot.data![i]['name'].toString(),
                                                style: const TextStyle(
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
                                            children: [
                                              SizedBox(width:width*.07),
                                              const Text(
                                                'Current Tarrif: ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                currentTarrif.toString(),
                                                style: const TextStyle(
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
                                                    totalCredit.toString(),
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
                                                onPressed: () {
                                                  Navigator.of(context).push<void>(
                                                    MaterialPageRoute<void>(builder: (context) => const Recharge()),
                                                  );
                                                },
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
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                else{
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal:width*.07),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                            side: BorderSide(color: Colors.deepPurple.shade100)),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: (){
                                        Navigator.of(context).push<void>(
                                          MaterialPageRoute<void>(builder: (context) => const WaterData()),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width:width*.08),
                                              const Text(
                                                'Meter Name: ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                waterSN,
                                                style: const TextStyle(
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
                                            children: [
                                              SizedBox(width:width*.07),
                                              const Text(
                                                'Current Tarrif: ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                currentTarrifWater.toString(),
                                                style: const TextStyle(
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
                                                            'icons/waterToday.png'),
                                                      ),
                                                      Text(
                                                        currentConsumptionWater.toString(),
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
                                                            'icons/waterMonth.png'),
                                                      ),
                                                      Text(
                                                        totalCreditWater.toString(),
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
                                                onPressed: () {
                                                  Navigator.of(context).push<void>(
                                                    MaterialPageRoute<void>(builder: (context) => const Recharge()),
                                                  );
                                                },
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
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }

                            /*Card(
                              child: ListTile(
                                title: Text("Meter Name: ${snapshot.data![i]['name']}"),
                                subtitle: Text("Meter Type: ${snapshot.data![i]['type']}"),
                              ),
                            )*/
                          );
                        }
                        return const Center(child: CircularProgressIndicator(),);
                      }
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  // Check if the item is a padding item (empty string)
                  if(valU==1){
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal:width*.07,vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.deepPurple.shade100)),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: (){
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(builder: (context) => const StoreData()),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(width:width*.07),
                                const Text(
                                  'Meter Name: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  electricSN,
                                  style: const TextStyle(
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
                              children: [
                                SizedBox(width:width*.07),
                                const Text(
                                  'Current Tarrif: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  currentTarrif.toString(),
                                  style: const TextStyle(
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
                                      totalCredit.toString(),
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
                                  onPressed: () {
                                    Navigator.of(context).push<void>(
                                      MaterialPageRoute<void>(builder: (context) => const Recharge()),
                                    );
                                  },
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
                          ],
                        ),
                      ),
                    );
                  }
                  else if(valU==2){
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal:width*.07),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.deepPurple.shade100)),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: (){
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(builder: (context) => const WaterData()),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(width:width*.08),
                                const Text(
                                  'Meter Name: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  waterSN,
                                  style: const TextStyle(
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
                              children: [
                                SizedBox(width:width*.07),
                                const Text(
                                  'Current Tarrif: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  currentTarrifWater.toString(),
                                  style: const TextStyle(
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
                                              'icons/waterToday.png'),
                                        ),
                                        Text(
                                          currentConsumptionWater.toString(),
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
                                              'icons/waterMonth.png'),
                                        ),
                                        Text(
                                          totalCreditWater.toString(),
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
                                  onPressed: () {
                                    Navigator.of(context).push<void>(
                                      MaterialPageRoute<void>(builder: (context) => const Recharge()),
                                    );
                                  },
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
                          ],
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: width*.65/2,vertical: 10.0),
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
