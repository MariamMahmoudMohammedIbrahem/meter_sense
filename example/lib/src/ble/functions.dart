import 'dart:convert';

import 'package:intl/intl.dart';

import 'constants.dart';
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

void calculateElectric(List<int> subscribeOutput) {
  print("in");
  clientID = convertToInt(subscribeOutput, 1, 4);
  pulses = convertToInt(subscribeOutput, 9, 2);
  totalCredit = convertToInt(subscribeOutput, 11, 4) / 100;
  currentTarrif = convertToInt(subscribeOutput, 15, 1);
  tarrifVersion = convertToInt(subscribeOutput, 16, 2);
  valveStatus = convertToInt(subscribeOutput, 18, 1);
  leackageFlag = convertToInt(subscribeOutput, 19, 1);
  fraudFlag = convertToInt(subscribeOutput, 20, 1);
  fraudHours = convertToInt(subscribeOutput, 21, 1);
  fraudMinutes = convertToInt(subscribeOutput, 22, 1);
  fraudDayOfWeek = convertToInt(subscribeOutput, 23, 1);
  fraudDayOfMonth = convertToInt(subscribeOutput, 24, 1);
  fraudMonth = convertToInt(subscribeOutput, 25, 1);
  fraudYear = convertToInt(subscribeOutput, 26, 1);
  totalDebit = convertToInt(subscribeOutput, 27, 4);
  currentConsumption = convertToInt(subscribeOutput, 31, 4);
  lcHour = convertToInt(subscribeOutput, 35, 1);
  lcMinutes = convertToInt(subscribeOutput, 36, 1);
  lcDayWeek = convertToInt(subscribeOutput, 37, 1);
  lcDayMonth = convertToInt(subscribeOutput, 38, 1);
  lcMonth = convertToInt(subscribeOutput, 39, 1);
  lcYear = convertToInt(subscribeOutput, 40, 1);
  lastChargeValueNumber = convertToInt(subscribeOutput, 41, 5);
  month1 = convertToInt(subscribeOutput, 46, 4);
  month2 = convertToInt(subscribeOutput, 50, 4);
  month3 = convertToInt(subscribeOutput, 54, 4);
  // month4 = convertToInt(subscribeOutput, 58, 4);
  // month5 = convertToInt(subscribeOutput, 62, 4);
  // month6 = convertToInt(subscribeOutput, 66, 4);
  // warningLimit = convertToInt(subscribeOutput, 70, 1);
  // checkSum = convertToInt(subscribeOutput, 71, 1);
  callFunctionOnce();
}
/*
void calculateElectric(List<int> subscribeOutput) {
  print("object");
  for (var i = 0; i < conversionIndices.length; i++) {
    final startIndex = conversionIndices[i];
    final size = conversionSizes[i];
    final value = convertToInt(subscribeOutput, startIndex, size);

    switch (i) {
      case 0: clientID = value; break;
      case 1: pulses = value; break;
      case 2: totalCredit = value / 100; break;
      case 3: currentTarrif = value; break;
      case 4: tarrifVersion = value; break;
      case 5: valveStatus = value; break;
      case 6: leackageFlag = value; break;
      case 7: fraudFlag = value; break;
      case 8: fraudHours = value; break;
      case 9: fraudMinutes = value; break;
      case 10: fraudDayOfWeek = value; break;
      case 11: fraudDayOfMonth = value; break;
      case 12: fraudMonth = value; break;
      case 13: fraudYear = value; break;
      case 14: totalDebit = value; break;
      case 15: currentConsumption = value; break;
      case 16: lcHour = value; break;
      case 17: lcMinutes = value; break;
      case 18: lcDayWeek = value; break;
      case 19: lcDayMonth = value; break;
      case 20: lcMonth = value; break;
      case 21: lcYear = value; break;
      case 22: lastChargeValueNumber = value; break;
      case 23: month1 = value; break;
      case 24: month2 = value; break;
      case 25: month3 = value; break;
      case 26: month4 = value; break;
      case 27: month5 = value; break;
      case 28: month6 = value; break;
      case 29: warningLimit = value; break;
      case 30: checkSum = value; break;
    }
  }

  callFunctionOnce();
}
*/
void calculateWater(List<int> subscribeOutput) {
  clientIDWater = convertToInt(subscribeOutput, 1, 4);
  pulsesWater = convertToInt(subscribeOutput, 9, 2);
  totalCreditWater = convertToInt(subscribeOutput, 11, 4)/100;
  currentTarrifWater = convertToInt(subscribeOutput, 15, 1);
  tarrifVersionWater = convertToInt(subscribeOutput, 16, 2);
  valveStatusWater = convertToInt(subscribeOutput, 18, 1);
  leackageFlagWater = convertToInt(subscribeOutput, 19, 1);
  fraudFlagWater = convertToInt(subscribeOutput, 20, 1);
  fraudHoursWater = convertToInt(subscribeOutput, 21, 1);
  fraudMinutesWater = convertToInt(subscribeOutput, 22, 1);
  fraudDayOfWeekWater = convertToInt(subscribeOutput, 23, 1);
  fraudDayOfMonthWater = convertToInt(subscribeOutput, 24, 1);
  fraudMonthWater = convertToInt(subscribeOutput, 25, 1);
  fraudYearWater = convertToInt(subscribeOutput, 26, 1);
  totalDebitWater = convertToInt(subscribeOutput, 27, 4);
  currentConsumptionWater = convertToInt(subscribeOutput, 31, 4);
  lcHourWater = convertToInt(subscribeOutput, 35, 1);
  lcMinutesWater = convertToInt(subscribeOutput, 36, 1);
  lcDayWeekWater = convertToInt(subscribeOutput, 37, 1);
  lcDayMonthWater = convertToInt(subscribeOutput, 38, 1);
  lcMonthWater = convertToInt(subscribeOutput, 39, 1);
  lcYearWater = convertToInt(subscribeOutput, 40, 1);
  lastChargeValueNumberWater = convertToInt(subscribeOutput, 41, 5);
  month1Water = convertToInt(subscribeOutput, 46, 4);
  month2Water = convertToInt(subscribeOutput, 50, 4);
  month3Water = convertToInt(subscribeOutput, 54, 4);
  month4Water = convertToInt(subscribeOutput, 58, 4);
  month5Water = convertToInt(subscribeOutput, 62, 4);
  month6Water = convertToInt(subscribeOutput, 66, 4);
  warningLimitWater = convertToInt(subscribeOutput, 70, 1);
  checkSumWater = convertToInt(subscribeOutput, 71, 1);
  callFunctionOnce();
}
void callFunctionOnce() {
  if (!isFunctionCalled) {
    isFunctionCalled = true;
    addData();
  }
}

//insert into electricity and water tables
Future<void> addData() async {
  now = DateTime.now();
  currentTime =DateFormat.yMMMEd().format(now);
  if(valU == 1){
    response = await sqlDb.insertData(
        '''
                              INSERT INTO Electricity (`clientId`,`title`,`totalReading`,`pulses`,`totalCredit`,`currentTarrif`,`tarrifVersion`,`valveStatus`,`leackageFlag`,`fraudFlag`,`fraudHours`,`fraudMinutes`,`fraudDayOfWeek`,`fraudDayOfMonth`,`fraudMonth`,`fraudYear`,`totalDebit`,`currentConsumption`,`lcHour`,`lcMinutes`,`lcDayWeek`,`lcDayMonth`,`lcMonth`,`lcYear`,` lastChargeValueNumber`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`warningLimit`,`time`)
                              VALUES ("${clientID.toString()}","$meterName","${totalReading.toString()}","${pulses.toString()}","${totalCredit.toString()}","${currentTarrif.toString()}","${tarrifVersion.toString()}","${valveStatus.toString()}","${leackageFlag.toString()}","${fraudFlag.toString()}","${fraudHours.toString()}","${fraudMinutes.toString()}","${fraudDayOfWeek.toString()}","${fraudDayOfMonth.toString()}","${fraudMonth.toString()}","${fraudYear.toString()}","${totalDebit.toString()}","${currentConsumption.toString()}","${lcHour.toString()}","${lcMinutes.toString()}","${lcDayWeek.toString()}","${lcDayMonth.toString()}","${lcMonth.toString()}","${lcYear.toString()}","${lastChargeValueNumber.toString()}","${month1.toString()}","${month2.toString()}","${month3.toString()}","${month4.toString()}","${month5.toString()}","${month6.toString()}","${warningLimit.toString()}","$currentTime")
                              '''
    );
  }
  if(valU == 2){
    response = await sqlDb.insertData(
        '''
                              INSERT INTO Water (`data`,`title`,`time`)
                              VALUES ("${clientID.toString()}","$meterName","$currentTime")
                              '''
    );
  }
}

// read all data from meter
Future<List<Map>> readData() async {
  final response  = await sqlDb.readData("SELECT `name`,`type` FROM Meters");
  return response;
}

//fetch meter data
Future<void> fetchData() async {
  final testing = await readData();
  for (final map in testing) {
    name = map['name'];
    meterType = map['type'];
  }
}

Future<String> prepareDataForTransfer() async {
  final data = await sqlDb.queryElectricityData();
  final jsonData = jsonEncode(data);
  return jsonData;
}