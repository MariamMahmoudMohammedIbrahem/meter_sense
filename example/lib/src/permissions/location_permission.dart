import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../t_key.dart';
import '../ble/constants.dart';
class LocationPermission extends StatefulWidget {
  const LocationPermission({super.key});

  @override
  State<LocationPermission> createState() => _LocationPermissionState();
}

class _LocationPermissionState extends State<LocationPermission> {
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
              child: Image.asset('images/location.jpg'),
            ),
            ElevatedButton(
              onPressed: _requestLocationPermission,
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade500, //replace with 855A2D
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(TKeys.accessLocation.translate(context),style: const TextStyle(color: Colors.white,fontSize: 18),),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _requestLocationPermission() async {
    if (locationWhenInUse.isDenied) {
      locationWhenInUse = await Permission.locationWhenInUse.request();
      if(locationWhenInUse.isGranted){
        await Fluttertoast.showToast(msg:'location granted');
      }
    }
  }
}