
import 'package:meter_sense/views/permission_handler/location_permission.dart';

import '../../commons.dart';

class BluetoothPermission extends StatelessWidget {
  final PermissionService _permissionService = PermissionService();

  BluetoothPermission({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: width,
              child: Image.asset('images/bluetooth.jpg'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.12),
              child: const Text(
                'We will need your Bluetooth to be able to scan for the device',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                bool hasPermission =
                await _permissionService.checkBluetoothPermission();
                if (hasPermission) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationPermission(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: MyColors.brown,
                  backgroundColor: MyColors.brown500,
                  disabledForegroundColor: MyColors.brown600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text(
                TKeys.accessBluetooth.translate(context),
                style: TextStyle(color: MyColors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

}