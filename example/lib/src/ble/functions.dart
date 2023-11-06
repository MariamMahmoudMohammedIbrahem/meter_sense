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

void calculateElectric(List<int> subscribeOutput,String name) {
  for (var i = 0; i < conversionIndices.length; i++) {
    final startIndex = conversionIndices[i];
    final size = conversionSizes[i];
    final value = convertToInt(subscribeOutput, startIndex, size);

    switch (i) {
      case 0: eleMeter[0] = value; break;
      case 1: eleMeter[1] = value; break;
      case 2: {eleMeter[2] = value; eleMeter[1] = merge(eleMeter[1], eleMeter[2]); break;}
      case 3: eleMeter[3] = value / 100; break;
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
      case 3: watMeter[3] = value / 100; break;
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
    }
  }
  callFunctionOnce(name);
}
void callFunctionOnce(String name) {
  if (!isFunctionCalled) {
    isFunctionCalled = true;
    addData(name);
  }
}

double merge (num value1, num value2){
  final  addition = '$value1.$value2';
  final trial = double.parse(addition);
  return trial;
}

//insert into electricity and water tables
void addData(String name) async {
  now = DateTime.now();
  currentTime =DateFormat.yMMMEd().format(now);
  monthList.clear();
  for (int i = 0; i < 6; i++) {
    final formattedMonth = DateFormat.MMM().format(now.subtract(Duration(days: 30 * i)));
    monthList.add(formattedMonth);
  }
  print('Month from database: $monthList');
  if(paddingType == "Electricity" ){
    await sqlDb.insertData(
        '''
                              INSERT INTO Electricity (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTarrif`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${eleMeter[0]}","$name","${eleMeter[1].toString()}","${eleMeter[3].toString()}","${eleMeter[4].toString()}","${eleMeter[5].toString()}","${eleMeter[6].toString()}","${eleMeter[7].toString()}","${eleMeter[8].toString()}","${eleMeter[9].toString()}","${eleMeter[10].toString()}","${eleMeter[11].toString()}","${eleMeter[12].toString()}","${eleMeter[13].toString()}","${eleMeter[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
    );
    isFunctionCalled = false;
  }
  else{
    // sqlDb.isTableEmpty();
    final count = await myInstance.isTableEmpty();
    // if(count == 0){}
    await sqlDb.insertData(
        '''
                              INSERT INTO Water (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTarrif`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${watMeter[1]}","$name","${watMeter[1].toString()}","${watMeter[3].toString()}","${watMeter[4].toString()}","${watMeter[5].toString()}","${watMeter[6].toString()}","${watMeter[7].toString()}","${watMeter[8].toString()}","${watMeter[9].toString()}","${watMeter[10].toString()}","${watMeter[11].toString()}","${watMeter[12].toString()}","${watMeter[13].toString()}","${watMeter[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
    );
    isFunctionCalled = false;
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
  for (Map<dynamic, dynamic> map in testing) {
    nameList.add(map['name'].toString());
    name.add(map['name'].toString());
    typeList.add(map['type'].toString());
  }
}
