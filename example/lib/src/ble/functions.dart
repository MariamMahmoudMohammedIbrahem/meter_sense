import 'package:intl/intl.dart';

import 'constants.dart';

num convertToInt(List<int> data, int start, int size) {
  final buffer = List<int>.filled(size, 0);
  int converted = 0;

  for (var i = start, j = 0; i < start + size && j < size; i++, j++) {
    buffer[j] = data[i];
  }

  for (var i = 0; i < buffer.length; i++) {
    converted += buffer[i] << (8 * (size - i - 1));
  }

  return converted;
}

void calculateElectric(List<int> subscribeOutput) {
  for (var i = 0; i < conversionIndices.length; i++) {
    final startIndex = conversionIndices[i];
    final size = conversionSizes[i];
    final value = convertToInt(subscribeOutput, startIndex, size);

    switch (i) {
      case 0: clientID = value; break;
      case 1: totalReading = value; break;
      case 2: pulses = value; break;
      case 3: totalCredit = value / 100; break;
      case 4: currentTarrif = value; break;
      case 5: valveStatus = value; break;
      case 6: leackageFlag = value; break;
      case 7: fraudFlag = value; break;
      case 8: currentConsumption = value; break;
      case 9: month1 = value; break;
      case 10: month2 = value; break;
      case 11: month3 = value; break;
      case 12: month4 = value; break;
      case 13: month5 = value; break;
      case 14: month6 = value; break;
    }
  }
  callFunctionOnce();
}

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

double merge (num value1, num value2){
  final  addition = '$value1.$value2';
  final trial = double.parse(addition);
  return trial;
}

//insert into electricity and water tables
void addData() async {
  now = DateTime.now();
  currentTime =DateFormat.yMMMEd().format(now);
  monthList.clear();
  for (int i = 0; i < 6; i++) {
    final formattedMonth = DateFormat.MMM().format(now.subtract(Duration(days: 30 * i)));
    monthList.add(formattedMonth);
  }
  print('Month from database: $monthList');
  if(paddingType == "Electricity" ){
    final totalPulses = merge(totalReading,pulses);
    await sqlDb.insertData(
        '''
                              INSERT INTO Electricity (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTarrif`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("$clientID","$meterName","${totalPulses.toString()}","${totalCredit.toString()}","${currentTarrif.toString()}","${valveStatus.toString()}","${leackageFlag.toString()}","${fraudFlag.toString()}","${currentConsumption.toString()}","${month1.toString()}","${month2.toString()}","${month3.toString()}","${month4.toString()}","${month5.toString()}","${month6.toString()}","$subscribeOutput","none","$currentTime")
        '''
    );
  }
  else{
    final totalPulsesWater = merge(totalReadingWater,pulsesWater);
    await sqlDb.insertData(
        '''
                              INSERT INTO Water (`clientId`,`title`,`totalReading`,`pulses`,`totalCredit`,`currentTarrif`,`tarrifVersion`,`valveStatus`,`leackageFlag`,`fraudFlag`,`fraudHours`,`fraudMinutes`,`fraudDayOfWeek`,`fraudDayOfMonth`,`fraudMonth`,`fraudYear`,`totalDebit`,`currentConsumption`,`lcHour`,`lcMinutes`,`lcDayWeek`,`lcDayMonth`,`lcMonth`,`lcYear`,`lastChargeValueNumber`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`warningLimit`,`time`)
                              VALUES ("$clientIDWater","$meterName","${totalPulsesWater.toString()}","${pulsesWater.toString()}","${totalCreditWater.toString()}","${currentTarrifWater.toString()}","${tarrifVersionWater.toString()}","${valveStatusWater.toString()}","${leackageFlagWater.toString()}","${fraudFlagWater.toString()}","${fraudHoursWater.toString()}","${fraudMinutesWater.toString()}","${fraudDayOfWeekWater.toString()}","${fraudDayOfMonthWater.toString()}","${fraudMonthWater.toString()}","${fraudYearWater.toString()}","${totalDebitWater.toString()}","${currentConsumptionWater.toString()}","${lcHourWater.toString()}","${lcMinutesWater.toString()}","${lcDayWeekWater.toString()}","${lcDayMonthWater.toString()}","${lcMonthWater.toString()}","${lcYearWater.toString()}","${lastChargeValueNumberWater.toString()}","${month1Water.toString()}","${month2Water.toString()}","${month3Water.toString()}","${month4Water.toString()}","${month5Water.toString()}","${month6Water.toString()}","${warningLimitWater.toString()}","$currentTime")
        '''
    );
  }
  isFunctionCalled = false;
}

// read all data from meter
Future<List<Map>> readData() async {
  final response  = await sqlDb.readData("SELECT `name`,`type` FROM Meters");
  return response;
}

//fetch meter data
Future<void> fetchData() async {
  final testing = await readData();
  for (Map<dynamic, dynamic> map in testing) {
    nameList.add(map['name'].toString());
    name.add(map['name'].toString());
    typeList.add(map['type'].toString());
  }
}

