import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:permission_handler/permission_handler.dart';
SqlDb sqlDb = SqlDb();
bool isFunctionCalled = false;
List<num> eleMeter = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
List<num> watMeter = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
late DateTime now;
late String time;
late String meterName;
const interval = Duration(seconds: 1);
List<String> nameList = [];
List<int> balanceList = [];
List<int> tarrifList = [];
dynamic paddingType;
List<double> eleReadings =[];
List<double> watReadings =[];
List<Color> gradientColors = [
  Colors.grey,
  Colors.grey.shade500,
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
late List<int> subscribeOutput;
Map<String, List<num>> eleMeters = {};
Map<String, List<num>> watMeters = {};
bool updated = true;

///*Permissions Directory**
PermissionStatus locationWhenInUse = PermissionStatus.denied;
PermissionStatus statusCamera = PermissionStatus.denied;
PermissionStatus statusBluetoothConnect = PermissionStatus.denied;

///*DEVICE-INTERACTION-TAB**
var start = 0;
List<int> previousEventData = [];
late Timer timer;
StreamSubscription<List<int>>? subscribeStream;

///*MASTER-STATION**
num clientID = 0;
num currentTarrif = 0;
num currentBalance = 0;
String? selectedName ;
final random = Random();
bool charging = false;

///*FUNCTIONS**
late String currentTime;
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

///*DEVICE-LIST**
int index = 0;
bool availability = false;
bool toggle = false; //english
String icon = 'icons/masterStation.png';
String barcodeScanRes = '';

///*SQLDB**
List<Map> response = [];
String query = '';
String query2='';