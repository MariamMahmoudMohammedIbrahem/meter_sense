
import 'commons.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize Localization Controller
  final localizationController = Get.put(LocalizationController());

  // initialize permissions
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
}

/// Builds the main application widget
Widget _buildApp(LocalizationController controller) => MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Meter Sense',
  color: Colors.black,
  theme: lightTheme,
  locale: controller.currentLanguage.isNotEmpty
      ? Locale(controller.currentLanguage.string, '')
      : null,
  localeResolutionCallback: LocalizationService.localeResolutionCallBack,
  supportedLocales: LocalizationService.supportedLocales,
  localizationsDelegates: LocalizationService.localizationsDelegate,
  home: const MeterSense(),
);
