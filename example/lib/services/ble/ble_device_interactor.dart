import '../../commons.dart';

class BleDeviceInteractor {
  BleDeviceInteractor({
    required Future<List<Service>> Function(String deviceId)
    bleDiscoverServices,
    required Future<List<int>> Function(QualifiedCharacteristic characteristic)
    readCharacteristic,
    required Future<void> Function(QualifiedCharacteristic characteristic,
        {required List<int> value})
    writeWithResponse,
    required Future<void> Function(QualifiedCharacteristic characteristic,
        {required List<int> value})
    writeWithOutResponse,
    required Stream<List<int>> Function(QualifiedCharacteristic characteristic)
    subscribeToCharacteristic,
  })  : _bleDiscoverServices = bleDiscoverServices,
        _readCharacteristic = readCharacteristic,
        _writeWithResponse = writeWithResponse,
        _writeWithoutResponse = writeWithOutResponse,
        _subScribeToCharacteristic = subscribeToCharacteristic;

  final Future<List<Service>> Function(String deviceId)
  _bleDiscoverServices;

  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
  _readCharacteristic;

  final Future<void> Function(QualifiedCharacteristic characteristic,
      {required List<int> value}) _writeWithResponse;

  final Future<void> Function(QualifiedCharacteristic characteristic,
      {required List<int> value}) _writeWithoutResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
  _subScribeToCharacteristic;


  Future<List<Service>> discoverServices(String deviceId) async {
    try {
      final result = await _bleDiscoverServices(deviceId);
      return result;
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<List<int>> readCharacteristic(
      QualifiedCharacteristic characteristic) async {
    try {
      final result = await _readCharacteristic(characteristic);

      return result;
    } on Exception catch (e, s) {
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Future<void> writeCharacteristicWithResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      await _writeWithResponse(characteristic, value: value);

    } on Exception catch (e, s) {
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Future<void> writeCharacteristicWithoutResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      await _writeWithoutResponse(characteristic, value: value);
    } on Exception catch (e, s) {
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Stream<List<int>> subScribeToCharacteristic(
      QualifiedCharacteristic characteristic) => _subScribeToCharacteristic(characteristic);
}