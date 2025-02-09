import '../../commons.dart';

class BleStatusMonitor implements ReactiveState<BleStatus?> {
  // const BleStatusMonitor(this._ble);

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  @override
  Stream<BleStatus?> get state => _ble.statusStream;
}
