import '../commons.dart';

//insert into electricity and water tables
Future<void> insertMeter(String name) async {
  currentTime =DateFormat.MMMEd().format(DateTime.now());
  if(name.startsWith("Ele")){
    final count  = await isTableEmpty("Electricity", name);
    // insert meter if it doesn't exist and initialize its data
    if(count){
      final scannedClientId = int.parse(regExp.firstMatch(name)?.group(0) ?? '0');

      print('electricity $count insert1 $name $scannedClientId');
      subscribeOutput = initializeMeterData(scannedClientId);
      print(scannedClientId);
      await sqlDb.insertData(
          '''
                              INSERT INTO Electricity (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTariff`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("$scannedClientId","$name","${meterData[1].toString()}","${meterData[3].toString()}","${meterData[4].toString()}","${meterData[5].toString()}","${meterData[6].toString()}","${meterData[7].toString()}","${meterData[8].toString()}","${meterData[9].toString()}","${meterData[10].toString()}","${meterData[11].toString()}","${meterData[12].toString()}","${meterData[13].toString()}","${meterData[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
      );
    }
    else{
      await readTime(name, "Electricity");
      if(currentTime == time){
        await sqlDb.updateData(
            '''
              UPDATE Electricity
              SET 
                totalReading = ${meterData[1]},
                totalCredit = ${meterData[3]},
                currentTariff = ${meterData[4]},
                valveStatus = ${meterData[5]},
                leackageFlag = ${meterData[6]},
                fraudFlag = ${meterData[7]},
                currentConsumption = ${meterData[8]},
                month1 = ${meterData[9]},
                month2 = ${meterData[10]},
                month3 = ${meterData[11]},
                month4 = ${meterData[12]},
                month5 = ${meterData[13]},
                month6 = ${meterData[14]},
                list = '$subscribeOutput'
              WHERE time = '$currentTime' AND title = '$name'
            '''
        );
      }
      //else if time != time stored in database insert the data
      else {
        await sqlDb.insertData(
            '''
                              INSERT INTO Electricity (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTariff`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${meterData[0]}","$name","${meterData[1].toString()}","${meterData[3].toString()}","${meterData[4].toString()}","${meterData[5].toString()}","${meterData[6].toString()}","${meterData[7].toString()}","${meterData[8].toString()}","${meterData[9].toString()}","${meterData[10].toString()}","${meterData[11].toString()}","${meterData[12].toString()}","${meterData[13].toString()}","${meterData[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
        );
      }
    }
    isFunctionCalled = false;
  }
  else{
    final count = await isTableEmpty("Water", name);
    final scannedClientId = int.parse(regExp.firstMatch(name)?.group(0) ?? '0');
    print('water $count ins $name $scannedClientId');
    subscribeOutput = initializeMeterData(scannedClientId);
    print(scannedClientId);
    //IF TABLE IS EMPTY insert the data
    if(count){
      print('water $count insert $name');
      await sqlDb.insertData(
          '''
                              INSERT INTO Water (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTariff`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("$scannedClientId","$name","${meterData[1].toString()}","${meterData[3].toString()}","${meterData[4].toString()}","${meterData[5].toString()}","${meterData[6].toString()}","${meterData[7].toString()}","${meterData[8].toString()}","${meterData[9].toString()}","${meterData[10].toString()}","${meterData[11].toString()}","${meterData[12].toString()}","${meterData[13].toString()}","${meterData[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
      );
    }
    //else if the table is not empty
    else{
      //if time == time stored in the database update the row where title = name of the selected meter
      await readTime(name, "Water");
      if(currentTime == time){
        await sqlDb.updateData(
            '''
              UPDATE Water
              SET 
                totalReading = ${meterData[1]},
                totalCredit = ${meterData[3]},
                currentTariff = ${meterData[4]},
                valveStatus = ${meterData[5]},
                leackageFlag = ${meterData[6]},
                fraudFlag = ${meterData[7]},
                currentConsumption = ${meterData[8]},
                month1 = ${meterData[9]},
                month2 = ${meterData[10]},
                month3 = ${meterData[11]},
                month4 = ${meterData[12]},
                month5 = ${meterData[13]},
                month6 = ${meterData[14]},
                list = '$subscribeOutput'
              WHERE time = '$currentTime' AND title = '$name'
            '''
        );
      }
      //else if time != time stored in database insert the data
      else {
        await sqlDb.insertData(
            '''
                              INSERT INTO Water (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTariff`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${meterData[1]}","$name","${meterData[1].toString()}","${meterData[3].toString()}","${meterData[4].toString()}","${meterData[5].toString()}","${meterData[6].toString()}","${meterData[7].toString()}","${meterData[8].toString()}","${meterData[9].toString()}","${meterData[10].toString()}","${meterData[11].toString()}","${meterData[12].toString()}","${meterData[13].toString()}","${meterData[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
        );
      }
    }
    isFunctionCalled = false;
  }
}
Future<void> deleteMeter(String meterName, String meterType) async {
  final myDb = await sqlDb.db;

  await myDb!.delete(
    'Meters',
    where: 'name = ?',
    whereArgs: [meterName],
  ).then(
        (value) => myDb.delete(
      '$meterType',
      where: 'title = ?',
      whereArgs: [meterName],
    ),
  );

}
Future<void> fetchData() async {
  nameList.clear();
  balanceList.clear();
  tariffList.clear();
  final testing = await sqlDb.readData('SELECT * FROM Meters');
  if (kDebugMode) {
    print('SELECT * FROM Meters $testing');
  }
  for (final map in testing) {
    if (!nameList.contains(map['name'].toString())){
      nameList.add(map['name'].toString());
    }
    balanceList.add(int.parse(map['balance'].toString()));
    tariffList.add(int.parse(map['tariff'].toString()));
  }
}

//get the data of previous connected meters
Future<List<Map>> readMeterData(String title) async {
  final myDb = await sqlDb.db;
  response =[];
  /*if (kDebugMode) {
    print('object');
  }*/
  if (title.startsWith('Ele')) {
    if (eleMeters[title] == null) {
      eleMeters[title] = [0, 0, 0, 0, 0];
    }
    response = await myDb!.rawQuery(
      '''
          SELECT `title` , `currentTariff`, `totalReading`, `totalCredit`, `currentConsumption` ,`valveStatus`
          FROM Electricity 
          WHERE `title` = ?
          ORDER BY `id` DESC 
          LIMIT 1
        ''',
      [title],
    );

    for (final map in response) {
      eleMeters[title]?[0] = num.parse(map['currentTariff'].toString());
      eleMeters[title]?[1] = num.parse(map['totalReading'].toString());
      eleMeters[title]?[2] = num.parse(map['totalCredit'].toString());
      eleMeters[title]?[3] = num.parse(map['currentConsumption'].toString());
      eleMeters[title]?[4] = num.parse(map['valveStatus'].toString());
    }
  }
  else if (title.startsWith('W')) {
    if (watMeters[title] == null) {
      watMeters[title] = [0, 0, 0, 0, 0];
    }
    response = await myDb!.rawQuery(
      '''
          SELECT `title`, `currentTariff`, `totalReading`, `totalCredit`, `currentConsumption`, `valveStatus`
          FROM Water 
          WHERE `title` = ?
          ORDER BY `id` DESC 
          LIMIT 1
        ''',
      [title],
    );

    for (final map in response) {
      watMeters[title]?[0] = num.parse(map['currentTariff'].toString());
      watMeters[title]?[1] = num.parse(map['totalReading'].toString());
      watMeters[title]?[2] = num.parse(map['totalCredit'].toString());
      watMeters[title]?[3] = num.parse(map['currentConsumption'].toString());
      watMeters[title]?[4] = num.parse(map['valveStatus'].toString());
    }
  }
  return response;
}
// get the data of the last days "history data"
Future<List<Map>> read(String name, String type) async {
  final myDb = await sqlDb.db;
  var query = '';
  if(type == 'Electricity'){
    query = '''
        SELECT `totalReading`, `time` FROM Electricity
        WHERE `title` =?
        ORDER BY id DESC
        LIMIT 10
      ''';
  }
  else{
    query = '''
        SELECT `totalReading`, `time` FROM Water
        WHERE `title` =?
        ORDER BY id DESC
        LIMIT 10
      ''';
  }
  final response  = await myDb!.rawQuery(
    query,
    [name],
  );
  return response;
}

//graph data "months data"
Future<void> editingList(String name) async {
  final myDb = await sqlDb.db;
  //electric
  if(name.startsWith('Ele')){
    const query = '''
    SELECT `month1`,`month2`,`month3`,`month4`,`month5`,`month6` 
    FROM Electricity
    WHERE `title` =?
    ORDER BY `id` DESC  
    LIMIT 1
  ''';
    final response = await myDb!.rawQuery(query,[name]);
    if (response.isNotEmpty) {
      final map = response.first;
      meterReadings = [
        map['month6'],
        map['month5'],
        map['month4'],
        map['month3'],
        map['month2'],
        map['month1'],
      ].map((value) {
        if (value is double) {
          return value/100;
        } else if (value is String) {
          final parsedValue = double.tryParse(value);
          if (parsedValue != null) {
            return parsedValue/100;
          } else {
            return 0.0;
          }
        } else {
          return 0.0;
        }
      }).toList();
    } else {
      meterReadings = [0,0,0,0,0,0];
    }
    await getSpecifiedList(name, 'tariff');
  }
  //water
  else{
    const query = '''
    SELECT `month1`,`month2`,`month3`,`month4`,`month5`,`month6` 
    FROM Water
    WHERE `title` =?
    ORDER BY `id` DESC  
    LIMIT 1
  ''';

    final response = await myDb!.rawQuery(query,[name]);
    if (response.isNotEmpty) {
      final map = response.first;
      meterReadings = [
        map['month6'],
        map['month5'],
        map['month4'],
        map['month3'],
        map['month2'],
        map['month1'],
      ].map((value) {
        if (value is double) {
          return value/100;
        } else if (value is String) {
          final parsedValue = double.tryParse(value);
          if (parsedValue != null) {
            return parsedValue/100;
          } else {
            return 0.0;
          }
        } else {
          return 0.0;
        }
      }).toList();
    } else {
      meterReadings = [0,0,0,0,0,0];
    }
    await getSpecifiedList(name, 'tariff');
  }
}

//check if the meter has previous stored data or not
Future<bool> isTableEmpty(String type, String name) async {
  final myDb = await sqlDb.db;
  if(type == 'Electricity'){
    query = 'SELECT COUNT(*) FROM Electricity WHERE `title` =?';
    query2 = '''
      SELECT `time` FROM Electricity
      WHERE `title` = ?
      ORDER BY `id` DESC
      LIMIT 1
    ''';
  }
  else{
    query = 'SELECT COUNT(*) FROM Water WHERE `title` =?';
    query2 = '''
      SELECT `time` FROM Water
      WHERE `title` = ?
      ORDER BY `id` DESC
      LIMIT 1
    ''';
  }
  final count = Sqflite.firstIntValue(
    await myDb!.rawQuery(query,[name]),
  );
  if(count != 0){
    final response = await myDb.rawQuery(query2,
      [name],);
    for(final map in response){
      time = map['time'].toString();
    }
  }
  return count == 0;
}

// retrieve the last time stored in the database
Future<List<Map>> readTime(String name, String type) async{
  final myDb = await sqlDb.db;
  if(type == 'Electricity'){
    query = '''
      SELECT `time` FROM Electricity 
      WHERE `title` = ?
      ORDER BY `id` DESC 
      LIMIT 1 
    ''';
  }
  else if(type == 'Water'){
    query = '''
      SELECT `time` FROM Water 
      WHERE `title` = ?
      ORDER BY `id` DESC 
      LIMIT 1 
    ''';
  }
  final response = await myDb!.rawQuery(query,
    [name],);
  for(final map in response){
    time = map['time'].toString();
  }
  return response;
}

Future<List<int>> getSpecifiedList(String? name, String process) async {
  final myDb = await sqlDb.db;
  var query = '';

  if(process == 'none'){
    if(name!.startsWith('W')){
      query = 'SELECT `list`,`title`,`clientId` FROM Water WHERE `title` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
      listType = 'Water';
    }
    else{
      query = 'SELECT `list`,`title`,`clientId` FROM Electricity WHERE `title` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
      listType = 'Electricity';
    }
    final List<Map<String, dynamic>> result = await myDb!.rawQuery(
      query,
      [name,process],
    );
    if (result.isNotEmpty) {
      final dynamic jsonListDynamic = result[0]['list'];
      final jsonList = jsonListDynamic as String?;
      if (jsonList != null) {
        final dynamicList = jsonDecode(jsonList) as List<dynamic>;
        myList = dynamicList.cast<int>();
        calculateChargeValues(myList);
        if(listType == "Electricity") {myList[0] = 0xA1;}
        else {myList[0] = 0xA0;}
        return myList;
      }
    }
  }
  else {
    myList = [];
    query = 'SELECT * FROM master_table WHERE `name` = ? AND `process` = ? ORDER BY id DESC LIMIT 1';
    final List<Map<String, dynamic>> result = await myDb!.rawQuery(query, [name, process]);

    print('$name $result $process');
    if (result.isNotEmpty) {
      final dynamic jsonListDynamic = result[0]['list'];
      // listType = result[0]['type'];
      if (jsonListDynamic != null) {
        final jsonList = jsonListDynamic as String;
        final dynamicList = jsonDecode(jsonList) as List<dynamic>;
        myList = dynamicList.cast<int>();
        int sum = myList.fold(0, (previousValue, element) => previousValue + element);
        myList.add(sum);
        print(myList);
        return myList;
      }
    }
  }

  return myList;
}
//save the list in the master station page tariff or balance
Future<void> saveList(List<int> myList, String name, String type, String process) async {
  final myDb = await sqlDb.db;
  final jsonList = jsonEncode(myList);
  final rewrite = Sqflite.firstIntValue(
    await myDb!.rawQuery(
      '''
        SELECT COUNT(*) 
        FROM master_table 
        WHERE `name` =? AND `process` =?
      ''',
      [name,type],
    ),
  );
  if(rewrite == 0){
    await myDb.rawInsert(
      'INSERT INTO master_table (list, name, type, process) VALUES (?, ?, ?, ?)',
      [ jsonList, name, type, process],
    );
  }
  else{
    await sqlDb.updateData(
        '''
              UPDATE master_table
              SET 
                list = $jsonList
              WHERE name = $name
            '''
    );
  }
}