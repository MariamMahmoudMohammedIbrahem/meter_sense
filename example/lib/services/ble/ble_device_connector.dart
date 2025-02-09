import '../../commons.dart';

class BleDeviceConnector extends ReactiveState<ConnectionStateUpdate> {
  // BleDeviceConnector({
  //   required FlutterReactiveBle ble,
  // })  : _ble = ble;

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  // ignore: cancel_subscriptions
  late StreamSubscription<ConnectionStateUpdate> _connection;

  Future<void> connect(String deviceId) async {
    _connection = _ble.connectToDevice(id: deviceId).listen(
      _deviceConnectionController.add
    );
  }

  Future<void> disconnect(String deviceId) async {
    try {
      await _connection.cancel();
    } finally {
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

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}
