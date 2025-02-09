import '../../commons.dart';

class ChargeCenter extends StatelessWidget {
  const ChargeCenter({
    required this.device,
    required this.characteristic,
    super.key,
  });
  final DiscoveredDevice device;
  final QualifiedCharacteristic characteristic;

  @override
  Widget build(BuildContext context) => Consumer4<BleDeviceConnector,
      ConnectionStateUpdate, BleDeviceInteractor, BleDeviceInteractor>(
    builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
        interactor, __) =>
        ChargeCenterScreen(
          viewModel: ChargeCenterViewModel(
              deviceId: device.id,
              connectableStatus: device.connectable,
              connectionStatus: connectionStateUpdate.connectionState,
              deviceConnector: deviceConnector,
              discoverServices: () =>
                  serviceDiscoverer.discoverServices(device.id)),
          characteristic: characteristic,
          writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
          subscribeToCharacteristic: interactor.subScribeToCharacteristic,
        ),
  );
}