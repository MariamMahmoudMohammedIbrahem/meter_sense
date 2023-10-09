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
import 'package:flutter_reactive_ble_example/src/ui/device_detail/device_list.dart';
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

// void disconnect() {
//   deviceConnector.disconnect(deviceId);
// }
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
  late List<DiscoveredService> discoveredServices;
  late List<int> subscribeOutput;
  StreamSubscription<List<int>>? subscribeStream;
  @override
  void initState() {
    discoveredServices = [];
    subscribeOutput = [];
      timer = Timer.periodic(interval, (Timer t) {
        if(!widget.viewModel.deviceConnected){
          widget.viewModel.connect();
        }
        else if(subscribeOutput.length != 72 ){
          subscribeCharacteristic();
          writeCharacteristicWithResponse();
        }
        else if(subscribeOutput.length == 72 ){
          t.cancel();
        }
      if(valveStatus == 1){
        valve = true;
      }
      else {
        valve = false;
      }
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
    if (kDebugMode) {
      print("subscribe in");
    }
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
              if (kDebugMode) {
                print("subscribeOutput$subscribeOutput");
              }
              if(paddingType == "Electricity" || (deviceNameController.text.isNotEmpty && type == "Electricity" && deviceNameController.text == meterName)){
                if (kDebugMode) {
                  print("start");
                }
                if(paddingType != "Electricity"){
                  sqlDb.saveList( subscribeOutput,clientID.toInt(),meterName, '$paddingType', 'none');
                }
                else{
                  sqlDb.saveList( subscribeOutput,clientID.toInt(),meterName, type, 'none');
                }
                // calculateElectric(subscribeOutput);
              }
              else if(paddingType == "Water"|| (deviceNameController.text.isNotEmpty&& type == "Water")){
                calculateWater(subscribeOutput);
                sqlDb.saveList( subscribeOutput,clientID.toInt(),meterName, '$paddingType', 'none');
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

  Future<void> writeCharacteristicWithoutResponse(List<int> myList) async {
    int chunkSize = 20;
    for (int i = 0; i < myList.length; i += chunkSize) {
      int end = i + chunkSize;
      if (end > myList.length) {
        end = myList.length;
      }
      List<int> chunk = myList.sublist(i, end);
      print("Sending chunk: $chunk");
      await widget.writeWithoutResponse(widget.characteristic, chunk);
    }
  }

  void startTimer() {
    const interval = Duration(seconds:1);
    final myInstance = SqlDb();
    bool cond = true;
    bool cond0 = true;
    timer = Timer.periodic(interval, (Timer t) async {
      if (cond) {
        // Code for sublist 1
        myInstance.getList(int.parse('$clientID'),meterName,type,'balance');
        print('sublist1: $myList');
        if(myList.first == 9){
          widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
            print("event$event");
            cond = false;
          });
          await widget.writeWithResponse(widget.characteristic, myList);
        }
      }
      else if(cond0){
        // Code for sublist 2
        myInstance.getList(int.parse('$clientID'),meterName,type,'tarrif');
        print('sublist2: $myList');
        if(myList.first == 16){
          widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
            print("event2$event");
            cond0 = false;
          });
          await widget.writeWithResponse(widget.characteristic, myList);
        }
      }
      else{
        print("hiii");
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
      body: RefreshIndicator(
        child: ListView(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:height*.8,
              width:width,
              child: Column(
                  children: [
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
                                                  Padding(
                                                    padding: const EdgeInsetsDirectional.only(start: 16.0),
                                                    child: Text(
                                                      "Connection: ${widget.viewModel.connectionStatus}",
                                                      style: const TextStyle(fontWeight: FontWeight.bold ,color: Colors.black),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Meter Name: ${snapshot.data![i]['name'].toString()}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      SizedBox(width:width*.07),
                                                      const Text(
                                                        'valve status ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          child: valve?const Icon(Icons.lock_outlined,color: Colors.red,):const Icon(Icons.lock_open_outlined,color: Colors.green,),
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
                                                      Column(
                                                        children: [
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              shape: const StadiumBorder(),
                                                              backgroundColor: Colors.purple.shade50,
                                                              foregroundColor: Colors.white,
                                                              disabledBackgroundColor: Colors.purple.shade100,
                                                            ),
                                                            onPressed: () async {
                                                                  if(!widget.viewModel.deviceConnected){
                                                                    widget.viewModel.connect();
                                                                  }
                                                                  else if(widget.viewModel.deviceConnected){
                                                                    startTimer();
                                                                    // final myInstance = SqlDb();
                                                                    // myInstance.getList(int.parse('$clientID'),meterName,type,'balance');
                                                                  }
                                                              print("done ");

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
                                                        ],
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
                                                        'waterSN',
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
                                  );
                                }
                                return const Center(child: CircularProgressIndicator(),);
                              }
                          ),
                        ],
                      ),
                    ),
                  ]
              ),
            ),
          ],
        ),
        onRefresh: ()=> Future.delayed(
              const Duration(seconds: 1),(){
            setState(() {
              if(!widget.viewModel.deviceConnected){
                widget.viewModel.connect();
              }
              else if(widget.viewModel.deviceConnected){
                subscribeCharacteristic();
                writeCharacteristicWithResponse();
                // final myInstance = SqlDb();
                // myInstance.getList(2);
              }
            });
          }),
      ),
    );
  }
}
