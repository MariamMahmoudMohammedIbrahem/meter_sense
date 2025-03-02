// ---------------------------- Utility Functions ----------------------------

/// Converts a list of bytes "meter data" to an integer value.
num convertToInt(List<int> data, int start, int size) {
  final buffer = List<int>.filled(size, 0);
  var converted = 0;

  for (var i = start, j = 0; i < start + size && j < size; i++, j++) {
    buffer[j] = data[i];
  }

  for (var i = 0; i < buffer.length; i++) {
    converted += buffer[i] << (8 * (size - i - 1));
  }

  return converted;
}

/// Merges total reading and pulses into one value.
double merge(num value1, num value2) {
  final addition = '$value1.${value2.toString().padLeft(3,'0')}';
  return double.parse(addition);
}

/// Calculates checksum for a given list of bytes.
int checkSum(List<int> response) {
  final calculatedSum = response.sublist(0, response.length - 1).reduce((a, b) => a + b) & 0xFF;
  return calculatedSum;
}