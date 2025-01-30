import 'commons.dart';

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

void calculateElectric(List<int> subscribeOutput,String name) {
  for (var i = 0; i < conversionIndices.length; i++) {
    final startIndex = conversionIndices[i];
    final size = conversionSizes[i];
    final value = convertToInt(subscribeOutput, startIndex, size);

    switch (i) {
      case 0: eleMeter[0] = value; break;
      case 1: eleMeter[1] = value; break;
      case 2: {eleMeter[2] = value; eleMeter[1] = merge(eleMeter[1], eleMeter[2]); break;}
      case 3: eleMeter[3] = value; break;
      case 4: eleMeter[4] = value; break;
      case 5: eleMeter[5] = value; break;
      case 6: eleMeter[6] = value; break;
      case 7: eleMeter[7] = value; break;
      case 8: eleMeter[8] = value; break;
      case 9: eleMeter[9] = value; break;
      case 10: eleMeter[10] = value; break;
      case 11: eleMeter[11] = value; break;
      case 12: eleMeter[12] = value; break;
      case 13: eleMeter[13] = value; break;
      case 14: eleMeter[14] = value; break;
      case 15:
        {
          eleMeter[15] = value;
          eleMeter[3] = (eleMeter[3] - eleMeter[15]) / 100;
          break;
        }
    }
  }
  callFunctionOnce(name);
}

void calculateWater(List<int> subscribeOutput, String name) {
  for (var i = 0; i < conversionIndices.length; i++) {
    final startIndex = conversionIndices[i];
    final size = conversionSizes[i];
    final value = convertToInt(subscribeOutput, startIndex, size);

    switch (i) {
      case 0: watMeter[0] = value; break;
      case 1: watMeter[1] = value; break;
      case 2: {watMeter[2] = value; watMeter[1] = merge(watMeter[1], watMeter[2]); break;}
      case 3: watMeter[3] = value; break;
      case 4: watMeter[4] = value; break;
      case 5: watMeter[5] = value; break;
      case 6: watMeter[6] = value; break;
      case 7: watMeter[7] = value; break;
      case 8: watMeter[8] = value; break;
      case 9: watMeter[9] = value; break;
      case 10: watMeter[10] = value; break;
      case 11: watMeter[11] = value; break;
      case 12: watMeter[12] = value; break;
      case 13: watMeter[13] = value; break;
      case 14: watMeter[14] = value; break;
      case 15:
        {
          watMeter[15] = value;
          watMeter[3] = (watMeter[3] - watMeter[15]) / 100;
          break;
        }
    }
  }
  callFunctionOnce(name);
}
void callFunctionOnce(String name) {
  if (!isFunctionCalled) {
    isFunctionCalled = true;
    counter++;
    addData(name);
  }
}

double merge (num value1, num value2){

  final  addition = '$value1.${value2.toString().padLeft(3,'0')}';
  final trial = double.parse(addition);
  return trial;
}

void masterValues(List<int> data){
  clientID = convertToInt(data, 1, 4);
  totalReadings = convertToInt(data, 5, 4);
  pulses = convertToInt(data, 9, 2);
  totalReadingsPulses = merge(totalReadings, pulses);
  currentBalance = (convertToInt(data, 11, 4)-convertToInt(data, 27, 4))/100;
  currentTariff = convertToInt(data, 15, 1);
  currentTariffVersion = convertToInt(data, 16, 2);
}

void showToast(String text, Color bgColor, Color txtColor) {
  Fluttertoast.showToast(
    msg: text,
    backgroundColor: bgColor,
    textColor: txtColor,
  );
}

List<int> composeDateTimePacket() {
  final now = DateTime.now();

  final hh = now.hour;
  final mm = now.minute;
  final dw = (now.weekday + 1) % 7;
  final dM = now.day;
  final mM = now.month;
  final yyyy = now.year;

  dateTime = [
    0x0D,
    hh,
    mm,
    dw,
    dM,
    mM,
    (yyyy >> 8) & 0xFF,
    yyyy & 0xFF,
  ];

  final checksum = dateTime.reduce((value, element) => value + element) & 0xFF;
  dateTime.add(checksum);

  return dateTime;
}
