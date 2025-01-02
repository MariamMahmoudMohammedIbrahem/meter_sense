import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble_example/src/ble/functions.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../ble/constants.dart';
class SqlDb {

  static Database? _db;

  Future <Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    }
    else {
      return _db;
    }
  }

  Future<Database> initialDb() async {
    const password = 'eoIp28waad';
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'eoip.db');
    final mydb = await openDatabase(
        path, onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade, password: password);
    return mydb;
  }

  //version changed
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // print("onUpgrade");
  }

  //JUST CALLED ONCE
  Future _onCreate(Database db, int version) async {
    //create meters table
    // CHARGE 1 NO CHARGE 0
    await db.execute('''
    CREATE TABLE "Meters"(
      'name' TEXT NOT NULL UNIQUE,
      'balance' INTEGER NOT NULL,
      'tarrif' INTEGER NOT NULL,
      PRIMARY KEY ('name')
    )
    ''');
    //create electricity table
    await db.execute('''
    CREATE TABLE "Electricity"(
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'title' TEXT NOT NULL,
      'clientId' INTEGER NOT NULL,
      'totalReading' TEXT NOT NULL,
      'totalCredit' TEXT NOT NULL,
      'currentTarrif' TEXT NOT NULL,
      'valveStatus' TEXT NOT NULL,
      'leackageFlag' TEXT NOT NULL,
      'fraudFlag' TEXT NOT NULL,
      'currentConsumption' TEXT NOT NULL,
      'month1' TEXT NOT NULL,
      'month2' TEXT NOT NULL,
      'month3' TEXT NOT NULL,
      'month4' TEXT NOT NULL,
      'month5' TEXT NOT NULL,
      'month6' TEXT NOT NULL,
      'list' TEXT NOT NULL,
      'process' TEXT NOT NULL,
      'time' DATETIME NOT NULL
    )
    ''');
    //create water table
    await db.execute('''
    CREATE TABLE "Water"(
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'title' TEXT NOT NULL,
      'clientId' INTEGER NOT NULL,
      'totalReading' TEXT NOT NULL,
      'totalCredit' TEXT NOT NULL,
      'currentTarrif' TEXT NOT NULL,
      'valveStatus' TEXT NOT NULL,
      'leackageFlag' TEXT NOT NULL,
      'fraudFlag' TEXT NOT NULL,
      'currentConsumption' TEXT NOT NULL,
      'month1' TEXT NOT NULL,
      'month2' TEXT NOT NULL,
      'month3' TEXT NOT NULL,
      'month4' TEXT NOT NULL,
      'month5' TEXT NOT NULL,
      'month6' TEXT NOT NULL,
      'list' TEXT NOT NULL,
      'process' TEXT NOT NULL,
      'time' DATETIME NOT NULL
    )
    ''');
    //create master table
    //process is balance or tarrif or none
    await db.execute('''
    CREATE TABLE "master_table" (
    'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    'list' TEXT NOT NULL,
    'name' TEXT NOT NULL,
    'type' TEXT NOT NULL,
    'process' TEXT NOT NULL
    )
    ''');
  }
  //get the names of the meters
  Future<List<Map>> readData(String sql) async {
    final mydb = await db;
    //take returened data from database
    final List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  //get the data of previous connected meters
  Future<List<Map>> readMeterData(String title) async {
    final mydb = await db;
    response =[];
    if (kDebugMode) {
      print('object');
    }
    if (title.startsWith('Ele')) {
      if (eleMeters[title] == null) {
        eleMeters[title] = [0, 0, 0, 0, 0];
      }
      response = await mydb!.rawQuery(
        '''
          SELECT `title` , `currentTarrif`, `totalReading`, `totalCredit`, `currentConsumption` ,`valveStatus`
          FROM Electricity 
          WHERE `title` = ?
          ORDER BY `id` DESC 
          LIMIT 1
        ''',
        [title],
      );

      for (final map in response) {
        eleMeters[title]?[0] = num.parse(map['currentTarrif'].toString());
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
      response = await mydb!.rawQuery(
        '''
          SELECT `title`, `currentTarrif`, `totalReading`, `totalCredit`, `currentConsumption`, `valveStatus`
          FROM Water 
          WHERE `title` = ?
          ORDER BY `id` DESC 
          LIMIT 1
        ''',
        [title],
      );

      for (final map in response) {
        watMeters[title]?[0] = num.parse(map['currentTarrif'].toString());
        watMeters[title]?[1] = num.parse(map['totalReading'].toString());
        watMeters[title]?[2] = num.parse(map['totalCredit'].toString());
        watMeters[title]?[3] = num.parse(map['currentConsumption'].toString());
        watMeters[title]?[4] = num.parse(map['valveStatus'].toString());
      }
    }
    return response;
  }

  // get the data of the last days "history data"
  ///TODO: edit currentConsumption to
  Future<List<Map>> read(String name, String type) async {
    final mydb = await db;
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
    final response  = await mydb!.rawQuery(
      query,
      [name],
    );
    return response;
  }

  //graph data "months data"
  Future<void> editingList(String name) async {
    final mydb = await db;
    //electric
    if(name.startsWith('Ele')){
      const query = '''
    SELECT `month1`,`month2`,`month3`,`month4`,`month5`,`month6` 
    FROM Electricity
    WHERE `title` =?
    ORDER BY `id` DESC  
    LIMIT 1
  ''';
      final response = await mydb!.rawQuery(query,[name]);
      if (response.isNotEmpty) {
        final map = response.first;
        eleReadings = [
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
        eleReadings = [0,0,0,0,0,0];
      }
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

      final response = await mydb!.rawQuery(query,[name]);
      if (response.isNotEmpty) {
        final map = response.first;
        watReadings = [
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
        watReadings = [0.0];
      }
    }
  }

  //check if the meter has previous stored data or not
  Future<bool> isTableEmpty(String type, String name) async {
    final mydb = await db;
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
      await mydb!.rawQuery(query,[name]),
    );
    if(count != 0){
      final response = await mydb.rawQuery(query2,
        [name],);
      for(final map in response){
        time = map['time'].toString();
      }
    }
    return count == 0;
  }

  // retrieve the last time stored in the database
  Future<List<Map>> readTime(String name, String type) async{
    final mydb = await db;
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
    final response = await mydb!.rawQuery(query,
    [name],);
    for(final map in response){
      time = map['time'].toString();
    }
    return response;
  }

  //INSERT
  Future<int> insertData(String sql) async {
    final mydb = await db;
    final response = await mydb!.rawInsert(sql);
    return response;
  }

  //UPDATE
  Future<int> updateData(String sql) async {
    final mydb = await db;
    final response = await mydb!.rawUpdate(sql);
    return response;
  }

  // delete database
  Future mydeleteDatabase() async {
    final databasepath = await getDatabasesPath();
    final path = join(databasepath, 'eoip.db');
    await deleteDatabase(path);
  }

  Future<List<int>> getSpecifiedList(String? name, String process) async {
    final mydb = await db;
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
      final List<Map<String, dynamic>> result = await mydb!.rawQuery(
        query,
        [name,process],
      );
      if (result.isNotEmpty) {
        final dynamic jsonListDynamic = result[0]['list'];
        final jsonList = jsonListDynamic as String?;
        if (jsonList != null) {
          final dynamicList = jsonDecode(jsonList) as List<dynamic>;
          myList = dynamicList.cast<int>();
          masterValues(myList);
          if(listType == "Electricity") {myList[0] = 0xA1;}
          else {myList[0] = 0xA0;}
          // print("myList => $myList");
          return myList;
        }
      }
    }
    else {
      myList = [];
      query = 'SELECT * FROM master_table WHERE `name` = ? AND `process` = ? ORDER BY id DESC LIMIT 1';
      final List<Map<String, dynamic>> result = await mydb!.rawQuery(query, [name, process]);

      if (result.isNotEmpty) {
        final dynamic jsonListDynamic = result[0]['list'];
        // listType = result[0]['type'];
        if (jsonListDynamic != null) {
          final jsonList = jsonListDynamic as String;
          final dynamicList = jsonDecode(jsonList) as List<dynamic>;
          myList = dynamicList.cast<int>();
          final int sum = myList.fold(0, (previousValue, element) => previousValue + element);
          myList.add(sum);
          return myList;
        }
      }
    }

    return myList;
  }
//save the list in the master station page tarrif or balance
  Future<void> saveList(List<int> myList, String name, String type, String process) async {
    final mydb = await db;
    final jsonList = jsonEncode(myList);
    final rewrite = Sqflite.firstIntValue(
      await mydb!.rawQuery(
      '''
        SELECT COUNT(*) 
        FROM master_table 
        WHERE `name` =? AND `process` =?
      ''',
      [name,type],
      ),
    );
    if(rewrite == 0){
      await mydb.rawInsert(
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
}
//insert into electricity and water tables
Future<void> addData(String name) async {
  currentTime =DateFormat.MMMEd().format(DateTime.now());
  if(paddingType == "Electricity" ){
    final count  = await sqlDb.isTableEmpty('$paddingType', name);
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
    final count = await sqlDb.isTableEmpty('$paddingType', name);
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

Future<void> fetchData() async {
  balanceList.clear();
  tarrifList.clear();
  final testing = await sqlDb.readData('SELECT * FROM Meters');
  if (kDebugMode) {
    print('SELECT * FROM Meters $testing');
  }
  for (final map in testing) {
    if (!nameList.contains(map['name'].toString())){
      nameList.add(map['name'].toString());
    }
    balanceList.add(int.parse(map['balance'].toString()));
    tarrifList.add(int.parse(map['tarrif'].toString()));
  }
}