import 'constants.dart';
/*
num convertToInt(String data, int start, int size) {
  final dataArrayTwoDgit = data.split(", ");
  final buffer = List<String>.filled(size, '');
  final sb = StringBuffer();
  final hex = StringBuffer();
  for (var x = start, y = 0; x < start + size && y < size; x++, y++) {
    buffer[y] = dataArrayTwoDgit[x];
    final value = int.parse(buffer[y]);
    final hexadecimalValue = value.toRadixString(16).toUpperCase().padLeft(2, '0');
    sb.write(buffer[y]);
    hex.write(hexadecimalValue);
  }
  final hexa = hex.toString();
  final converted = int.parse(hexa, radix: 16);
  return converted;

}
void calculate(String subscribeOutput) {
  if(valU == 1){
    clientID = convertToInt(subscribeOutput, 1, 4);
    pulses = convertToInt(subscribeOutput, 9, 2);
    totalCredit = convertToInt(subscribeOutput, 11, 4)/100;
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
    month4 = convertToInt(subscribeOutput, 58, 4);
    month5 = convertToInt(subscribeOutput, 62, 4);
    month6 = convertToInt(subscribeOutput, 66, 4);
    warningLimit = convertToInt(subscribeOutput, 70, 1);
    checkSum = convertToInt(subscribeOutput, 71, 1);
  }
  else if(valU == 2){
    totalCreditWater = convertToInt(subscribeOutput, 11, 4);
  }
  callFunctionOnce();
}
*/
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

void calculate(List<int> subscribeOutput) {
  if (valU == 1) {
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
    month4 = convertToInt(subscribeOutput, 58, 4);
    month5 = convertToInt(subscribeOutput, 62, 4);
    month6 = convertToInt(subscribeOutput, 66, 4);
    warningLimit = convertToInt(subscribeOutput, 70, 1);
    checkSum = convertToInt(subscribeOutput, 71, 1);
  } else if (valU == 2) {
    totalCreditWater = convertToInt(subscribeOutput, 11, 4);
  }
  callFunctionOnce();
}

void callFunctionOnce() {
  if (!isFunctionCalled) {
    isFunctionCalled = true;
    addData();
  }
}
void addData() async {
  currentTime = DateTime.now();
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
Future<List<Map>> readData() async {
  final response  = await sqlDb.readData("SELECT `name` FROM Meters");
  return response;
}
Future<void> fetchData() async {
  final testing = await readData();
  for (Map<dynamic, dynamic> map in testing) {
    name = map['name'];
  }
}
