import '../../commons.dart';

part 'device_scanner_controller.dart';

class DeviceScannerScreen extends StatefulWidget {
  const DeviceScannerScreen({super.key});

  @override
  createState() => _DeviceScannerScreen();
}

class _DeviceScannerScreen extends DeviceScannerController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                BleScanner().startScan([]);
              },
              child: const Text('scan for devices'),
            )
          ],
        ),
      ),
    );
  }
}
