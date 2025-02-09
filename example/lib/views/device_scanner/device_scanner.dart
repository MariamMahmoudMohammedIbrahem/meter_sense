import '../../commons.dart';

class DeviceScanner extends StatelessWidget {
  const DeviceScanner({super.key});

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleScanner, BleScannerState?, BleDeviceConnector>(
        builder: (_, bleScanner, bleScannerState, deviceConnector, __) =>
            DeviceScannerScreen(
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