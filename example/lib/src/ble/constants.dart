import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:permission_handler/permission_handler.dart';
SqlDb sqlDb = SqlDb();
bool isFunctionCalled = false;
List<num> eleMeter = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];///edited
List<num> watMeter = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];///edited
late DateTime now;
late String time;
late String meterName;
const timerInterval = Duration(seconds: 1);
List<String> nameList = [];
List<int> balanceList = [];
List<int> tariffList = [];
dynamic paddingType;
List<double> eleReadings =[0,0,0,0,0,0];
List<double> watReadings =[0,0,0,0,0,0];
List<Color> gradientColors = [
  const Color(0xff4CAF50),
  Colors.grey.shade500,
];
List<int> myList = [];
dynamic listType = "";
var monthList = <String>[];
bool balanceCond = false;
bool tariffCond = false;
late List<int> subscribeOutput;
Map<String, List<num>> eleMeters = {};
Map<String, List<num>> watMeters = {};

///*Permissions Directory**
PermissionStatus locationWhenInUse = PermissionStatus.denied;
PermissionStatus statusCamera = PermissionStatus.denied;
PermissionStatus statusBluetoothConnect = PermissionStatus.denied;

///*DEVICE-INTERACTION-TAB**
var start = 0;
List<int> previousEventData = [];
late Timer timer;
StreamSubscription<List<int>>? subscribeStream;
bool isLoading = false;
StreamSubscription<List<int>>? balanceTariff;
StreamSubscription<List<int>>? dateTimeListener;
List<int> dateTime = [];

///*MASTER-STATION**
num clientID = 0;
num totalReadings = 0;
num pulses = 0;
num totalReadingsPulses = 0;
num currentBalance = 0;
num currentTariff = 0;
num currentTariffVersion = 0;
String? selectedName ;
final random = Random();
bool charging = false;
// bool updated = true;
bool updatingMaster = false;
num tariffMaster = 0;
num tariffVersionMaster = 0;
List<int> balance = [];
num balanceMaster = 0;
List<int> tariff = [];

///*FUNCTIONS**
late String currentTime;
final conversionIndices = [
  1,   // clientID
  5,   //total reading
  9,   // pulses
  11,  // totalCredit
  15,  // currentTariff
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
  27,  // total debit
];

final conversionSizes = [
  4,   // clientID
  4,   //totalReading
  2,   // pulses
  4,   // totalCredit
  1,   // currentTariff
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
  4,   // total debit
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

List<int> zeroing = [0x17, 03, 0xE5, 0xff];
// num tempCredit = 0.0;
num eleMeterOld = -1000000;
num watMeterOld = -1000000;
int counter = 0;
bool recharge = false;
/*
final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
GlobalKey<RefreshIndicatorState>();*/