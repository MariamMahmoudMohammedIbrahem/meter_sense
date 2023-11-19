import 'dart:async';
import 'dart:convert';

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
    String password = 'eoIp28waad';
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'eoip.db');
    Database mydb = await openDatabase(
        path, onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade, password: password);
    return mydb;
  }

  //version changed
  Future<void> _onUpgrade(Database db, int oldversion, int newversion) async {
    print("onUpgrade");
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
    Database? mydb = await db;
    //take returened data from database
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  //get the data of previous connected meters
  Future<List<Map>> readMeterData(String title) async {
    Database? mydb = await db;
    response =[];
    print('object');
    if (title.startsWith('Ele')) {
      if (eleMeters[title] == null) {
        eleMeters[title] = [0, 0, 0, 0];
      }
      response = await mydb!.rawQuery(
        '''
          SELECT `title` , `currentTarrif`, `totalReading`, `totalCredit`, `currentConsumption` 
          FROM Electricity 
          WHERE `title` = ?
          ORDER BY `id` DESC 
          LIMIT 1
        ''',
        [title],
      );

      for (Map<dynamic, dynamic> map in response) {
        eleMeters[title]?[0] = num.parse(map['currentTarrif'].toString());
        eleMeters[title]?[1] = num.parse(map['totalReading'].toString());
        eleMeters[title]?[2] = num.parse(map['totalCredit'].toString());
        eleMeters[title]?[3] = num.parse(map['currentConsumption'].toString());
      }
      print("electric $title: $response");
    }
    else if (title.startsWith('W')) {
      if (watMeters[title] == null) {
        watMeters[title] = [0, 0, 0, 0];
      }
      response = await mydb!.rawQuery(
        '''
          SELECT `title`, `currentTarrif`, `totalReading`, `totalCredit`, `currentConsumption` 
          FROM Water 
          WHERE `title` = ?
          ORDER BY `id` DESC 
          LIMIT 1
        ''',
        [title],
      );

      for (Map<dynamic, dynamic> map in response) {
        watMeters[title]?[0] = num.parse(map['currentTarrif'].toString());
        watMeters[title]?[1] = num.parse(map['totalReading'].toString());
        watMeters[title]?[2] = num.parse(map['totalCredit'].toString());
        watMeters[title]?[3] = num.parse(map['currentConsumption'].toString());
      }

      print("water $title: $response");
    }
    return response;
  }

  // get the data of the last days "history data"
  Future<List<Map>> read(String name, String type) async {
    Database? mydb = await db;
    String query = '';
    if(type == 'Electricity'){
      query = '''
        SELECT `currentConsumption`, `time` FROM Electricity
        WHERE `title` =?
        ORDER BY id DESC
        LIMIT 10
      ''';
    }
    else{
      query = '''
        SELECT `currentConsumption`, `time` FROM Water
        WHERE `title` =?
        ORDER BY id DESC
        LIMIT 10
      ''';
    }
    final response  = await mydb!.rawQuery(
      query,
      [name],
    );
    print("object => $response");
    return response;
  }

  //graph data "months data"
  Future<void> editingList(String name, String type) async {
    Database? mydb = await db;
    //electric
    if(type == "Electricity"){
      const query = '''
    SELECT `month1`,`month2`,`month3`,`month4`,`month5`,`month6` 
    FROM Electricity
    WHERE `title` =?
    ORDER BY `id` DESC  
    LIMIT 1
  ''';
      final response = await mydb!.rawQuery(query,[name]);
      print("res[]:$response");
      if (response.isNotEmpty) {
        final map = response.first;
        eleReadings = [
          map['month1'],
          map['month2'],
          map['month3'],
          map['month4'],
          map['month5'],
          map['month6'],
        ].map((value) {
          if (value is double) {
            return value;
          } else if (value is String) {
            final parsedValue = double.tryParse(value);
            if (parsedValue != null) {
              return parsedValue;
            } else {
              return 0.0;
            }
          } else {
            return 0.0;
          }
        }).toList();
      } else {
        eleReadings = [];
      }
      print("readings$eleReadings");
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
      print("res:$response");
      if (response.isNotEmpty) {
        final map = response.first;
        watReadings = [
          map['month1'],
          map['month2'],
          map['month3'],
          map['month4'],
          map['month5'],
          map['month6'],
        ].map((value) {
          if (value is double) {
            return value;
          } else if (value is String) {
            final parsedValue = double.tryParse(value);
            if (parsedValue != null) {
              return parsedValue;
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
      print("readings$watReadings");
    }
  }

  //check if the meter has previous stored data or not
  Future<bool> isTableEmpty(String type, String name) async {
    Database? mydb = await db;
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
      final response = await mydb!.rawQuery(query2,
        [name],);
      for(var map in response){
        time = map['time'].toString();
      }
    }
    print("count $count");
    return count == 0;
  }

  // retrieve the last time stored in the database
  Future<List<Map>> readTime(String name, String type) async{
    Database? mydb = await db;
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
    for(var map in response){
      time = map['time'].toString();
    }
    return response;
  }

  //INSERT
  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  //UPDATE
  Future<int> updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  // delete database
  Future mydeleteDatabase() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'eoip.db');
    await deleteDatabase(path);
  }

  Future<List<int>> getSpecifiedList(String? name, String process) async {
    Database? mydb = await db;
    String query = '';

    // if(process == 'none'){
    //   if(name!.startsWith('W')){
    //     query = 'SELECT `list`,`title`,`clientId` FROM Water WHERE `title` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
    //     listType = 'Water';
    //   }
    //   else if(name!.startsWith('E')){
    //     query = 'SELECT `list`,`title`,`clientId` FROM Electricity WHERE `title` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
    //     listType = 'Electricity';
    //   }
    //   final List<Map<String, dynamic>> result = await mydb!.rawQuery(
    //     query,
    //     [name,process],
    //   );
    //   if (result.isNotEmpty) {
    //     final dynamic jsonListDynamic = result[0]['list'];
    //     // listName = result[0]['title'];
    //     // listClientId = result[0]['clientId'];
    //     final String? jsonList = jsonListDynamic as String?;
    //     if (jsonList != null) {
    //       final List<dynamic> dynamicList = jsonDecode(jsonList) as List<dynamic>;
    //       myList = dynamicList.cast<int>();
    //       if(listType == "Electricity") {myList[0] = 0xA1;}
    //       else {myList[0] = 0xA0;}
    //       print("myList => $myList");
    //       return myList;
    //     }
    //   }
    // }
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
        final String? jsonList = jsonListDynamic as String?;
        if (jsonList != null) {
          final List<dynamic> dynamicList = jsonDecode(jsonList) as List<dynamic>;
          myList = dynamicList.cast<int>();
          if(listType == "Electricity") {myList[0] = 0xA1;}
          else {myList[0] = 0xA0;}
          print("myList => $myList");
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
          final String jsonList = jsonListDynamic as String;
          final List<dynamic> dynamicList = jsonDecode(jsonList) as List<dynamic>;
          myList = dynamicList.cast<int>();
          int sum = myList.fold(0, (previousValue, element) => previousValue + element);
          myList.add(sum);
          return myList;
        }
      }
    }

    return myList;
  }
//save the list in the master station page tarrif or balance
  Future<void> saveList(List<int> myList, String name, String type, String process) async {
    Database? mydb = await db;
    final jsonList = jsonEncode(myList);
    print('saved successfully');
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
    // myList.insert(0, 0x09);
    // myList.add(random.nextInt(255));
    if(rewrite == 0){
      await mydb.rawInsert(
        'INSERT INTO master_table (list, name, type, process) VALUES (?, ?, ?, ?)',
        [ jsonList, name, type, process],
      );
    }
    else{
      print('update');
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

// Future<void> updateList(int id, String newValue) async {
//   Database? mydb = await db;
//   await mydb!.rawUpdate('UPDATE master_table SET list = ? WHERE id = ?', [newValue, id]);
// }
// Retrieve the list from the database to send to master station
// Future<List<int>> getList(String? name,  String process) async {
//   Database? mydb = await db;
//   String query = '';
//   if(process == 'none'){
//     if(name!.startsWith('W')){
//       listType = 'Water';
//     }
//     else{
//       query = 'SELECT `list`,`title`,`clientId` FROM Electricity WHERE `title` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
//       listType = 'Electricity';
//     }
//     final List<Map<String, dynamic>> result = await mydb!.rawQuery(
//       query,
//       [name,process],
//     );
//     if (result.isNotEmpty) {
//       final dynamic jsonListDynamic = result[0]['list'];
//       // listName = result[0]['title'];
//       // listClientId = result[0]['clientId'];
//       final String? jsonList = jsonListDynamic as String?;
//       if (jsonList != null) {
//         final List<dynamic> dynamicList = jsonDecode(jsonList) as List<dynamic>;
//         myList = dynamicList.cast<int>();
//         if(listType == "Electricity") {myList[0] = 0xA1;}
//         else {myList[0] = 0xA0;}
//         print("myList => $myList");
//         return myList;
//       }
//     }
//   }
//   else{
//     myList = [];
//     query = 'SELECT * FROM master_table WHERE `name` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
//     final List<Map<String, dynamic>> result = await mydb!.rawQuery(
//       query,
//       [name,process],
//     );
//     if (result.isNotEmpty) {
//       final dynamic jsonListDynamic = result[0]['list'];
//       // listName = result[0]['name'];
//       // listClientId = result[0]['clientId'];
//       listType = result[0]['type'];
//       final String? jsonList = jsonListDynamic as String?;
//       if (jsonList != null) {
//         final List<dynamic> dynamicList = jsonDecode(jsonList) as List<dynamic>;
//         myList = dynamicList.cast<int>();
//         // balance data
//         if(process == 'balance'){
//           myList.insert(0, 0x09);
//           final random = Random();
//           myList.insert(5, int.parse('${random.nextInt(255)}'));
//           int sum = myList.fold(0, (previousValue, element) => previousValue + element);
//           myList.add(sum);
//           print(myList);
//         }
//         // tarrif data
//         else{
//           print("i = 3");
//           myList.insert(0, 0x10);
//           final random = Random();
//           myList.add(int.parse('${random.nextInt(255)}'));
//           int sum = myList.fold(0, (previousValue, element) => previousValue + element);
//           myList.add(sum);
//           print(myList);
//         }
//         return myList;
//       }
//     }
//   }
//   return myList;
// }

//wrong sotred data
/*
  Future<void> saveList(List<int> myList, int clientId, String name, String type) async {
    Database? mydb = await db;
    final jsonList = jsonEncode(myList);
    final existingRows = await mydb!.rawQuery(
      'SELECT list FROM master_table WHERE `clientId` = ?',
      [clientId],
    );

    bool listMatched = false;

    for (final row in existingRows) {
      List<int> storedList = (jsonDecode(row['list'] as String) as List<dynamic>).cast<int>();

      if (storedList.length == myList.length) {
        bool listsMatch = true;
        if (listsMatch) {
          listMatched = true;
          break;
        }
      }
    }

    if (listMatched) {
      await mydb.rawUpdate(
        'UPDATE master_table SET `list` = ? WHERE name = ? AND type = ? AND clientId = ?',
        [jsonList, name, type, clientId],
      );
      print("Updated");
    } else {
      await mydb!.rawInsert(
        'INSERT INTO master_table (list, clientId, name, type) VALUES (?, ?, ?, ?)',
        [jsonList, clientId, name, type],
      );
      print("Inserted");
    }
  }
*/


// Future<List<Map>> readWatData() async {
//   final response  = await sqlDb.readData("SELECT `name`,`type` FROM Meters WHERE type = ?",["Electricity"]);
//   return response;
// }

//   Future<List<int>> getList(String? name,  String process) async {
//   Database? mydb = await db;
//   String query = '';
//   if(process == 'none'){
//     if(name!.startsWith('W')){
//       query = 'SELECT `list`,`title`,`clientId` FROM Water WHERE `title` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
//       listType = 'Water';
//     }
//     else{
//       query = 'SELECT `list`,`title`,`clientId` FROM Electricity WHERE `title` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
//       listType = 'Electricity';
//     }
//     final List<Map<String, dynamic>> result = await mydb!.rawQuery(
//       query,
//       [name,process],
//     );
//     if (result.isNotEmpty) {
//       final dynamic jsonListDynamic = result[0]['list'];
//       // listName = result[0]['title'];
//       // listClientId = result[0]['clientId'];
//       final String? jsonList = jsonListDynamic as String?;
//       if (jsonList != null) {
//         final List<dynamic> dynamicList = jsonDecode(jsonList) as List<dynamic>;
//         myList = dynamicList.cast<int>();
//         if(listType == "Electricity") {myList[0] = 0xA1;}
//         else {myList[0] = 0xA0;}
//         print("myList => $myList");
//         return myList;
//       }
//     }
//   }
//   else{
//     myList = [];
//     query = 'SELECT * FROM master_table WHERE `name` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
//     final List<Map<String, dynamic>> result = await mydb!.rawQuery(
//       query,
//       [name,process],
//     );
//     if (result.isNotEmpty) {
//       final dynamic jsonListDynamic = result[0]['list'];
//       // listName = result[0]['name'];
//       // listClientId = result[0]['clientId'];
//       listType = result[0]['type'];
//       final String? jsonList = jsonListDynamic as String?;
//       if (jsonList != null) {
//         final List<dynamic> dynamicList = jsonDecode(jsonList) as List<dynamic>;
//         myList = dynamicList.cast<int>();
//         // balance data
//         if(process == 'balance'){
//           myList.insert(0, 0x09);
//           final random = Random();
//           myList.insert(5, int.parse('${random.nextInt(255)}'));
//           int sum = myList.fold(0, (previousValue, element) => previousValue + element);
//           myList.add(sum);
//           print(myList);
//         }
//         // tarrif data
//         else{
//           print("i = 3");
//           myList.insert(0, 0x10);
//           final random = Random();
//           myList.add(int.parse('${random.nextInt(255)}'));
//           int sum = myList.fold(0, (previousValue, element) => previousValue + element);
//           myList.add(sum);
//           print(myList);
//         }
//         return myList;
//       }
//     }
//   }
//   return myList;
// }
// Future<int> getRowCountFromDatabase() async {
//   Database? mydb = await db;
//   final queryResult = await mydb!.rawQuery('''
//     SELECT `id` FROM master_table
//     ORDER BY id DESC
//     LIMIT 1
//     ''');
//   print(queryResult);
//   final rowCount = queryResult[0]['id'] as int;
//
//   return rowCount;
// }
// Future<int> deleteData(String sql) async {
//   Database? mydb = await db;
//   int response = await mydb!.rawDelete('DROP TABLE IF EXISTS Water');
//   return response;
// }
