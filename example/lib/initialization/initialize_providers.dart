
import '../commons.dart';

/// Initializes providers for dependency injection
List<SingleChildWidget> initializeProviders(
    BleScanner scanner,
    BleStatusMonitor monitor,
    BleDeviceConnector connector,
    BleDeviceInteractor serviceDiscoverer,
    ) =>
    [
      Provider.value(value: scanner),
      Provider.value(value: monitor),
      Provider.value(value: connector),
      Provider.value(value: serviceDiscoverer),
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
      ChangeNotifierProvider(create: (_) => PermissionProvider()),
      StreamProvider<ConnectionStateUpdate>(
          create: (_) => connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
    ];