
import '../commons.dart';

class MeterSense extends StatelessWidget {
  const MeterSense({super.key});

  @override
  Widget build(BuildContext context) => Consumer2<BleStatus?, PermissionProvider>(
    builder: (_, status, permission, __) {
      if (_hasAllPermissionsGranted(status, permission)) {
        return const DeviceScanner();
      }

      return _handlePermissionScreen(permission);
    },
  );

  /// Checks if all required permissions are granted
  bool _hasAllPermissionsGranted(BleStatus? status, PermissionProvider permission) => status == BleStatus.ready &&
      permission.cameraStatus.isGranted &&
      permission.whenInUseLocation.isGranted &&
      permission.bluetoothStatus.isGranted;

  /// Determines which permission screen to show
  Widget _handlePermissionScreen(PermissionProvider permission) {
    if (_isBluetoothDenied(permission)) {
      permission.requestBluetoothPermission();
      return const BluetoothPermission();
    }

    if (_isLocationDenied(permission)) {
      permission.requestLocationWhenInUse();
      return const LocationPermission();
    }

    if (_isCameraDenied(permission)) {
      permission.requestCameraPermission();
      return const CameraPermission();
    }

    return const BleStatusScreen(status: BleStatus.unknown);
  }

  /// Checks if Bluetooth permission is denied
  bool _isBluetoothDenied(PermissionProvider permission) => permission.bluetoothStatus.isDenied || permission.bluetoothStatus.isPermanentlyDenied;

  /// Checks if Location permission is denied
  bool _isLocationDenied(PermissionProvider permission) => permission.whenInUseLocation.isDenied || permission.whenInUseLocation.isPermanentlyDenied;

  /// Checks if Camera permission is denied
  bool _isCameraDenied(PermissionProvider permission) => permission.cameraStatus.isDenied || permission.cameraStatus.isPermanentlyDenied;
}