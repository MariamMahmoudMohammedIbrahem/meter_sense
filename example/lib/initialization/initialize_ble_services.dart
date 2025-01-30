import '../commons.dart';

/// Initializes BLE services and returns them in a map
Map<String, dynamic> initializeBleServices() {
  final ble = FlutterReactiveBle();
  return {
    'scanner': BleScanner(ble: ble),
    'monitor': BleStatusMonitor(ble),
    'connector': BleDeviceConnector(ble: ble),
    'serviceDiscoverer': initializeBleInteractor(ble),
  };
}

/// Initializes the BLE Interactor
BleDeviceInteractor initializeBleInteractor(FlutterReactiveBle ble) => BleDeviceInteractor(
  bleDiscoverServices: (deviceId) async {
    await ble.discoverAllServices(deviceId);
    return ble.getDiscoveredServices(deviceId);
  },
  readCharacteristic: ble.readCharacteristic,
  writeWithResponse: ble.writeCharacteristicWithResponse,
  writeWithOutResponse: ble.writeCharacteristicWithoutResponse,
  subscribeToCharacteristic: ble.subscribeToCharacteristic,
);