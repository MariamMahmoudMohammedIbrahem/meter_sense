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
  const DeviceList({
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.deviceConnector,
    super.key,
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
      Timer(const Duration(seconds: 5), () {
        widget.stopScan();
        availability = true;
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.green,
      //   foregroundColor: Colors.black,
      //   onPressed: () {
      //     sqlDb.mydeleteDatabase();
      //     eleMeters.clear();
      //     watMeter.clear();
      //   },
      //   child: Icon(Icons.add),
      // ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: scanQR,
                                child: Text(
                                  TKeys.qr.translate(context),
                                  style: TextStyle(
                                    color: Colors.green.shade50,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _startScanning();
                                  Timer(const Duration(seconds: 5), () {
                                    widget.stopScan();
                                  });
                                },
                                child: Text(
                                  !widget.scannerState.scanIsInProgress
                                      ? TKeys.scan.translate(context)
                                      : TKeys.scanning.translate(context),
                                  style: TextStyle(
                                    color: Colors.green.shade50,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * .1),
                            child: Visibility(
                              visible: availability,
                              child: Text(
                                nameList.isEmpty?TKeys.first.translate(context):TKeys.hint.translate(context),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                TKeys.device.translate(context),
                                style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    shadows: const [
                                      Shadow(
                                          color: Colors.grey,
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
                              color: Colors.grey.shade400,
                            ),
                          ),
                          ListView(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: widget.scannerState.discoveredDevices
                                .where(
                              (device) =>
                                  (device.name == scanBarcode ||
                                      nameList.contains(device.name) ||
                                      device.name == "MasterStation") &&
                                  (device.name.isNotEmpty),
                            )
                                .map((device) {
                              if (device.name.startsWith('W')) {
                                icon =  'icons/waterMonth.png';
                              }
                              else if(device.name.startsWith('Ele')){
                                icon = 'icons/electricityMonth.png';
                              }
                              else{
                                icon =  'icons/masterStation.png';
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * .1),
                                child: Column(
                                  children: [
                                    ListTile(
                                      onTap: () async {
                                        widget.stopScan();
                                        if(device.name.startsWith('W')){
                                          paddingType = 'Water';
                                        }
                                        else{
                                          paddingType = "Electricity";
                                        }
                                        meterName = device.name;
                                        if (device.name == "MasterStation") {
                                          await Navigator.push<void>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MasterInteractionTab(
                                                device: device,
                                                characteristic:
                                                    QualifiedCharacteristic(
                                                  characteristicId: Uuid.parse(
                                                      "0000ffe1-0000-1000-8000-00805f9b34fb"),
                                                  serviceId: Uuid.parse(
                                                      "0000ffe0-0000-1000-8000-00805f9b34fb"),
                                                  deviceId: device.id,
                                                ),
                                              ),
                                            ),
                                          ).then((value) => widget.deviceConnector
                                              .connect(device.id));
                                        } else {
                                          if (nameList.contains(device.name) ==
                                              false) {
                                            await sqlDb.insertData('''
                                                      INSERT OR IGNORE INTO Meters (`name`, `type`)
                                                      VALUES ("${device.name}","$paddingType")
                                                      ''');
                                          }
                                          await Navigator.push<void>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  DeviceInteractionTab(
                                                device: device,
                                                characteristic:
                                                    QualifiedCharacteristic(
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
                                      leading: SizedBox(
                                        width: 25,
                                        child: Image.asset(
                                          icon
                                        ),
                                      ),
                                      title: Text(
                                        device.name,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      indent: 0,
                                      endIndent: 10,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

class LanguageToggle extends StatefulWidget {
  const LanguageToggle({Key? key}) : super(key: key);

  @override
  State<LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<LanguageToggle> {
  final localizationController = Get.find<LocalizationController>();
  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(
            onPressed: () {
              if (!toggle) {
                localizationController.toggleLanguage('ara');
              } else {
                localizationController.toggleLanguage('eng');
              }
              toggle = !toggle;
            },
            icon: const Icon(Icons.language_outlined),
          ),
          Text(
            toggle
                ? TKeys.arabic.translate(context)
                : TKeys.english.translate(context),
          )
        ],
      );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          height: height,
          width: width,
          child: Column(
            children: [
              const LanguageToggle(),
              SizedBox(
                width: width * .7,
                child: Image.asset('images/authorize.jpg'),
              ),
              const Expanded( child: DeviceListScreen()),
              // const Clip(direction: true,),
            ],
          ),
        ),
      ),
    );
  }
}
