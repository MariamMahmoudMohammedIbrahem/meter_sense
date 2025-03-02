import '../commons.dart';

// ---------------------------- Meter Data Processing ----------------------------

/// Processes meter data from subscribed output and updates `meterData`.
/// this function saves the only needed data to display and save
void calculateMeterData(List<int> subscribeOutput, String name) {
  for (var i = 0; i < conversionIndices.length; i++) {
    final startIndex = conversionIndices[i];
    final size = conversionSizes[i];
    final value = convertToInt(subscribeOutput, startIndex, size);

    switch (i) {
      case 0: meterData[0] = value; break;
      case 1: meterData[1] = value; break;
      case 2: {
        meterData[2] = value;
        meterData[1] = merge(meterData[1], meterData[2]);
        break;
      }
      case 3: meterData[3] = value; break;
      case 4: meterData[4] = value; break;
      case 5: meterData[5] = value; break;
      case 6: meterData[6] = value; break;
      case 7: meterData[7] = value; break;
      case 8: meterData[8] = value; break;
      case 9: meterData[9] = value; break;
      case 10: meterData[10] = value; break;
      case 11: meterData[11] = value; break;
      case 12: meterData[12] = value; break;
      case 13: meterData[13] = value; break;
      case 14: meterData[14] = value; break;
      case 15:
        {
          meterData[15] = value;
          meterData[3] = (meterData[3] - meterData[15]) / 100;
          break;
        }
    }
  }
  callFunctionOnce(name);
}

/// Ensures `insertMeter` is called only once per session.
void callFunctionOnce(String name) {
  if (!isFunctionCalled) {
    isFunctionCalled = true;
    counter++;
    insertMeter(name);
  }
}