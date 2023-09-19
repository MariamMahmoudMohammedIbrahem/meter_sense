import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_scanner.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ui/master/master_station.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import '../../ble/ble_logger.dart';
import '../../ble/functions.dart';
// import 'device_detail_screen.dart';
import 'device_interaction_tab.dart';

part 'device_list.g.dart';
//ignore_for_file: annotate_overrides


class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer4<BleScanner, BleScannerState?, BleLogger,BleDeviceConnector>(
        builder: (_, bleScanner, bleScannerState, bleLogger, deviceConnector, __) => DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: deviceConnector ,
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
  DeviceList({
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.deviceConnector,
    // required this.viewModel,
  });

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final BleDeviceConnector  deviceConnector;
  // final DeviceInteractionViewModel viewModel;

  @override
  _DeviceListState createState() => _DeviceListState();


}

class _DeviceListState extends State<DeviceList> {
  late TextEditingController _uuidController;

  @override
  void initState() {
    super.initState();
    _uuidController = TextEditingController()..addListener(() => setState(() {}));
    fetchData();
    _handleScanButtonPress();
  }

  @override
  void dispose() {
    widget.stopScan();
    _uuidController.dispose();
    super.dispose();
  }
  // bool _isValidUuidInput() {
  //   final uuidText = _uuidController.text;
  //   if (uuidText.isEmpty) {
  //     return true;
  //   } else {
  //     try {
  //       Uuid.parse(uuidText);
  //       return true;
  //     } on Exception {
  //       return false;
  //     }
  //   }
  // }

  void _startScanning() {
    final text = _uuidController.text;
    widget.startScan(text.isEmpty ? [] : [Uuid.parse(_uuidController.text)]);
  }

  void _handleScanButtonPress() {
    if (!widget.scannerState.scanIsInProgress ) {
      _startScanning();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 150,
              color: Colors.grey.shade200,
            ),
          ),
          Expanded(
            child:Column(
              children: [
                SizedBox(
                  // width:width,
                  height: height*.25,
                  child: Image.asset('images/logo.jpg'),
                ),
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 1,
                      ),
                      Row(
                        children: [
                          Radio<int>(
                              value: 1,
                              groupValue: valU,
                              onChanged: (value){
                                setState(() {
                                  valU = value!;
                                  type = 'Electricity';
                                });
                              }
                          ),
                          Text(
                            'Electricity',
                            style: TextStyle(
                                fontSize: 17.0,
                                color:Colors.grey.shade800
                            ),),
                        ],
                      ),
                      const SizedBox(width: 30),
                      Row(
                        children: [
                          Radio<int>(
                              value: 2,
                              groupValue: valU,
                              onChanged: (value){
                                setState(() {
                                  valU = value!;
                                  type = 'Water';
                                });
                              }
                          ),
                          Text(
                            'Water',
                            style: TextStyle(
                                fontSize: 17.0,
                                color:Colors.grey.shade800
                            ),),
                        ],
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: width*.5,
                      child: TextField(
                        controller: deviceName,
                        // onChanged: (value) {
                        //   if (valU == 1){
                        //     electricSN = value;
                        //   }else if (valU == 2){
                        //     waterSN = value;
                        //   }
                        // },
                        decoration: InputDecoration(
                          border:  UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade200)
                          ),
                          labelText: 'Device Name',
                          floatingLabelStyle:
                          MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                            final Color color = states.contains(MaterialState.error)
                                ? Theme.of(context).colorScheme.error
                                : Colors.brown.shade900;
                            return TextStyle(color: color, letterSpacing: 1.3);
                          }),
                          labelStyle:
                          MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                            final Color color = states.contains(MaterialState.error)
                                ? Theme.of(context).colorScheme.error
                                : Colors.brown.shade800;
                            return TextStyle(color: color, letterSpacing: 1.3);
                          }),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade100,
                      ),
                      onPressed: (){},
                      child: const Text("QR Scanning",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: widget.scannerState.discoveredDevices
                        .map(
                          (device) {
                        if (device.name == deviceName.text && deviceName.text != "" || device.name == name|| device.name == "MasterStation") {
                          if(deviceName.text == "MasterStation" || device.name == "MasterStation"){
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade100,
                              ),
                              onPressed: isDeviceFound
                                  ? () async {
                                widget.stopScan();
                                await widget.deviceConnector.connect(device.id);
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const MasterStation(),
                                  ),
                                ).then((value) => deviceName.clear(),);
                              }
                                  : null,
                              child: Text(device.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),),
                            );
                          }
                          else if(device.name == name ){
                            isDeviceFound = true;
                            id = device.id;
                            return Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    backgroundColor: Colors.grey.shade200,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey.shade100,
                                  ),
                                  onPressed: isDeviceFound
                                      ? () async {
                                    widget.stopScan();
                                    await widget.deviceConnector.connect(device.id);
                                    dataStored = device;
                                    paddingType = meterType.toString();
                                    meterName = device.name;
                                    await Navigator.push<void>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DeviceInteractionTab(
                                              device: device, characteristic: QualifiedCharacteristic(
                                                characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                                                serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                                                deviceId: device.id),
                                            ),
                                      ),
                                    ).then((value) => deviceName.clear(),);
                                  }
                                      : null,
                                  child: Text(device.name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                                ),
                              ],
                            );
                          }
                          else {
                            isDeviceFound = true;
                            id = device.id;
                            count = 1;
                            return Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    backgroundColor: Colors.grey.shade200,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey.shade100,
                                  ),
                                  onPressed: isDeviceFound
                                      ? () async {
                                    widget.stopScan();
                                    await widget.deviceConnector.connect(device.id);
                                    dataStored = device;
                                    meterTable = await sqlDb.insertData(
                                        '''
                                        INSERT OR IGNORE INTO Meters (`name`, `type`)
                                        VALUES ("${device.name}","$type")
                                        '''
                                    );
                                    if (valU == 1){
                                      electricSN = device.name;
                                    }else if (valU == 2){
                                      waterSN = device.name;
                                    }
                                    paddingType = meterType.toString();
                                    meterName = device.name;
                                    // count = await sqlDb.getMetersTableLength();
                                    // print("count$count");
                                    await Navigator.push<void>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DeviceInteractionTab(
                                              device: device, characteristic: QualifiedCharacteristic(
                                                characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                                                serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                                                deviceId: device.id),
                                            ),
                                      ),
                                    ).then((value) => deviceName.clear(),);
                                  }
                                      : null,
                                  child: Text(device.name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                                ),
                              ],
                            );
                          }

                        }
                        else {
                          return const SizedBox.shrink();
                        }
                      },
                    )
                        .toList(),
                  ),
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
class WaveClipper extends CustomClipper<Path> {
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