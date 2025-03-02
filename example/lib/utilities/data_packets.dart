import '../commons.dart';

// ---------------------------- Data Packet Preparation ----------------------------

/// Creates a DateTime packet with a checksum to update the date on the meter.
List<int> composeDateTimePacket() {
  final now = DateTime.now();

  final dateTime = [
    0x0D,
    now.hour,
    now.minute,
    (now.weekday + 1) % 7,
    now.day,
    now.month,
    (now.year >> 8) & 0xFF,
    now.year & 0xFF,
  ];

  final checksum = dateTime.reduce((value, element) => value + element) & 0xFF;
  dateTime.add(checksum);

  return dateTime;
}

/// Initializes meter data when it is added but not connected.
List<int> initializeMeterData(int selectedClientId) {
  final bytes = ByteData(4)..setInt32(0, selectedClientId, Endian.big);
  final newBytes = bytes.buffer.asUint8List().toList();
  final zerosList = List.filled(66, 0);
  final createdList = [0x59, ...newBytes, ...zerosList];
  createdList.add(checkSum(createdList));
  return createdList;
}

