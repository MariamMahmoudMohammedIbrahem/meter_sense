import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  currentTime =DateFormat.yMMMEd().format(DateTime.now());
  if(paddingType == "Electricity" ){
    final count  = await myInstance.isTableEmpty('$paddingType', name);
    if(count){
      await sqlDb.insertData(
          '''
                              INSERT INTO Electricity (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTarrif`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${eleMeter[0]}","$name","${eleMeter[1].toString()}","${eleMeter[3].toString()}","${eleMeter[4].toString()}","${eleMeter[5].toString()}","${eleMeter[6].toString()}","${eleMeter[7].toString()}","${eleMeter[8].toString()}","${eleMeter[9].toString()}","${eleMeter[10].toString()}","${eleMeter[11].toString()}","${eleMeter[12].toString()}","${eleMeter[13].toString()}","${eleMeter[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
      );
    }
    else{
      await sqlDb.readTime(name, '$paddingType');
      if(currentTime == time){
        await sqlDb.updateData(
            '''
              UPDATE Electricity
              SET 
                totalReading = ${eleMeter[1]},
                totalCredit = ${eleMeter[3]},
                currentTarrif = ${eleMeter[4]},
                valveStatus = ${eleMeter[5]},
                leackageFlag = ${eleMeter[6]},
                fraudFlag = ${eleMeter[7]},
                currentConsumption = ${eleMeter[8]},
                month1 = ${eleMeter[9]},
                month2 = ${eleMeter[10]},
                month3 = ${eleMeter[11]},
                month4 = ${eleMeter[12]},
                month5 = ${eleMeter[13]},
                month6 = ${eleMeter[14]},
                list = '$subscribeOutput'
              WHERE time = '$currentTime' AND title = '$name'
            '''
        );
      }
      //else if time != time stored in database insert the data
      else {
        await sqlDb.insertData(
            '''
                              INSERT INTO Electricity (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTarrif`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${eleMeter[0]}","$name","${eleMeter[1].toString()}","${eleMeter[3].toString()}","${eleMeter[4].toString()}","${eleMeter[5].toString()}","${eleMeter[6].toString()}","${eleMeter[7].toString()}","${eleMeter[8].toString()}","${eleMeter[9].toString()}","${eleMeter[10].toString()}","${eleMeter[11].toString()}","${eleMeter[12].toString()}","${eleMeter[13].toString()}","${eleMeter[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
        );
      }
    }
    isFunctionCalled = false;
  }
  else{
    final count = await myInstance.isTableEmpty('$paddingType', name);
    //IF TABLE IS EMPTY insert the data
    if(count){
      await sqlDb.insertData(
          '''
                              INSERT INTO Water (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTarrif`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${watMeter[0]}","$name","${watMeter[1].toString()}","${watMeter[3].toString()}","${watMeter[4].toString()}","${watMeter[5].toString()}","${watMeter[6].toString()}","${watMeter[7].toString()}","${watMeter[8].toString()}","${watMeter[9].toString()}","${watMeter[10].toString()}","${watMeter[11].toString()}","${watMeter[12].toString()}","${watMeter[13].toString()}","${watMeter[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
      );
    }
    //else if the table is not empty
    else{
      //if time == time stored in the database update the row where title = name of the selected meter
      await sqlDb.readTime(name, '$paddingType');
      if(currentTime == time){
        await sqlDb.updateData(
            '''
              UPDATE Water
              SET 
                totalReading = ${watMeter[1]},
                totalCredit = ${watMeter[3]},
                currentTarrif = ${watMeter[4]},
                valveStatus = ${watMeter[5]},
                leackageFlag = ${watMeter[6]},
                fraudFlag = ${watMeter[7]},
                currentConsumption = ${watMeter[8]},
                month1 = ${watMeter[9]},
                month2 = ${watMeter[10]},
                month3 = ${watMeter[11]},
                month4 = ${watMeter[12]},
                month5 = ${watMeter[13]},
                month6 = ${watMeter[14]},
                list = '$subscribeOutput'
              WHERE time = '$currentTime' AND title = '$name'
            '''
        );
      }
      //else if time != time stored in database insert the data
      else {
        await sqlDb.insertData(
            '''
                              INSERT INTO Water (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTarrif`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${watMeter[1]}","$name","${watMeter[1].toString()}","${watMeter[3].toString()}","${watMeter[4].toString()}","${watMeter[5].toString()}","${watMeter[6].toString()}","${watMeter[7].toString()}","${watMeter[8].toString()}","${watMeter[9].toString()}","${watMeter[10].toString()}","${watMeter[11].toString()}","${watMeter[12].toString()}","${watMeter[13].toString()}","${watMeter[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
        );
      }
    }
    isFunctionCalled = false;
  }
}

// read all data from meters
Future<List<Map>> readData() async {
  final response  = await sqlDb.readData("SELECT * FROM Meters");
  return response;
}

//fetch meter data
Future<void> fetchData() async {
  balanceList.clear();
  tarrifList.clear();
  final testing = await readData();
  for (Map<dynamic, dynamic> map in testing) {
    if (!nameList.contains(map['name'].toString())){
      nameList.add(map['name'].toString());
      name.add(map['name'].toString());
    }
    balanceList.add(int.parse(map['balance'].toString()));
    tarrifList.add(int.parse(map['tarrif'].toString()));
    // typeList.add(map['type'].toString());
  }
}
IconData getStrengthIcon(int rssi) {
  if (-30 >= rssi && rssi >= -55) {
    return Icons.signal_cellular_alt_outlined; // Icon for more strong
  } else if (-55 >= rssi && rssi >= -67) {
    return Icons.signal_cellular_alt_2_bar_outlined; // Icon for strong
  } else if (-80 >= rssi && rssi >= -90) {
    return Icons.signal_cellular_alt_1_bar_outlined; // Icon for terrible
  } else if (rssi < -90) {
    return Icons.signal_cellular_off; // Icon for unusable
  } else {
    return Icons.error; // Handle any other cases
  }
}