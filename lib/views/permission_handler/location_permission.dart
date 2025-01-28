import '../../commons.dart';

class LocationPermission extends StatelessWidget {
  final PermissionService _permissionService = PermissionService();

  LocationPermission({super.key});
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
              child: Image.asset('images/location.jpg'),
            ),
            ElevatedButton(
              onPressed: () async {
                bool hasPermission =
                    await _permissionService.checkLocationPermission();
                if (hasPermission) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoadingScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: MyColors.brown,
                  backgroundColor: MyColors.brown500, //replace with 855A2D
                  disabledForegroundColor: MyColors.brown600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text(
                TKeys.accessLocation.translate(context),
                style: TextStyle(color: MyColors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
