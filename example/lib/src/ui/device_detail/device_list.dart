//ignore_for_file: annotate_overrides

import '../../../commons.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleScanner, BleScannerState?, BleDeviceConnector>(
        builder: (_, bleScanner, bleScannerState, deviceConnector, __) =>
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

// @immutable
@FunctionalData()
class DeviceViewModel extends $DeviceInteractionViewModel {
  const DeviceViewModel({
    required this.deviceId,
    required this.deviceConnector,
    required this.discoverServices,
  });

  final String deviceId;
  final BleDeviceConnector deviceConnector;
  @CustomEquality(Ignore())
  final Future<List<Service>> Function() discoverServices;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }

  @override
  Connectable get connectableStatus => throw UnimplementedError();

  @override
  DeviceConnectionState get connectionStatus => throw UnimplementedError();
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
  DeviceListState createState() => DeviceListState();
}

class DeviceListState extends State<DeviceList> {
  @override
  void initState() {
    now = DateTime.now();
    for (var i = 0; i < 6; i++) {
      final previousMonth = DateTime(now.year, now.month - i, now.day);
      final formattedMonth = DateFormat.MMM().format(previousMonth);
      monthList.add(formattedMonth);
    }
    // setState(() {
      fetchData();
    // });
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
    super.dispose();
  }

  void _startScanning() {
    widget.startScan([]);
  }

  Future<void> scanQR(BuildContext context) async {
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = TKeys.failed.translate(context);
    }
    if (!mounted) return;
  }

  final localizationController = Get.find<LocalizationController>();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  scanQR(context).then((value) async {
                    if(barcodeScanRes.startsWith('EleMeter')||barcodeScanRes.startsWith('WMeter')){
                      await sqlDb.insertData('''
                                          INSERT OR IGNORE INTO Meters (`name`, `balance`, `tariff`)
                                          VALUES ("$barcodeScanRes", 0, 0)
                                          ''');
                    }
                    _startScanning();
                    Timer(const Duration(seconds: 5), () {
                      widget.stopScan();
                      fetchData();
                    });
                  });
                },
                child: AutoSizeText(
                  TKeys.qr.translate(context),
                  minFontSize: 18,
                  maxFontSize: 20,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _startScanning();
                  Timer(const Duration(seconds: 5), () {
                    widget.stopScan();
                    fetchData();
                  });
                },
                child: AutoSizeText(
                  !widget.scannerState.scanIsInProgress
                      ? TKeys.scan.translate(context)
                      : TKeys.scanning.translate(context),
                  minFontSize: 18,
                    maxFontSize: 20,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  TKeys.device.translate(context),
                  style:
                      Theme.of(context).textTheme.displayLarge,
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: width * .07,
              right: width * .07,
            ),
            child: const Divider(
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...widget.scannerState.discoveredDevices
                        .where(
                      (device) =>
                          (device.name == barcodeScanRes ||
                              nameList.contains(device.name) ||
                              device.name == "MasterStation") &&
                          (device.name.isNotEmpty),
                    )
                        .map((device) {
                      if (device.name.startsWith('W')) {
                        icon = 'assets/icons/waterMonth.png';
                      } else if (device.name.startsWith('Ele')) {
                        icon = 'assets/icons/electricityMonth.png';
                      } else {
                        icon = 'assets/icons/masterStation.png';
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * .1),
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () async {
                                if (device.name.startsWith('W')) {
                                  paddingType = 'Water';
                                } else {
                                  paddingType = "Electricity";
                                }
                                meterName = device.name;
                                if (device.name ==
                                    "MasterStation") {
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
                                  ).then((value) => widget
                                      .deviceConnector
                                      .connect(device.id));
                                } else {
                                  // if (nameList
                                  //         .contains(device.name) ==
                                  //     false) {
                                  //   await sqlDb.insertData('''
                                  //       INSERT OR IGNORE INTO Meters (`name`, `balance`, `tarrif`)
                                  //       VALUES ("${device.name}", 0, 0)
                                  //       ''');
                                  // } else {
                                    index = nameList
                                        .indexOf(device.name);
                                  // }
                                  await widget.deviceConnector
                                      .connect(device.id);
                                  await fetchData().then((value) {
                                    setState(() {
                                      balanceCond =
                                          balanceList[index] == 1;
                                      tariffCond =
                                          tariffList[index] == 1;
                                    });
                                    Navigator.push<void>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DeviceInteractionTab(
                                          device: device,
                                          characteristic:
                                              QualifiedCharacteristic(
                                            characteristicId:
                                                Uuid.parse(
                                                    "0000ffe1-0000-1000-8000-00805f9b34fb"),
                                            serviceId: Uuid.parse(
                                                "0000ffe0-0000-1000-8000-00805f9b34fb"),
                                            deviceId: device.id,
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                }
                              },
                              leading: SizedBox(
                                width: 30,
                                child: Image.asset(icon),
                              ),
                              title: AutoSizeText(
                                device.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium,
                                minFontSize: 20,
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    }),
                    ...nameList
                        .where((name) => !widget
                            .scannerState.discoveredDevices
                            .any((device) => device.name == name))
                        .map((name) {
                      if (name.startsWith('W')) {
                        icon = 'assets/icons/waterMonth.png';
                      } else if (name.startsWith('Ele')) {
                        icon = 'assets/icons/electricityMonth.png';
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * .1,
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: SizedBox(
                                width: 25,
                                child: Image.asset(icon),
                              ),
                              title: AutoSizeText(
                                name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                              trailing: const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                              onTap: () {
                                sqlDb.readMeterData(
                                  name,
                                );
                                meterName = 'unKnown';
                                if (name.startsWith('W')) {
                                  paddingType = 'Water';
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          WaterData(
                                        name: name,
                                      ),
                                    ),
                                  );
                                } else {
                                  // setState(() {
                                  //   sqlDb.editingList(name);
                                  // });
                                  paddingType = "Electricity";
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          StoreData(
                                        name: name,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    }),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageToggle extends StatefulWidget {
  const LanguageToggle({super.key});

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
            icon: const Icon(
              Icons.language_outlined,
              color: Colors.black,
              size: 30,
            ),
          ),
          AutoSizeText(
            toggle
                ? TKeys.arabic.translate(context)
                : TKeys.english.translate(context),
            style: Theme.of(context).textTheme.bodyMedium,
            minFontSize: 18,
            maxFontSize: 20,
          )
        ],
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                width: width * .6,
                height: height*.35,
                child: Image.asset('assets/images/authorize.jpg'),
              ),
              const Expanded(child: DeviceListScreen()),
            ],
          ),
        ),
      ),
    );
  }
}
