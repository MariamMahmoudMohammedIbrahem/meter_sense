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
  // void _showDialog(BuildContext context) {
  //   showDialog<String>(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //         title: Text(TKeys.device.translate(context)),
  //         content: SizedBox(
  //           height: 200,
  //           child: Column(
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   const SizedBox(width: 1),
  //                   Radio<int>(
  //                     value: 1,
  //                     groupValue: valU,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         valU = value!;
  //                         type = 'Electricity';
  //                       });
  //                     },
  //                   ),
  //                   Text(
  //                     TKeys.electricity.translate(context),
  //                     style: TextStyle(
  //                       fontSize: 17.0,
  //                       color: Colors.grey.shade800,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 30),
  //                   Radio<int>(
  //                     value: 2,
  //                     groupValue: valU,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         valU = value!;
  //                         type = 'Water';
  //                       });
  //                     },
  //                   ),
  //                   Text(
  //                     TKeys.water.translate(context),
  //                     style: TextStyle(
  //                       fontSize: 17.0,
  //                       color: Colors.grey.shade800,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 1),
  //                 ],
  //               ),
  //               TextField(
  //                 controller: deviceNameController,
  //                 decoration: InputDecoration(
  //                   border: UnderlineInputBorder(
  //                     borderSide: BorderSide(
  //                       color: Colors.grey.shade200,
  //                     ),
  //                   ),
  //                   labelText: TKeys.name.translate(context),
  //                   floatingLabelStyle: MaterialStateTextStyle.resolveWith(
  //                         (Set<MaterialState> states) {
  //                       final color = states.contains(MaterialState.error)
  //                           ? Theme.of(context).colorScheme.error
  //                           : Colors.brown.shade900;
  //                       return TextStyle(
  //                         color: color,
  //                         letterSpacing: 1.3,
  //                       );
  //                     },
  //                   ),
  //                   labelStyle: MaterialStateTextStyle.resolveWith(
  //                         (Set<MaterialState> states) {
  //                       final color = states.contains(MaterialState.error)
  //                           ? Theme.of(context).colorScheme.error
  //                           : Colors.brown.shade800;
  //                       return TextStyle(
  //                         color: color,
  //                         letterSpacing: 1.3,
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //             child: Text(TKeys.close.translate(context)),
  //           ),
  //         ],
  //       ),
  //   );
  // }

  @override
  void initState() {
    deviceNameController = TextEditingController();
    fetchData();
    if (!widget.scannerState.scanIsInProgress) {
      _startScanning();
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.stopScan();
    deviceNameController.dispose();
    // valU = -1;
    super.dispose();
  }

  void _startScanning() {
    final text = deviceNameController.text;
    widget.startScan(text.isEmpty ? [] : [Uuid.parse(text)]);
  }
  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await qrScan.FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, qrScan.ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = TKeys.failed.translate(context);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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
    // final deviceNameText = deviceNameController.text;
    // final isMasterStation = deviceNameText == "MasterStation";
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: WaveClipperTwo(reverse: false),
                child: Container(
                  height: 150,
                  color: Colors.grey.shade200,
                ),
              ),
              Column(
                children: [
                  const SizedBox(height:25),
                  Row(
                    children: [
                      const SizedBox(width:10,),
                      ElevatedButton(
                        onPressed: () {
                          localizationController.toggleLanguage('eng');
                        },
                        child: Text(TKeys.english.translate(context),style: const TextStyle(color: Colors.black),),
                      ),
                      const SizedBox(width:10,),
                      ElevatedButton(
                        onPressed: () {localizationController.toggleLanguage('ara');// Add your button 2 functionality here
                        },
                        child: Text(TKeys.arabic.translate(context),style: const TextStyle(color: Colors.black),),
                      ),
                      const SizedBox(width:10,),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.25,
                  child: Image.asset('images/logo.jpg'),
                ),
                const SizedBox(height:20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     // ElevatedButton(
                //     //     onPressed: () {
                //     //       _showDialog(context);
                //     //     },
                //     //     child: Text(
                //     //       TKeys.device.translate(context),
                //     //       // 'Add New Device',
                //     //       style: const TextStyle(
                //     //         color: Colors.black,
                //     //         fontWeight: FontWeight.bold,
                //     //         fontSize: 16,
                //     //       ),
                //     //     )),
                //     ElevatedButton(
                //       onPressed: scanQR,
                //       child: Text(
                //         TKeys.qr.translate(context),
                //         style: const TextStyle(
                //           color: Colors.black,
                //           fontWeight: FontWeight.bold,
                //           fontSize: 16,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
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
                                  (device) => Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: width * .1),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        widget.stopScan();
                                        await widget.deviceConnector.connect(device.id);
                                        // valU = -1;
                                        if (device.name == "MasterStation") {
                                          // DEVID = device.id;
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
                                              // .then(
                                              // (value) => deviceNameController.clear());
                                        }
                                        else {
                                          if(device.name.startsWith('W')){
                                            paddingType = "Water";
                                            // type = "Water";
                                          }
                                          else{
                                            paddingType = "Electricity";
                                            // type = "Electricity";
                                          }
                                          // dataStored = device;
                                          meterName = device.name;
                                          await sqlDb.insertData('''
                                                  INSERT OR IGNORE INTO Meters (`name`, `type`)
                                                  VALUES ("${device.name}","$paddingType")
                                                  ''');
                                          // for (int i = 0; i < nameList.length; i++) {
                                          //   if (nameList[i] == device.name) {
                                          //     paddingType = typeList[i];
                                          //   }
                                          // }
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
                                          //     .then(
                                          //     (value) => deviceNameController.clear());
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
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10,),
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
                    const SizedBox(width: 10,),
                  ],
                ),
              ],
            ),
          ),
          ClipPath(
            clipper: WaveClipperTwo(reverse: true),
            child: Container(
              height: 150,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }
}
// wave clipper shape
/* class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height);
    var firstStart = Offset(size.width / 5, size.height);
    //first point of quadratic bezier curve
    var firstEnd = Offset(size.width / 2.25, size.height - 50.0);
    //second point of quadratic bezier curve
    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);
    var secondStart =
        Offset(size.width - (size.width / 3.24), size.height - 105);
    //third point of quadratic bezier curve
    var secondEnd = Offset(size.width, size.height - 10);
    //fourth point of quadratic bezier curve
    path.quadraticBezierTo(
        secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
// @override
// dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
*/