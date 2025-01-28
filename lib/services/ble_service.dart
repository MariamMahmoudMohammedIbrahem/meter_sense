import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../commons.dart';
class BleScanner implements ReactiveState<BleScannerState> {
  // BleScanner({
  //   required FlutterReactiveBle ble,
    // required Function(String message) logMessage,
  // })  : _ble = ble;
        // _logMessage = logMessage;

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  // final void Function(String message) _logMessage;
  final StreamController<BleScannerState> _stateStreamController =
  StreamController();

  final _devices = <DiscoveredDevice>[];

  @override
  Stream<BleScannerState> get state => _stateStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds).listen((device) {
          final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
          if (knownDeviceIndex >= 0) {
            _devices[knownDeviceIndex] = device;
          } else {
            _devices.add(device);
            print('_devices $_devices');
          }
          _pushState();
        });
    _pushState();
  }

  void _pushState() {
    _stateStreamController.add(
      BleScannerState(
        discoveredDevices: _devices,
        scanIsInProgress: _subscription != null,
      ),
    );
  }

  Future<void> stopScan() async {

    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  /*Future<void> dispose() async {
    await _stateStreamController.close();
  }*/

  StreamSubscription? _subscription;
}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}

class BLEConnector implements ReactiveState<ConnectionStateUpdate>{

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  // ignore: cancel_subscriptions
  late StreamSubscription<ConnectionStateUpdate> _connection;

  Future<void> connect(String deviceId) async {
    _connection = _ble.connectToDevice(id: deviceId).listen(
          (update) {
        _deviceConnectionController.add(update);
      },);
  }

  Future<void> disconnect(String deviceId) async {
    try {
      await _connection.cancel();
    }  finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }
}

abstract class ReactiveState<T> {
  Stream<T> get state;
}