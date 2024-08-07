// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'master_station.dart';
//
// // **************************************************************************
// // FunctionalDataGenerator
// // **************************************************************************
//
// abstract class $MasterInteractionViewModel {
//   const $MasterInteractionViewModel();
//
//   String get deviceId;
//   Connectable get connectableStatus;
//   DeviceConnectionState get connectionStatus;
//   BleDeviceConnector get deviceConnector;
//   Future<List<DiscoveredService>> Function() get discoverServices;
//
//   MasterInteractionViewModel copyWith({
//     String? deviceId,
//     Connectable? connectableStatus,
//     DeviceConnectionState? connectionStatus,
//     BleDeviceConnector? deviceConnector,
//     Future<List<DiscoveredService>> Function()? discoverServices,
//   }) =>
//       MasterInteractionViewModel(
//         deviceId: deviceId ?? this.deviceId,
//         connectableStatus: connectableStatus ?? this.connectableStatus,
//         connectionStatus: connectionStatus ?? this.connectionStatus,
//         deviceConnector: deviceConnector ?? this.deviceConnector,
//         discoverServices: discoverServices ?? this.discoverServices,
//       );
//
//   MasterInteractionViewModel copyUsing(
//       void Function(MasterInteractionViewModel$Change change) mutator) {
//     final change = MasterInteractionViewModel$Change._(
//       this.deviceId,
//       this.connectableStatus,
//       this.connectionStatus,
//       this.deviceConnector,
//       this.discoverServices,
//     );
//     mutator(change);
//     return MasterInteractionViewModel(
//       deviceId: change.deviceId,
//       connectableStatus: change.connectableStatus,
//       connectionStatus: change.connectionStatus,
//       deviceConnector: change.deviceConnector,
//       discoverServices: change.discoverServices,
//     );
//   }
//
//   @override
//   String toString() =>
//       "MasterInteractionViewModel(deviceId: $deviceId, connectableStatus: $connectableStatus, connectionStatus: $connectionStatus, deviceConnector: $deviceConnector, discoverServices: $discoverServices)";
//
//   @override
//   // ignore: avoid_equals_and_hash_code_on_mutable_classes
//   bool operator ==(Object other) =>
//       other is MasterInteractionViewModel &&
//           other.runtimeType == runtimeType &&
//           deviceId == other.deviceId &&
//           connectableStatus == other.connectableStatus &&
//           connectionStatus == other.connectionStatus &&
//           deviceConnector == other.deviceConnector &&
//           const Ignore().equals(discoverServices, other.discoverServices);
//
//   @override
//   // ignore: avoid_equals_and_hash_code_on_mutable_classes
//   int get hashCode {
//     var result = 17;
//     result = 37 * result + deviceId.hashCode;
//     result = 37 * result + connectableStatus.hashCode;
//     result = 37 * result + connectionStatus.hashCode;
//     result = 37 * result + deviceConnector.hashCode;
//     result = 37 * result + const Ignore().hash(discoverServices);
//     return result;
//   }
// }
//
// class MasterInteractionViewModel$Change {
//   MasterInteractionViewModel$Change._(
//       this.deviceId,
//       this.connectableStatus,
//       this.connectionStatus,
//       this.deviceConnector,
//       this.discoverServices,
//       );
//
//   String deviceId;
//   Connectable connectableStatus;
//   DeviceConnectionState connectionStatus;
//   BleDeviceConnector deviceConnector;
//   Future<List<DiscoveredService>> Function() discoverServices;
// }
//
// // ignore: avoid_classes_with_only_static_members
// class MasterInteractionViewModel$ {
//   static final deviceId = Lens<MasterInteractionViewModel, String>(
//         (deviceIdContainer) => deviceIdContainer.deviceId,
//         (deviceIdContainer, deviceId) =>
//         deviceIdContainer.copyWith(deviceId: deviceId),
//   );
//
//   static final connectableStatus =
//   Lens<MasterInteractionViewModel, Connectable>(
//         (connectableStatusContainer) =>
//     connectableStatusContainer.connectableStatus,
//         (connectableStatusContainer, connectableStatus) =>
//         connectableStatusContainer.copyWith(
//             connectableStatus: connectableStatus),
//   );
//
//   static final connectionStatus =
//   Lens<MasterInteractionViewModel, DeviceConnectionState>(
//         (connectionStatusContainer) => connectionStatusContainer.connectionStatus,
//         (connectionStatusContainer, connectionStatus) =>
//         connectionStatusContainer.copyWith(connectionStatus: connectionStatus),
//   );
//
//   static final deviceConnector =
//   Lens<MasterInteractionViewModel, BleDeviceConnector>(
//         (deviceConnectorContainer) => deviceConnectorContainer.deviceConnector,
//         (deviceConnectorContainer, deviceConnector) =>
//         deviceConnectorContainer.copyWith(deviceConnector: deviceConnector),
//   );
//
//   static final discoverServices = Lens<MasterInteractionViewModel,
//       Future<List<DiscoveredService>> Function()>(
//         (discoverServicesContainer) => discoverServicesContainer.discoverServices,
//         (discoverServicesContainer, discoverServices) =>
//         discoverServicesContainer.copyWith(discoverServices: discoverServices),
//   );
// }
