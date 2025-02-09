import 'commons.dart';

SqlDb sqlDb = SqlDb();
bool isFunctionCalled = false;
List<num> meterData = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];///edited
late String time;
late String meterName;
const timerInterval = Duration(seconds: 1);
List<String> nameList = [];
List<int> balanceList = [];
List<int> tariffList = [];
dynamic paddingType;
// List<double> eleReadings =[0,0,0,0,0,0];
// List<double> watReadings =[0,0,0,0,0,0];
List<double> meterReadings =[0,0,0,0,0,0];

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
late Timer timer;
StreamSubscription<List<int>>? subscribeStream;
List<int> dateTime = [];

///*MASTER-STATION**
num clientID = 0;
num totalReadings = 0;
num pulses = 0;
num totalReadingsPulses = 0;
num currentBalance = 0;
num currentTariff = 0;
num currentTariffVersion = 0;

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

///*SQLDB**
List<Map> response = [];
String query = '';
String query2='';

List<int> zeroingBalance = [0x0B, 0X00, 0x00, 0X00, 0x00, 0x0B];
List<int> zeroingChargeNumber = [0x09, 0X00, 0x00, 0X00, 0x00, 0x09];
int counter = 0;