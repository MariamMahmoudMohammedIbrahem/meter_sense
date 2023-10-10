import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
SqlDb sqlDb = SqlDb();
bool isFunctionCalled = false;
bool enter = false;
List<int> previousEventData = [];
// electric data
num clientID = 0;
num totalReading = 0;
num pulses = 0;
num totalCredit = 0;
num currentTarrif = 0;
num tarrifVersion = 0;
num valveStatus = 0;
num leackageFlag = 0;
num fraudFlag = 0;
num fraudHours = 0;
num fraudMinutes = 0;
num fraudDayOfWeek = 0;
num fraudDayOfMonth = 0;
num fraudMonth = 0;
num fraudYear = 0;
num totalDebit = 0;
num currentConsumption = 0;
num lcHour = 0;
num lcMinutes = 0;
num lcDayWeek = 0;
num lcDayMonth = 0;
num lcMonth = 0;
num lcYear = 0;
num  lastChargeValueNumber = 0;
num month1 = 0;
num month2 = 0;
num month3 = 0;
num month4 = 0;
num month5 = 0;
num month6 = 0;
num warningLimit = 0;
num checkSum = 0;
int sum = 0;
num test = 89;
//water data

num clientIDWater = 0;
num totalReadingWater = 0;
num pulsesWater = 0;
num totalCreditWater = 0;
num currentTarrifWater = 0;
num tarrifVersionWater = 0;
num valveStatusWater = 0;
num leackageFlagWater = 0;
num fraudFlagWater = 0;
num fraudHoursWater = 0;
num fraudMinutesWater = 0;
num fraudDayOfWeekWater = 0;
num fraudDayOfMonthWater = 0;
num fraudMonthWater = 0;
num fraudYearWater = 0;
num totalDebitWater = 0;
num currentConsumptionWater = 0;
num lcHourWater = 0;
num lcMinutesWater = 0;
num lcDayWeekWater = 0;
num lcDayMonthWater = 0;
num lcMonthWater = 0;
num lcYearWater = 0;
num lastChargeValueNumberWater = 0;
num month1Water = 0;
num month2Water = 0;
num month3Water = 0;
num month4Water = 0;
num month5Water = 0;
num month6Water = 0;
num warningLimitWater = 0;
num checkSumWater = 0;
late DateTime now;
late String currentTime;
// final deviceName = TextEditingController();
int valU = -1;
// String electricSN = ' ';
// String waterSN = ' ';
String type ="Electricity";
// bool isDeviceFound = false;
late String meterName;
late DiscoveredDevice dataStored;
// late String id;
// TextEditingController deviceNameController = TextEditingController();
const interval = Duration(seconds: 1);
// dynamic name;
List<String> nameList = [];
Set<String> name = <String>{};
List<String> typeList = [];
String? selectedName ;
// dynamic meterType;
late Timer timer;
// int count = 0;
dynamic paddingType;
List<double> data = [10.0,20.0,50.0,30.0,40.0,25.0];
List<double> eleReadings =[];
List<double> watReadings =[];
late String today;
List<Color> gradientColors = [
  Colors.grey,
  Colors.grey.shade500,
];
bool showAvg = false;
final conversionIndices = [
  1,   // clientID
  9,   // pulses
  11,  // totalCredit
  15,  // currentTarrif
  16,  // tarrifVersion
  18,  // valveStatus
  19,  // leackageFlag
  20,  // fraudFlag
  21,  // fraudHours
  22,  // fraudMinutes
  23,  // fraudDayOfWeek
  24,  // fraudDayOfMonth
  25,  // fraudMonth
  26,  // fraudYear
  27,  // totalDebit
  31,  // currentConsumption
  35,  // lcHour
  36,  // lcMinutes
  37,  // lcDayWeek
  38,  // lcDayMonth
  39,  // lcMonth
  40,  // lcYear
  41,  // lastChargeValueNumber
  46,  // month1
  50,  // month2
  54,  // month3
  58,  // month4
  62,  // month5
  66,  // month6
  70,  // warningLimit
  71,  // checkSum
];

final conversionSizes = [
  4,   // clientID
  2,   // pulses
  4,   // totalCredit
  1,   // currentTarrif
  2,   // tarrifVersion
  1,   // valveStatus
  1,   // leackageFlag
  1,   // fraudFlag
  1,   // fraudHours
  1,   // fraudMinutes
  1,   // fraudDayOfWeek
  1,   // fraudDayOfMonth
  1,   // fraudMonth
  1,   // fraudYear
  4,   // totalDebit
  4,   // currentConsumption
  1,   // lcHour
  1,   // lcMinutes
  1,   // lcDayWeek
  1,   // lcDayMonth
  1,   // lcMonth
  1,   // lcYear
  5,   // lastChargeValueNumber
  4,   // month1
  4,   // month2
  4,   // month3
  4,   // month4
  4,   // month5
  4,   // month6
  1,   // warningLimit
  1,   // checkSum
];
bool valve = true;
List<int> myList = [];
List<int> balance = [];
List<int> tarrif = [];
String DEVID = "";
dynamic listName = "";
dynamic listClientId = 0;
dynamic listType = "";
late int meterTable;
List<int> subList =[];
int lastValue = 0;
late Future <List<int>> currentBalance ;
late Future <List<int>> qwerTarrif ;
int selectedValue = -1; // Initialize with a default
String? time;
String? month;
var monthList = <String>[];
String eleName = '';
String watName = '';
bool cond = false;
bool cond0 = false;