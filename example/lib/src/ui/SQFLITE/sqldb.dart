

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      'id' TEXT NOT NULL PRIMARY KEY,
      'name' TEXT NOT NULL,
      'serviceData' TEXT NOT NULL,
      'serviceUuids' TEXT NOT NULL,
      'manufacturerData' TEXT NOT NULL,
      'rssi' INTEGER NOT NULL,
      'connectable' ENUM NOT NULL
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

}