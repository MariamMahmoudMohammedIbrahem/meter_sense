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
    final mydb = await db;
    //take returned data from database
    final List<Map> response = await mydb!.rawQuery(sql);
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

  /*// delete database
  Future mydeleteDatabase() async {
    final databasepath = await getDatabasesPath();
    final path = join(databasepath, 'eoip.db');
    await deleteDatabase(path);
  }*/
}
//insert into electricity and water tables
Future<void> addData(String name) async {
  currentTime =DateFormat.MMMEd().format(DateTime.now());
  if(paddingType == "Electricity" ){
    final count  = await isTableEmpty('$paddingType', name);
    if(count){
      await sqlDb.insertData(
          '''
                              INSERT INTO Electricity (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTariff`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${meterData[0]}","$name","${meterData[1].toString()}","${meterData[3].toString()}","${meterData[4].toString()}","${meterData[5].toString()}","${meterData[6].toString()}","${meterData[7].toString()}","${meterData[8].toString()}","${meterData[9].toString()}","${meterData[10].toString()}","${meterData[11].toString()}","${meterData[12].toString()}","${meterData[13].toString()}","${meterData[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
      );
    }
    else{
      await readTime(name, '$paddingType');
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
    final count = await isTableEmpty('$paddingType', name);
    //IF TABLE IS EMPTY insert the data
    if(count){
      await sqlDb.insertData(
          '''
                              INSERT INTO Water (`clientId`,`title`,`totalReading`,`totalCredit`,`currentTariff`,`valveStatus`,`leackageFlag`,`fraudFlag`,`currentConsumption`,`month1`,`month2`,`month3`,`month4`,`month5`,`month6`,`list`,`process`,`time`)
                              VALUES ("${meterData[0]}","$name","${meterData[1].toString()}","${meterData[3].toString()}","${meterData[4].toString()}","${meterData[5].toString()}","${meterData[6].toString()}","${meterData[7].toString()}","${meterData[8].toString()}","${meterData[9].toString()}","${meterData[10].toString()}","${meterData[11].toString()}","${meterData[12].toString()}","${meterData[13].toString()}","${meterData[14].toString()}","$subscribeOutput","none","$currentTime")
        '''
      );
    }
    //else if the table is not empty
    else{
      //if time == time stored in the database update the row where title = name of the selected meter
      await readTime(name, '$paddingType');
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

Future<void> fetchData() async {
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
  final mydb = await sqlDb.db;
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
    response = await mydb!.rawQuery(
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
  final mydb = await sqlDb.db;
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
  final mydb = await sqlDb.db;
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

    final response = await mydb!.rawQuery(query,[name]);
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
  }
}

//check if the meter has previous stored data or not
Future<bool> isTableEmpty(String type, String name) async {
  final mydb = await sqlDb.db;
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
  final mydb = await sqlDb.db;
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

Future<List<int>> getSpecifiedList(String? name, String process) async {
  final mydb = await sqlDb.db;
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
        int sum = myList.fold(0, (previousValue, element) => previousValue + element);
        myList.add(sum);
        return myList;
      }
    }
  }

  return myList;
}
//save the list in the master station page tariff or balance
Future<void> saveList(List<int> myList, String name, String type, String process) async {
  final mydb = await sqlDb.db;
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