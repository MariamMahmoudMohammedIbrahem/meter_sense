

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/utils/utils.dart';

import '../../ble/constants.dart';

class SqlDb{

  static Database? _db;

  Future <Database?> get db async{
    if(_db == null){
      _db =  await initialDb();
      return _db;
    }
    else{
      return _db;
    }
  }

  Future<Database> initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'eoip.db');
    Database mydb = await openDatabase(path, onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return mydb;
  }

  //version changed
  Future<void> _onUpgrade(Database db, int oldversion , int newversion)async {
    print("onUpgrade");
    // await db.execute("ALTER TABLE meter ADD COLUMN color TEXT");
  }

  //JUST CALLED ONCE
  Future _onCreate(Database db, int version) async {
    print("create");
    await db.execute('''
    CREATE TABLE "Electricity"(
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'title' TEXT NOT NULL,
      'clientId' INTEGER NOT NULL,
      'totalReading' TEXT NOT NULL,
      'pulses' TEXT NOT NULL,
      'totalCredit' TEXT NOT NULL,
      'currentTarrif' TEXT NOT NULL,
      'tarrifVersion' TEXT NOT NULL,
      'valveStatus' TEXT NOT NULL,
      'leackageFlag' TEXT NOT NULL,
      'fraudFlag' TEXT NOT NULL,
      'fraudHours' TEXT NOT NULL,
      'fraudMinutes' TEXT NOT NULL,
      'fraudDayOfWeek' TEXT NOT NULL,
      'fraudDayOfMonth' TEXT NOT NULL,
      'fraudMonth' TEXT NOT NULL,
      'fraudYear' TEXT NOT NULL,
      'totalDebit' TEXT NOT NULL,
      'currentConsumption' TEXT NOT NULL,
      'lcHour' TEXT NOT NULL,
      'lcMinutes' TEXT NOT NULL,
      'lcDayWeek' TEXT NOT NULL,
      'lcDayMonth' TEXT NOT NULL,
      'lcMonth' TEXT NOT NULL,
      'lcYear' TEXT NOT NULL,
      ' lastChargeValueNumber' TEXT NOT NULL,
      'month1' TEXT NOT NULL,
      'month2' TEXT NOT NULL,
      'month3' TEXT NOT NULL,
      'month4' TEXT NOT NULL,
      'month5' TEXT NOT NULL,
      'month6' TEXT NOT NULL,
      'warningLimit' TEXT NOT NULL,
      'time' DATETIME NOT NULL
    )
    ''');
    await db.execute('''
    CREATE TABLE "Water"(
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'title' TEXT NOT NULL,
      'data' TEXT NOT NULL,
      'time' DATETIME NOT NULL
    )
    ''');
    await db.execute('''
    CREATE TABLE "Meters"(
      'name' TEXT NOT NULL UNIQUE,
      'type' TEXT NOT NULL
    )
    ''');
    // Batch batch = db.batch();
    // batch.execute(
    //   '''
    //   CREATE TABLE "ELECTRICITY" (
    //   'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    //   'title' TEXT NOT NULL,
    //   'data' TEXT NOT NULL
    //   )
    //   '''
    // );
    // batch.execute(
    //     '''
    //   CREATE TABLE "WATER" (
    //   'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    //   'title' TEXT NOT NULL,
    //   'data' TEXT NOT NULL
    //   )
    //   '''
    // );
    // await batch.commit();
    print("create");
  }

  //SELECT
  Future<List<Map>> readData(String sql) async{
    Database? mydb = await db ;
    //take returened data from database
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }
  Future<void> editingList() async {
    Database? mydb = await db;
    const query = '''
    SELECT `month1`,`month2`,`month3`,`month4`,`month5`,`month6` 
    FROM Electricity
    ORDER BY `month1` DESC  
    LIMIT 1
  ''';

    final response = await mydb!.rawQuery(query);
    print("res:$response");
    if (response.isNotEmpty) {
      final map = response.first;
      readings = [
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
      readings = [0.0];
    }
    print("readings$readings");
  }


  //INSERT
  Future<int> insertData(String sql) async{
    Database? mydb = await db ;
    //take returened data from database
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  //UPDATE
  Future<int> updateData(String sql) async{
    Database? mydb = await db ;
    //take returened data from database
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  //DELETE
  Future<int> deleteData(String sql) async{
    Database? mydb = await db ;
    //take returened data from database
    int response = await mydb!.rawDelete(sql);
    return response;
  }

  // delete database
  Future mydeleteDatabase()async{
    String databasepath = await getDatabasesPath();
    String path = join(databasepath,'eoip.db');
    await deleteDatabase(path);
  }

  Future<int> getMetersTableLength() async {
    const sql = 'SELECT COUNT(*) as count FROM Meters';
    final result = await sqlDb.readData(sql);

    if (result.isNotEmpty) {
      final count = result.first['count'] as int;
      return count;
    } else {
      return 0; // Return 0 if the table is empty or there's an error.
    }
  }
  // Future<List<Map<String, dynamic>>> queryElectricityData() async {
  //   Database? mydb = await db ;
  //   final result = await mydb!.query('Electricity');
  //   return result;
  // }

}