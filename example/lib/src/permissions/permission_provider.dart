
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ble/constants.dart';

class PermissionProvider extends ChangeNotifier {
  // Define the permissions you want to manage
  PermissionStatus _locationStatus = statusLocation;
  PermissionStatus _cameraStatus = statusCamera;

  // Getters for permission statuses
  PermissionStatus get locationStatus => _locationStatus;
  PermissionStatus get cameraStatus => _cameraStatus;

  // Function to request location permission
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.status;
    _locationStatus = status;
    notifyListeners();
  }

  // Function to request camera permission
  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.status;
    _cameraStatus = status;
    notifyListeners();
  }
}