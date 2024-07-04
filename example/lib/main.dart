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
                color: Colors.grey,
                theme: ThemeData(
                  popupMenuTheme:  PopupMenuThemeData(
                    color: Colors.grey.shade100, // Default background color
                  ),
                  primaryColor: Colors.grey,
                  primarySwatch: Colors.grey,
                  scaffoldBackgroundColor: Colors.white,
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey[600],
                      shape: const StadiumBorder(),
                      disabledForegroundColor: Colors.grey.withOpacity(0.38),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                    ),
                  ),
                  textTheme: const TextTheme(
                    displayLarge: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
          } else if (permission.bluetoothStatus.isDenied) {
            permission.requestBluetoothPermission();
            return const BluetoothPermission();
          } else if (permission.whenInUseLocation.isDenied) {
            permission.requestLocationWhenInUse();
            return const LocationPermission();
          } else if (permission.cameraStatus.isDenied) {
            permission.requestCameraPermission();
            return const CameraPermission();
          } else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}
