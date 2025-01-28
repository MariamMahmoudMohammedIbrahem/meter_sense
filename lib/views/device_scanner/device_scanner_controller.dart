part of 'device_scanner_screen.dart';

abstract class DeviceScannerController extends State<DeviceScannerScreen> {
  /*late DateTime now;
  String barcodeScanRes = '';

  var monthList = <String>[];
  bool availability = false;

  final _bleScanner = BleScanner();
  final _bleScannerState = const BleScannerState(discoveredDevices: [], scanIsInProgress: false);
  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    for (var i = 0; i < 6; i++) {
      final previousMonth = DateTime(now.year, now.month - i, now.day);
      final formattedMonth = DateFormat.MMM().format(previousMonth);
      monthList.add(formattedMonth);
    }
    ///TODO: call fetchData()
    // fetchData();
    if (_bleScannerState.scanIsInProgress) {
      _startScanning();
      Timer(const Duration(seconds: 5), () {
        _bleScanner.stopScan();
        availability = true;
      });
    }
  }

  @override
  void dispose() {
    _bleScanner.stopScan();
    super.dispose();
  }

  void _startScanning() {
    _bleScanner.startScan([]);
  }

  Future<void> scanQR() async {
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = TKeys.failed.translate(context);
    }
    if (!mounted) return;
  }

  final localizationController = Get.find<LocalizationController>();*/
}