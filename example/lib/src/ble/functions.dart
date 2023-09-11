import 'constants.dart';

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