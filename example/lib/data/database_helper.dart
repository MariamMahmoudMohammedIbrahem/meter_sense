import '../commons.dart';

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
    final path = join(databasePath, 'meterSense.db');
    final myDb = await openDatabase(
        path, onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade, password: password);
    return myDb;
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
      'tariff' INTEGER NOT NULL,
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
      'currentTariff' TEXT NOT NULL,
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
      'currentTariff' TEXT NOT NULL,
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
    //process is balance or tariff or none
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
    final myDb = await db;
    //take returned data from database
    final List<Map> response = await myDb!.rawQuery(sql);
    return response;
  }

  //INSERT
  Future<int> insertData(String sql) async {
    final myDb = await db;
    final response = await myDb!.rawInsert(sql);
    return response;
  }

  //UPDATE
  Future<int> updateData(String sql) async {
    final myDb = await db;
    final response = await myDb!.rawUpdate(sql);
    return response;
  }

  /*// delete database
  Future myDeleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'eoip.db');
    await deleteDatabase(path);
  }*/

  Future deleteRow(String table, String rowName, String rowNameData) async {
    final myDb = await db;
    await myDb!.delete(table,where: '$rowName=?',whereArgs: [rowNameData]);
  }
}