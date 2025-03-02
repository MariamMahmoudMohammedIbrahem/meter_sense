part of 'device_scanner_screen.dart';

abstract class DeviceScannerController extends State<DeviceScannerScreen> {


  late DateTime now;
  int index = 0;
  bool toggle = false; //english
  String icon = "assets/icons/masterStation.png";
  String barcodeScanRes = '';

  final characteristicId = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");
  final serviceId = Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb");

  final localizationController = Get.find<LocalizationController>();

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    for (var i = 0; i < 6; i++) {
      final previousMonth = DateTime(now.year, now.month - i, now.day);
      final formattedMonth = DateFormat.MMM().format(previousMonth);
      monthList.add(formattedMonth);
    }
    if (!widget.scannerState.scanIsInProgress) {
      _startScanning();
    }
  }

  void toggleLanguage(){
    localizationController.toggleLanguage();
    toggle = !toggle;
  }

  Future<void> barcodeScanning(BuildContext context) async {
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      if((barcodeScanRes.startsWith("EleMeter")&&barcodeScanRes.length==12)||(barcodeScanRes.startsWith("WMeter")&&barcodeScanRes.length==10)){
        await sqlDb.insertData('''
                                            INSERT OR IGNORE INTO Meters (`name`, `balance`, `tariff`)
                                            VALUES ("$barcodeScanRes", 0, 0)
                                            ''');
        /// insert meter into its specific table
        await insertMeter(barcodeScanRes);
      }
      _startScanning();
    } on PlatformException {
      barcodeScanRes = TKeys.failed.translate(context);
    }
    if (!mounted) return;
  }

  void _startScanning() {
    fetchData();
    widget.startScan([]);
    Timer(const Duration(seconds: 5), () {
      widget.stopScan();
    });
  }

  String getDeviceIcon(String name) {
    if (name.startsWith('W')) {
      return "assets/icons/waterMonth.png";
    } else if (name.startsWith('Ele')) {
      return "assets/icons/electricityMonth.png";
    }
    return "assets/icons/masterStation.png";
  }

  Future<void> handleDeviceTap(DiscoveredDevice device) async {
    meterName = device.name;

    if (device.name == "MasterStation") {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => ChargeCenter(
            device: device,
            characteristic: QualifiedCharacteristic(
              characteristicId: characteristicId,
              serviceId: serviceId,
              deviceId: device.id,
            ),
          ),
        ),
      ).then((_) => widget.deviceConnector.connect(device.id));
    } else {
      index = nameList.indexOf(device.name);
      await widget.deviceConnector.connect(device.id);
      await fetchData().then((_) {
        balanceCond = balanceList[index] == 1;
        tariffCond = tariffList[index] == 1;

        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceInteraction(
              device: device,
              characteristic: QualifiedCharacteristic(
                characteristicId: characteristicId,
                serviceId: serviceId,
                deviceId: device.id,
              ),
            ),
          ),
        );
      });
    }
  }

  void handleHistoryTap(String name){
    readMeterData(
      name,
    );
    meterName = "unKnown";
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            DeviceHistoryScreen(
              name: name,
            ),
      ),
    );
  }

  void _showOptions(BuildContext context, String meterName) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
          decoration: const BoxDecoration(
            color:Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Color(0xFF047424),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Color(0xFF047424),
                  ),
                ),
                onTap: () {
                  var meterType = "Water";
                  if(meterName.startsWith("Ele")){
                    meterType = "Electricity";
                  }
                  deleteMeter(meterName, meterType);
                  _startScanning();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.stopScan();
  }
}
