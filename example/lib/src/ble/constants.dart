import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:permission_handler/permission_handler.dart';
SqlDb sqlDb = SqlDb();
bool isFunctionCalled = false;
List<int> previousEventData = [];
List<num> eleMeter = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
List<num> watMeter = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
late DateTime now;
late String currentTime;
late String time;
late String meterName;
const interval = Duration(seconds: 1);
List<String> nameList = [];
List<int> balanceList = []; //get if there is balances for the meters
List<int> tarrifList = [];
int index = 0;
String? selectedName ;
late Timer timer;
dynamic paddingType;
List<double> eleReadings =[]; // months data
List<double> watReadings =[];
List<Color> gradientColors = [
  Colors.grey,
  Colors.grey.shade500,
];
final conversionIndices = [
  1,   // clientID
  5,   //total reading
  9,   // pulses
  11,  // totalCredit
  15,  // currentTarrif
  18,  // valveStatus
  19,  // leackageFlag
  20,  // fraudFlag
  31,  // currentConsumption
  46,  // month1
  50,  // month2
  54,  // month3
  58,  // month4
  62,  // month5
  66,  // month6
];

final conversionSizes = [
  4,   // clientID
  4,   //totalReading
  2,   // pulses
  4,   // totalCredit
  1,   // currentTarrif
  1,   // valveStatus
  1,   // leackageFlag
  1,   // fraudFlag
  4,   // currentConsumption
  4,   // month1
  4,   // month2
  4,   // month3
  4,   // month4
  4,   // month5
  4,   // month6
];
List<int> myList = [];
List<int> balance = [];
num balanceMaster = 0;
List<int> tarrif = [];
num tarrifMaster = 0;
dynamic listType = "";
var monthList = <String>[];
bool cond = false;
bool cond0 = false;
// String scanBarcode = 'Unknown';
Color color1 = Colors.red.shade900;
late List<DiscoveredService> discoveredServices;
late List<int> subscribeOutput;
StreamSubscription<List<int>>? subscribeStream;
final myInstance = SqlDb();
bool availability = false;
List<Map> response = [];
bool toggle = false; //english
String icon = 'icons/masterStation.png';
Map<String, List<num>> eleMeters = {};
Map<String, List<num>> watMeters = {};
bool recharged = false;
bool updated = false;
String query = '';
String query2='';
String barcodeScanRes = '';
final random = Random();

// List<double> data = [10.0,20.0,50.0,30.0,40.0,25.0];
// bool showAvg = false;
// List<int> testing =[];
// String DEVID = "";
// dynamic listName = "";
// List<int> subList =[];
// int lastValue = 0;
// String? time;
// String? month;
// String eleName = '';
// String watName = '';
// Color color3 = Colors.grey;
// String ids = '';
// String ids2 = '';
// bool isEleEnabled = false;
// bool isWatEnabled = false;
// bool newData = true;
bool visible = false;
// List<num> cutting = [0,0,0,0];
// bool write = true;
// String signalStrength = '';
// Future<int> rowCount = sqlDb.getRowCountFromDatabase();
// String testValue ='';
// num tarrifVersion = 0;
// Completer<void> subscriptionCompleter = Completer<void>();
// Set<String> name = <String>{};
///*Permissions Directory**
PermissionStatus statusLocation = PermissionStatus.denied;
PermissionStatus statusCamera = PermissionStatus.denied;