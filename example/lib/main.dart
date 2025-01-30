
import 'commons.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Localization Controller
  final localizationController = Get.put(LocalizationController());/*
  locationWhenInUse = await Permission.locationWhenInUse.status;
  statusBluetoothConnect = await Permission.bluetoothConnect.status;
  statusCamera = await Permission.camera.status;*/
  // Request permissions
  await initializePermissions();

  final bleServices = initializeBleServices();
  runApp(
    MultiProvider(
      providers: initializeProviders(
          bleServices['scanner'] as BleScanner,
          bleServices['monitor'] as BleStatusMonitor,
          bleServices['connector'] as BleDeviceConnector,
          bleServices['serviceDiscoverer'] as BleDeviceInteractor,
        ),
      child: GetBuilder<LocalizationController>(
        init: localizationController,
        builder: _buildApp,
      ),
    ),
  );


  /*WidgetsFlutterBinding.ensureInitialized();

  // Initialize Localization Controller
  final localizationController = Get.put(LocalizationController());

  // Request permissions
  await initializePermissions();

  // Initialize BLE services
  final bleServices = initializeBleServices();

  // Run the application
  runApp(
    MultiProvider(
      providers: initializeProviders(
        bleServices['scanner'] as BleScanner,
        bleServices['monitor'] as BleStatusMonitor,
        bleServices['connector'] as BleDeviceConnector,
        bleServices['serviceDiscoverer'] as BleDeviceInteractor,
      ),
      child: GetBuilder<LocalizationController>(
        init: localizationController,
        builder: _buildApp,
      ),
    ),
  );*/

}

/// Builds the main application widget
Widget _buildApp(LocalizationController controller) => MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'MeterSense',
  color: Colors.black,
  theme: lightTheme,
  locale: controller.currentLanguage.isNotEmpty
      ? Locale(controller.currentLanguage, '')
      : null,
  localeResolutionCallback: LocalizationService.localeResolutionCallBack,
  supportedLocales: LocalizationService.supportedLocales,
  localizationsDelegates: LocalizationService.localizationsDelegate,
  home: const MeterSense(),
);
