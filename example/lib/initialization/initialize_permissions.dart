import '../commons.dart';

/// Requests required permissions
Future<void> initializePermissions() async {
  locationWhenInUse = await Permission.locationWhenInUse.status;
  statusBluetoothConnect = await Permission.bluetoothConnect.status;
  statusCamera = await Permission.camera.status;
}