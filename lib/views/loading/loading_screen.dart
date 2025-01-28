import 'package:meter_sense/views/device_scanner/device_scanner_screen.dart';

import '../../commons.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
    );
    _checkPermissions();
  }

  void _checkPermissions() {
    _permissionService.checkAllPermissions().then((granted) {
      if (granted) {
        // Navigate to the main screen if all permissions are granted
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DeviceScannerScreen(),
          ),
        );
      } else {
        // Show a dialog or message if permissions are not granted
        _showPermissionDeniedDialog();
      }
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'To use the app, please grant all required permissions. \nYou may need to open the app settings to grant them',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _checkPermissions(); // Retry permission check
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.refresh_rounded),
        ],
      ),
    );
  }
}
