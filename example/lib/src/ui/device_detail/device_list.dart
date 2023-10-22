import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart' as qrScan;
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/localization_service.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_scanner.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ui/master/master_station.dart';
import 'package:flutter_reactive_ble_example/src/ble/navigatorTest.dart';
import 'package:flutter_reactive_ble_example/t_key.dart';
import 'package:functional_data/functional_data.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ble/ble_logger.dart';
import '../../ble/functions.dart';
import 'device_interaction_tab.dart';

part 'device_list.g.dart';
//ignore_for_file: annotate_overrides

late TextEditingController deviceNameController;

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer4<BleScanner, BleScannerState?, BleLogger, BleDeviceConnector>(
        builder:
            (_, bleScanner, bleScannerState, bleLogger, deviceConnector, __) =>
                DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: deviceConnector,
        ),
      );
}

@immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.deviceConnector,
    required this.discoverServices,
  });

  final String deviceId;
  final BleDeviceConnector deviceConnector;
  @CustomEquality(Ignore())
  final Future<List<DiscoveredService>> Function() discoverServices;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class DeviceList extends StatefulWidget {
  const DeviceList({required this.scannerState, required this.startScan, required this.stopScan, required this.deviceConnector, super.key,
  });

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final BleDeviceConnector deviceConnector;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  @override
  void initState() {
    deviceNameController = TextEditingController();
    fetchData();
    if (!widget.scannerState.scanIsInProgress) {
      _startScanning();
      Timer(
          const Duration(seconds: 5), () {
        widget.stopScan();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.stopScan();
    deviceNameController.dispose();
    super.dispose();
  }

  void _startScanning() {
    final text = deviceNameController.text;
    widget.startScan(text.isEmpty ? [] : [Uuid.parse(text)]);
  }
  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await qrScan.FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, qrScan.ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = TKeys.failed.translate(context);
    }
    if (!mounted) return;

    setState(() {
      scanBarcode = barcodeScanRes;
    });
  }
  final localizationController = Get.find<LocalizationController>();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Stack(
          //   children: [
          //     ClipPath(
          //       clipper: WaveClipperTwo(reverse: false),
          //       child: Container(
          //         height: 150,
          //         color: Colors.grey.shade200,
          //       ),
          //     ),
          //     Column(
          //       children: [
          //         const SizedBox(height:25),
          //         Row(
          //           children: [
          //             const SizedBox(width:10,),
          //             ElevatedButton(
          //               onPressed: () {
          //                 localizationController.toggleLanguage('eng');
          //               },
          //               child: Text(TKeys.english.translate(context),style: const TextStyle(color: Colors.black),),
          //             ),
          //             const SizedBox(width:10,),
          //             ElevatedButton(
          //               onPressed: () {localizationController.toggleLanguage('ara');
          //               },
          //               child: Text(TKeys.arabic.translate(context),style: const TextStyle(color: Colors.black),),
          //             ),
          //             const SizedBox(width:10,),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          Expanded(
            child: Column(
              children: [
                // SizedBox(
                //   height: height * 0.25,
                //   child: Image.asset('images/logo.jpg'),
                // ),
                const SizedBox(height:20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10,),
                    Flexible(
                      child: Column(
                        children: [
                          const SizedBox(height:10,),
                          const Text("Available Devices to connect", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,),),
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: widget.scannerState.discoveredDevices
                                .where(
                                  (device) =>
                                      (device.name == scanBarcode || nameList.contains(device.name) || device.name == "MasterStation")
                                          && (device.name.isNotEmpty),
                                )
                                .map(
                                  (device) {
                                    meterName = device.name;
                                    if(device.name.startsWith('W')){
                                      paddingType = "Water";
                                    }
                                    else{
                                      paddingType = "Electricity";
                                    }
                                    return Padding(
                                      padding: EdgeInsets.symmetric(horizontal: width * .1),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          widget.stopScan();
                                          await widget.deviceConnector.connect(device.id);
                                          if (device.name == "MasterStation") {
                                            await Navigator.push<void>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => MasterInteractionTab(
                                                  device: device,
                                                  characteristic: QualifiedCharacteristic(
                                                    characteristicId: Uuid.parse(
                                                        "0000ffe1-0000-1000-8000-00805f9b34fb"),
                                                    serviceId: Uuid.parse(
                                                        "0000ffe0-0000-1000-8000-00805f9b34fb"),
                                                    deviceId: device.id,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          else {
                                            if(nameList.contains(device.name) == false){
                                              await sqlDb.insertData('''
                                                  INSERT OR IGNORE INTO Meters (`name`, `type`)
                                                  VALUES ("${device.name}","$paddingType")
                                                  ''');
                                            }
                                            await Navigator.push<void>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => DeviceInteractionTab(
                                                  device: device,
                                                  characteristic: QualifiedCharacteristic(
                                                    characteristicId: Uuid.parse(
                                                        "0000ffe1-0000-1000-8000-00805f9b34fb"),
                                                    serviceId: Uuid.parse(
                                                        "0000ffe0-0000-1000-8000-00805f9b34fb"),
                                                    deviceId: device.id,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          device.name,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: scanQR,
                          child: Text(
                            TKeys.qr.translate(context),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _startScanning,
                              child: const Text('Start',style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),),
                            ),
                            ElevatedButton(
                              onPressed: widget.stopScan,
                              child: const Text('Stop',style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 10,),
                  ],
                ),
              ],
            ),
          ),
          // ClipPath(
          //   clipper: WaveClipperTwo(reverse: true),
          //   child: Container(
          //     height: 150,
          //     color: Colors.grey.shade200,
          //   ),
          // ),
        ],
      ),
    );
  }
}
class Clip extends StatelessWidget {
  final bool direction;
  const Clip({required this.direction, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ClipPath(
      clipper: WaveClipperTwo(reverse: direction),
      child: Container(
        height: 150,
        color: Colors.grey.shade200,
      ),
    );
}

class DeviceLayout extends StatelessWidget {
  DeviceLayout({Key? key}) : super(key: key);
  final localizationController = Get.find<LocalizationController>();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.25,
      child: Image.asset('images/logo.jpg'),
    );
  }
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height:height,
        width: width,
        child: Column(
          children: [
            const Clip(direction: false,),
            SizedBox(
              height: height-300,
              width: width,
              child: Column(
                children: [
                  DeviceLayout(),
                  SizedBox(height:height*.4,child: const DeviceListScreen()),
                ],
              ),
            ),
            const Clip(direction: true,),
          ],
        ),
      ),
    );
  }
}
