import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../t_key.dart';
import '../ble/constants.dart';

class CameraPermission extends StatefulWidget {
  const CameraPermission({super.key});

  @override
  State<CameraPermission> createState() => _BluetoothPermissionState();
}

class _BluetoothPermissionState extends State<CameraPermission> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: width,
              child: Image.asset('images/bluetooth.jpg'),///ToDo: edit image to be camera not bluetooth
            ),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade600,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(TKeys.accessCamera.translate(context),style: const TextStyle(color: Colors.white,fontSize: 18),),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _requestCameraPermission() async {
    if(statusCamera.isDenied||statusCamera.isPermanentlyDenied){
      statusCamera = await Permission.camera.request();
      if(statusCamera.isGranted){
        // statusCamera = PermissionStatus.granted;
        await Fluttertoast.showToast(msg: 'camera granted');
      }
    }
  }
}