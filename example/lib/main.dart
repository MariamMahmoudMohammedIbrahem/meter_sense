import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/localization_service.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_scanner.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_status_monitor.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/permissions/bluetooth_permission.dart';
import 'package:flutter_reactive_ble_example/src/permissions/camera_permission.dart';
import 'package:flutter_reactive_ble_example/src/permissions/location_permission.dart';
import 'package:flutter_reactive_ble_example/src/permissions/permission_provider.dart';
import 'package:flutter_reactive_ble_example/src/ui/ble_status_screen.dart';
import 'package:flutter_reactive_ble_example/src/ui/device_detail/device_list.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'src/ble/ble_logger.dart';


Future<void> main() async {
  final localizationController = Get.put(LocalizationController());
  locationWhenInUse = await Permission.locationWhenInUse.status;
  statusBluetoothConnect = await Permission.bluetoothConnect.status;
  statusCamera = await Permission.camera.status;
  WidgetsFlutterBinding.ensureInitialized();

  final ble = FlutterReactiveBle();
  final bleLogger = BleLogger(ble: ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final monitor = BleStatusMonitor(ble);
  final connector = BleDeviceConnector(
    ble: ble,
    logMessage: bleLogger.addToLog,
  );
  final serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: (deviceId) async {
      await ble.discoverAllServices(deviceId);
      return ble.getDiscoveredServices(deviceId);
    },
    readCharacteristic: ble.readCharacteristic,
    writeWithResponse: ble.writeCharacteristicWithResponse,
    writeWithOutResponse: ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: ble.subscribeToCharacteristic,
    logMessage: bleLogger.addToLog,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: scanner),
        Provider.value(value: monitor),
        Provider.value(value: connector),
        Provider.value(value: serviceDiscoverer),
        Provider.value(value: bleLogger),
        StreamProvider<BleScannerState?>(
          create: (_) => scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => monitor.state,
          initialData: BleStatus.unknown,
        ),
        ChangeNotifierProvider(
          create: (context) => PermissionProvider(),
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: GetBuilder<LocalizationController>(
          init: localizationController,
          builder: (LocalizationController controller) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'MeterSense',
                color: Colors.black,
                theme: ThemeData(
                  popupMenuTheme:  PopupMenuThemeData(
                    color: Colors.grey.shade100, // Default background color
                  ),
                  scaffoldBackgroundColor: Colors.white,
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4CAF50),
                      disabledBackgroundColor: Colors.black,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        // fontSize: 20,
                      ),
                      foregroundColor: Colors.black, // Add this line to set text color
                      disabledForegroundColor: const Color(0xff4CAF50),
                    ),
                  ),
                  textTheme: TextTheme(
                    displayLarge: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff4CAF50),
                    ),
                    displayMedium: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff4CAF50),
                    ),
                    displaySmall: const TextStyle(
                      // fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff4CAF50),
                    ),
                    titleMedium: const TextStyle(
                      // fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    titleSmall: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    bodyMedium: const TextStyle(
                      // fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    bodySmall: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade900,
                    ),
                    bodyLarge: const TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  dividerTheme: const DividerThemeData(
                    thickness: 1,
                    indent: 0,
                    endIndent: 10,
                    color: Color(0xff4CAF50),
                  ),
                ),
                locale: controller.currentLanguage != ''
                    ? Locale(controller.currentLanguage, '')
                    : null,
                localeResolutionCallback:
                    LocalizationService.localeResolutionCallBack,
                supportedLocales: LocalizationService.supportedLocales,
                localizationsDelegates:
                    LocalizationService.localizationsDelegate,
                home: const HomeScreen(),
              )),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
      Consumer2<BleStatus?, PermissionProvider>(
        builder: (_, status, permission, __) {
          if (status == BleStatus.ready &&
              permission.cameraStatus.isGranted &&
              permission.whenInUseLocation.isGranted &&
              permission.bluetoothStatus.isGranted) {
            return const MyApp();
          }
          else if (permission.bluetoothStatus.isDenied) {
            permission.requestBluetoothPermission();
            return const BluetoothPermission();
          }
          else if (permission.whenInUseLocation.isDenied) {
            permission.requestLocationWhenInUse();
            return const LocationPermission();
          }
          else if (permission.cameraStatus.isDenied) {
            permission.requestCameraPermission();
            return const CameraPermission();
          }
          else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}
