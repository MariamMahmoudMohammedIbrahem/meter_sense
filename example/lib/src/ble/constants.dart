import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
SqlDb sqlDb = SqlDb();
late int response;
late int response1;
bool isFunctionCalled = false;
int maxOutputLength = 72*3;
String previousEventData = '';
num clientID = 0;
num totalReading = 0;
num pulses = 0;
num totalCredit = 0;
num totalCreditWater = 0;
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
late DateTime currentTime;
final deviceName = TextEditingController();
int valU = 1;
String electricSN = ' ';
String waterSN = ' ';
late String type;
bool isDeviceFound = false;
late String meterName;
late DiscoveredDevice dataStored;