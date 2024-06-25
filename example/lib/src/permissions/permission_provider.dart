
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ble/constants.dart';

class PermissionProvider extends ChangeNotifier {
  // Define the permissions you want to manage
  PermissionStatus _locationWhenInUse = locationWhenInUse;
  PermissionStatus _cameraStatus = statusCamera;
  PermissionStatus _bluetoothStatus = statusBluetoothConnect;

  // Getters for permission statuses
  PermissionStatus get whenInUseLocation => _locationWhenInUse;
  PermissionStatus get cameraStatus => _cameraStatus;
  PermissionStatus get bluetoothStatus => _bluetoothStatus;

  // Function to request location permission
  Future<void> requestLocationWhenInUse() async {
    final status = await Permission.locationWhenInUse.status;
    _locationWhenInUse = status;
    notifyListeners();
  }

  // Function to request camera permission
  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.status;
    _cameraStatus = status;
    notifyListeners();
  }
  // Function to request bluetooth permission
  Future<void> requestBluetoothPermission() async {
    final status = await Permission.bluetoothConnect.status;
    _bluetoothStatus = status;
    notifyListeners();
  }
}