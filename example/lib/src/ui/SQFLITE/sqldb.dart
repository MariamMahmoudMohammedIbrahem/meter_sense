

import 'dart:convert';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'eoip.db');
    Database mydb = await openDatabase(
        path, onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return mydb;
  }

  //version changed
  Future<void> _onUpgrade(Database db, int oldversion, int newversion) async {
    print("onUpgrade");
  }

  //JUST CALLED ONCE
  Future _onCreate(Database db, int version) async {
    //create meters table
    await db.execute('''
    CREATE TABLE "Meters"(
      'name' TEXT NOT NULL UNIQUE,
      'type' TEXT NOT NULL,
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
    'clientId' INTEGER NOT NULL,
    'type' TEXT NOT NULL,
    'process' TEXT NOT NULL
    )
    ''');
  }

  //SELECT
  Future<List<Map>> readData(String sql) async {
    Database? mydb = await db;
    //take returened data from database
    List<Map> response = await mydb!.rawQuery(sql);
    print("responsein read$response");
    return response;
  }

  Future<List<Map>> readMeterData(String title, String type, int i) async {
    Database? mydb = await db;
    response =[];
    print('object');
    if (type == 'Electricity') {
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
    else if (type == 'Water') {
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

  Future<List<Map>> read(String name, String type) async {
    Database? mydb = await db;
    String query = '';
    if(type == 'Electricity'){
      query = '''
        SELECT * FROM Electricity
        WHERE `title` =?
      ''';
    }
    else{
      query = '''
        SELECT * FROM Water
        WHERE `title` =?
      ''';
    }
    final response  = await mydb!.rawQuery(
      query,
      [name],
    );
    print("object => $response");
    return response;
  }
  Future<void> editingList(String name, int i) async {
    Database? mydb = await db;
    if(i == 1){
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
  Future<int> getRowCountFromDatabase() async {
    Database? mydb = await db;
    final queryResult = await mydb!.rawQuery('''
    SELECT `id` FROM master_table 
    ORDER BY id DESC 
    LIMIT 1
    ''');
    print(queryResult);
    final rowCount = queryResult[0]['id'] as int;

    return rowCount;
  }
  //INSERT
  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    //take returened data from database
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  //DELETE
  Future<int> deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
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
        // listName = result[0]['title'];
        // listClientId = result[0]['clientId'];
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
        listType = result[0]['type'];

        if (jsonListDynamic != null) {
          final String jsonList = jsonListDynamic as String;
          if (jsonList != null) {
            final List<dynamic> dynamicList = jsonDecode(jsonList) as List<dynamic>;
            myList = dynamicList.cast<int>();

            if (process == 'balance') {
              myList.insert(0, 0x09);
            } else {
              myList.insert(0, 0x10);
            }

            final random = Random();
            myList.add(random.nextInt(255));

            int sum = myList.fold(0, (previousValue, element) => previousValue + element);
            myList.add(sum);

            return myList;
          }
        }
      }
    }

    return myList;
  }

  Future<List<int>> getList(String? name,  String process) async {
  Database? mydb = await db;
  String query = '';
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
      // listName = result[0]['title'];
      // listClientId = result[0]['clientId'];
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
  else{
    myList = [];
    query = 'SELECT * FROM master_table WHERE `name` = ? AND `process` = ? ORDER BY id DESC LIMIT 1' ;
    final List<Map<String, dynamic>> result = await mydb!.rawQuery(
      query,
      [name,process],
    );
    if (result.isNotEmpty) {
      final dynamic jsonListDynamic = result[0]['list'];
      // listName = result[0]['name'];
      // listClientId = result[0]['clientId'];
      listType = result[0]['type'];
      final String? jsonList = jsonListDynamic as String?;
      if (jsonList != null) {
        final List<dynamic> dynamicList = jsonDecode(jsonList) as List<dynamic>;
        myList = dynamicList.cast<int>();
        // balance data
        if(process == 'balance'){
          myList.insert(0, 0x09);
          final random = Random();
          myList.insert(5, int.parse('${random.nextInt(255)}'));
          int sum = myList.fold(0, (previousValue, element) => previousValue + element);
          myList.add(sum);
          print(myList);
        }
        // tarrif data
        else{
          print("i = 3");
          myList.insert(0, 0x10);
          final random = Random();
          myList.add(int.parse('${random.nextInt(255)}'));
          int sum = myList.fold(0, (previousValue, element) => previousValue + element);
          myList.add(sum);
          print(myList);
        }
        return myList;
      }
    }
  }
  return myList;
}


    Future<void> saveList(List<int> myList, int clientId, String name, String type, String process) async {
    Database? mydb = await db;
    final jsonList = jsonEncode(myList);
    print('myList => $myList');
    print('client => $clientId');
    print('name => $name');
    print('type => $type');
    print('process => $process');
    await mydb!.rawInsert(
      'INSERT INTO master_table (list, clientId, name, type, process) VALUES (?, ?, ?, ?, ?)',
      [ jsonList, clientId, name, type, process],
    );
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
//UPDATE
/*
  Future<int> updateData(List<int> myList, int clientId) async {
    Database? mydb = await db;
    //take returened data from database
    int response = await mydb!.rawUpdate(
      'UPDATE master_table SET list = ? WHERE clientId = ?',
      ['$myList', clientId],
    );
    print("done");
    return response;
  }
  */

// Future<List<Map>> readWatData() async {
//   final response  = await sqlDb.readData("SELECT `name`,`type` FROM Meters WHERE type = ?",["Electricity"]);
//   return response;
// }