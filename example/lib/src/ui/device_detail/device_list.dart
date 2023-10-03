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
  });

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final BleDeviceConnector deviceConnector;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  late TextEditingController _deviceNameController;

  @override
  void initState() {
    _deviceNameController = TextEditingController();
    fetchData();
    if (!widget.scannerState.scanIsInProgress) {
      _startScanning();
    }
    // final myInstance = SqlDb(); // Creating an instanc// e of MyClass
    // myInstance.getList();
    super.initState();
  }

  @override
  void dispose() {
    widget.stopScan();
    _deviceNameController.dispose();
    super.dispose();
  }

  void _startScanning() {
    final text = _deviceNameController.text;
    widget.startScan(text.isEmpty ? [] : [Uuid.parse(text)]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final deviceNameText = _deviceNameController.text;
    // final isMasterStation = deviceNameText == "MasterStation";
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.25,
                  child: Image.asset('images/logo.jpg'),
                ),
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 1),
                      Radio<int>(
                        value: 1,
                        groupValue: valU,
                        onChanged: (value) {
                          setState(() {
                            valU = value!;
                            type = 'Electricity';
                          });
                        },
                      ),
                      Text(
                        'Electricity',
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Radio<int>(
                        value: 2,
                        groupValue: valU,
                        onChanged: (value) {
                          setState(() {
                            valU = value!;
                            type = 'Water';
                          });
                        },
                      ),
                      Text(
                        'Water',
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 1),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: width * 0.5,
                      child: TextField(
                        controller: _deviceNameController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          labelText: 'Device Name',
                          floatingLabelStyle:
                          MaterialStateTextStyle.resolveWith(
                                (Set<MaterialState> states) {
                              final color =
                              states.contains(MaterialState.error)
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.brown.shade900;
                              return TextStyle(
                                color: color,
                                letterSpacing: 1.3,
                              );
                            },
                          ),
                          labelStyle:
                          MaterialStateTextStyle.resolveWith(
                                (Set<MaterialState> states) {
                              final color =
                              states.contains(MaterialState.error)
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.brown.shade800;
                              return TextStyle(
                                color: color,
                                letterSpacing: 1.3,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        var list3 = addBytesAndHex([0,2,15,200], [0,0,0,2]);
                        num result2 = convertToInt(list3, 0, 4);
                        print('res2 : $result2');

                      },
                      child: const Text(
                        "QR Scanning",
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
                    children: widget.scannerState.discoveredDevices.where((device)=>

                      (device.name == deviceNameText || device.name == name || device.name == "MasterStation") &&
                          (device.name != ""  ) ,
                    )
                        .map(
                          (device) => ElevatedButton(
                            onPressed: () async {
                              widget.stopScan();
                              await widget.deviceConnector.connect(device.id);
                              if (device.name == "MasterStation") {
                                DEVID = device.id;
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MasterInteractionTab(
                                      device: device,
                                      characteristic: QualifiedCharacteristic(
                                        //untill know the caharcteristic and service id
                                        characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                                        serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                                    deviceId: device.id,
                                  ),

                                    ),
                                  ),
                                ).then((value) => _deviceNameController.clear());
                              }
                              else {
                                dataStored = device;
                                meterName = device.name;
                                meterTable = await sqlDb.insertData(
                                    '''
                                        INSERT OR IGNORE INTO Meters (`name`, `type`)
                                        VALUES ("${device.name}","$type")
                                        '''
                                );
                                paddingType = meterType.toString();
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DeviceInteractionTab(
                                      device: device,
                                      characteristic: QualifiedCharacteristic(
                                        characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                                        serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                                        deviceId: device.id,
                                      ),
                                    ),
                                  ),
                                ).then((value) => _deviceNameController.clear());
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