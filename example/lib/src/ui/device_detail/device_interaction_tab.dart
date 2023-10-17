import 'dart:async';

// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
import 'package:functional_data/functional_data.dart';
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
  late List<DiscoveredService> discoveredServices;
  late List<int> subscribeOutput;
  StreamSubscription<List<int>>? subscribeStream;
  @override
  void initState() {
    discoveredServices = [];
    subscribeOutput = [];
    setState(() {
      timer = Timer.periodic(interval, (Timer t) {
        print("timer $interval");
        if(!widget.viewModel.deviceConnected){
          print("timer connect");
          widget.viewModel.connect();
        }
        else if(subscribeOutput.length != 72 ){
          print("timer not 72");
          subscribeCharacteristic();
          writeCharacteristicWithResponse();
        }
        else if(subscribeOutput.length == 72 ){
          print("timer 72");
          t.cancel();
        }
      });
    });
    super.initState();
  }

  // Future<void> discoverServices() async {
  //   final result = await widget.viewModel.discoverServices();
  //   discoveredServices = result;
  // }

  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    super.dispose();
    timer.cancel();
  }

  Future<void> subscribeCharacteristic() async {
    var newEventData =<int>[];
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
          newEventData = event;
          setState(() async {
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
              print("subscribe output: $subscribeOutput");
              final id = await sqlDb.readData('''
                SELECT `process` FROM master_table ORDER BY `id` DESC LIMIT 1 
                ''');
              for (Map<dynamic, dynamic> map in id) {
                ids = map['process'].toString();
                print("ids:$ids");
              }
              if(paddingType == "Electricity" ){
                calculateElectric(subscribeOutput);
                sqlDb.saveList( subscribeOutput,clientID.toInt(),meterName, '$paddingType', 'none');
              }
              else if(paddingType == "Water"){
                calculateWater(subscribeOutput);
                sqlDb.saveList( subscribeOutput,clientIDWater.toInt(),meterName, '$paddingType', 'none');
              }
            }
          });
        });
      subscribeOutput = [];
  }

  Future<void> writeCharacteristicWithResponse() async {
    await widget.writeWithResponse(widget.characteristic, [89]);
  }

  // Future<void> writeCharacteristicWithoutResponse(List<int> myList) async {
  //   int chunkSize = 20;
  //   for (int i = 0; i < myList.length; i += chunkSize) {
  //     int end = i + chunkSize;
  //     if (end > myList.length) {
  //       end = myList.length;
  //     }
  //     List<int> chunk = myList.sublist(i, end);
  //     await widget.writeWithoutResponse(widget.characteristic, chunk);
  //   }
  // }

  void startTimer() {
    // const interval = Duration(seconds:1);
    final myInstance = SqlDb();
    timer = Timer.periodic(interval, (Timer t) async {
      // cond => balance
      if (cond) {
        // Code for sublist 1
        myInstance.getList(meterName,'balance');
        if(myList.first == 9){
          widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
            cond = false;
          });
          await widget.writeWithResponse(widget.characteristic, myList);
        }
      }
      // cond0 => tarrif
      else if(cond0){
        // Code for sublist 2
        myInstance.getList(meterName,'tarrif');
        if(myList.first == 16){
          widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
            cond0 = false;
          });
          await widget.writeWithResponse(widget.characteristic, myList);
        }
      }
      else{
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     sqlDb.mydeleteDatabase();
      //   },
      //   child: const Icon(Icons.add),
      // ),
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                                onPressed: (){
                                  widget.viewModel.disconnect();
                                  Navigator.pop(context);
                                },
                                child: Text(TKeys.logout.translate(context),style: const TextStyle(color:Colors.black),),
                            ),
                          ),
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
                                          eleName = snapshot.data![i]['name'].toString();
                                          if(eleName == meterName && widget.viewModel.deviceConnected && paddingType == "Electricity"){
                                              color1 = Colors.green.shade300;
                                              if (ids != 'none') {
                                                isEleEnabled = true;
                                                color2 = Colors.deepPurple.shade100;
                                              }
                                              else{
                                                isEleEnabled = false;
                                                color2 = Colors.grey;
                                              }
                                          }
                                          else{
                                              color1 = Colors.deepPurple.shade100;
                                              isEleEnabled = false;
                                              color2 = Colors.grey;
                                          }
                                          return Padding(
                                            padding: EdgeInsets.symmetric(horizontal:width*.07,vertical: 10.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(18.0),
                                                    side: BorderSide(color: color1)),
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
                                                  Text(
                                                    '${TKeys.name.translate(context)}: ${snapshot.data![i]['name'].toString()}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      SizedBox(width:width*.07),
                                                      Text(
                                                        '${TKeys.currentTarrif.translate(context)}: ',
                                                        style: const TextStyle(
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
                                                          Text(
                                                            TKeys.today.translate(context),
                                                            style: const TextStyle(
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
                                                          Text(
                                                            TKeys.month.translate(context),
                                                            style: const TextStyle(
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
                                                          Text(
                                                            '${TKeys.balance.translate(context)}: ',
                                                            style: const TextStyle(
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
                                                              backgroundColor: color2,
                                                              foregroundColor: Colors.white,
                                                              disabledBackgroundColor: color2,
                                                            ),
                                                            onPressed: isEleEnabled?() async {
                                                                  if(!widget.viewModel.deviceConnected){
                                                                    widget.viewModel.connect();
                                                                  }
                                                                  else if(widget.viewModel.deviceConnected){
                                                                    if(eleName == meterName){
                                                                      // color2 = Colors.green.shade300;
                                                                      startTimer();
                                                                    }
                                                                  }

                                                            }: null,
                                                            child: Text(
                                                              TKeys.recharge.translate(context),
                                                              style: const TextStyle(
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
                                          watName = snapshot.data![i]['name'].toString();
                                          if(watName == meterName && widget.viewModel.deviceConnected && paddingType == "Water"){
                                            color1 = Colors.green.shade300;
                                            if (ids != 'none') {
                                              isWatEnabled = true;
                                              color3 = Colors.deepPurple.shade100;
                                            }
                                            else{
                                              isWatEnabled = false;
                                              color3 = Colors.grey;
                                            }
                                          }
                                          else{
                                            color1 = Colors.deepPurple.shade100;
                                            isWatEnabled = false;
                                            color3 = Colors.grey;
                                          }
                                          return Padding(
                                            padding: EdgeInsets.symmetric(horizontal:width*.07,vertical: 10.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(18.0),
                                                    side: BorderSide(color: color1)),
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
                                                  Text(
                                                    '${TKeys.name.translate(context)}: ${snapshot.data![i]['name'].toString()}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      SizedBox(width:width*.07),
                                                      Text(
                                                        '${TKeys.currentTarrif.translate(context)}: ',
                                                        style: const TextStyle(
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
                                                          Text(
                                                            TKeys.today.translate(context),
                                                            style: const TextStyle(
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
                                                          Text(
                                                            TKeys.month.translate(context),
                                                            style: const TextStyle(
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
                                                                totalReadingWater.toString(),
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
                                                          Text(
                                                            '${TKeys.balance.translate(context)}: ',
                                                            style: const TextStyle(
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
                                                      Column(
                                                        children: [
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              shape: const StadiumBorder(),
                                                              backgroundColor: color3,
                                                              foregroundColor: Colors.white,
                                                              disabledBackgroundColor: color3,
                                                            ),
                                                            onPressed: isEleEnabled?() async {
                                                              if(!widget.viewModel.deviceConnected){
                                                                widget.viewModel.connect();
                                                              }
                                                              else if(widget.viewModel.deviceConnected){
                                                                if(watName == meterName){
                                                                  startTimer();
                                                                }
                                                              }
                                                            }:null,
                                                            child: Text(
                                                              TKeys.recharge.translate(context),
                                                              style: const TextStyle(
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
              }
            });
          }),
      ),
    );
  }
}
