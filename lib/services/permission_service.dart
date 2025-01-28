
import '../commons.dart';

class PermissionService {
  // Check and request Bluetooth permission
  Future<bool> checkBluetoothPermission() async {
    final status = await Permission.bluetooth.request();
    return status.isGranted;
  }

  // Check and request Location permission
  Future<bool> checkLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check and request Camera permission
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Check multiple permissions together
  Future<bool> checkAllPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.location,
      Permission.camera,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  // Open app settings if permissions are permanently denied
  Future<void> openAppSettings() async {
    if (!await Permission.bluetooth.isGranted ||
        !await Permission.location.isGranted ||
        !await Permission.camera.isGranted) {
      await openAppSettings();
    }
  }
}
