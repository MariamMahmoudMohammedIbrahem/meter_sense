import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/dataPage.dart';
import 'package:flutter_reactive_ble_example/src/ui/SQFLITE/sqldb.dart';
import 'package:flutter_reactive_ble_example/src/ui/device_detail/device_list.dart';
import 'package:provider/provider.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:sqflite/sqflite.dart';
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

class CharacteristicInteractionDialog extends StatelessWidget {
  const CharacteristicInteractionDialog({
    required this.characteristic,
    Key? key,
  }) : super(key: key);
  final QualifiedCharacteristic characteristic;

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceInteractor>(
      builder: (context, interactor, _) => _CharacteristicInteractionDialog(
            characteristic: characteristic,
            readCharacteristic: interactor.readCharacteristic,
            writeWithResponse: interactor.writeCharacteristicWithResponse,
            writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
            subscribeToCharacteristic: interactor.subScribeToCharacteristic,
          ));
}

class _CharacteristicInteractionDialog extends StatefulWidget {
  const _CharacteristicInteractionDialog({
    required this.characteristic,
    required this.readCharacteristic,
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
    Key? key,
  }) : super(key: key);

  final QualifiedCharacteristic characteristic;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;

  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;

  @override
  _CharacteristicInteractionDialogState createState() =>
      _CharacteristicInteractionDialogState();
}

class _CharacteristicInteractionDialogState
    extends State<_CharacteristicInteractionDialog> {
  SqlDb sqlDb = SqlDb();
  late String readOutput;
  late String writeOutput;
  late String subscribeOutput;
  // late List output;
  late TextEditingController textEditingController;
  late StreamSubscription<List<int>>? subscribeStream;

  @override
  void initState() {
    readOutput = '';
    writeOutput = '';
    subscribeOutput = '';
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    super.dispose();
  }
  /*void callFunctionOnce() {
    if (!isFunctionCalled) {
      isFunctionCalled = true;
      addData(); // Call the function you want to execute once
    }
  }
  void addData() async {
    currentTime = DateTime.now();
    response = await sqlDb.insertData(
        '''
                              INSERT INTO meter (`data`,`title`,`time`)
                              VALUES ("${clientID.toString()}","$meterName","$currentTime")
                              '''
    );
  }*/
  Future<void> subscribeCharacteristic() async {
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
          String newEventData = event.join(', ',);
          setState(() {
            if (newEventData != previousEventData) {
              previousEventData = newEventData;
              if (subscribeOutput.length >= maxOutputLength) {
                //data cutting
                clientID = convertToInt(subscribeOutput, 1, 4);//000153 = 153
                totalReading = convertToInt(subscribeOutput, 5, 4);//0000
                pulses = convertToInt(subscribeOutput, 9, 2);//00
                totalCredit = convertToInt(subscribeOutput, 11, 4);//00,46,224 = 828
                currentTarrif = convertToInt(subscribeOutput, 15, 1);//0
                tarrifVersion = convertToInt(subscribeOutput, 16, 2);//0,1,4 = 20
                valveStatus = convertToInt(subscribeOutput, 18, 1);//1 = 1
                leackageFlag = convertToInt(subscribeOutput, 19, 1);//0
                fraudFlag = convertToInt(subscribeOutput, 20, 1);//0
                fraudHours = convertToInt(subscribeOutput, 21, 1);//0
                fraudMinutes = convertToInt(subscribeOutput, 22, 1);//0
                fraudDayOfWeek = convertToInt(subscribeOutput, 23, 1);//0
                fraudDayOfMonth = convertToInt(subscribeOutput, 24, 1);//0
                fraudMonth = convertToInt(subscribeOutput, 25, 1);//0
                fraudYear = convertToInt(subscribeOutput, 26, 1);//0
                totalDebit = convertToInt(subscribeOutput, 27, 4);//0000
                currentConsumption = convertToInt(subscribeOutput, 31, 4);//0007 = 7
                lcHour = convertToInt(subscribeOutput, 35, 1);//23
                lcMinutes = convertToInt(subscribeOutput, 36, 1);//2
                lcDayWeek = convertToInt(subscribeOutput, 37, 1);//3
                lcDayMonth = convertToInt(subscribeOutput, 38, 1);//7
                lcMonth = convertToInt(subscribeOutput, 39, 1);//22
                lcYear = convertToInt(subscribeOutput, 40, 1);//0
                lastChargeValueNumber = convertToInt(subscribeOutput, 41, 5);//0,46*16*16*16,224*16*16,208*16,0 = 772672768
                month1 = convertToInt(subscribeOutput, 46, 4);//0000
                month2 = convertToInt(subscribeOutput, 50, 4);//0000
                month3 = convertToInt(subscribeOutput, 54, 4);//0000
                month4 = convertToInt(subscribeOutput, 58, 4);//0000
                month5 = convertToInt(subscribeOutput, 62, 4);//0000
                month6 = convertToInt(subscribeOutput, 66, 4);//0000
                warningLimit = convertToInt(subscribeOutput, 70, 1);//10
                checkSum = convertToInt(subscribeOutput, 71, 1);//56
                // Reset the output
                // previousEventData = '';
                subscribeOutput = '${event.join(', ')}, ';
                // callFunctionOnce();
              }
              else{
                subscribeOutput += '$newEventData, ';
              }
            }
          });
    });
    setState(() {
      subscribeOutput = '';
    });
  }

  Future<void> readCharacteristic() async {
    final result = await widget.readCharacteristic(widget.characteristic);
    setState(() {
      readOutput = result.toString();
    });
  }

  List<int> _parseInput() => textEditingController.text
      .split(',')
      .map(
        int.parse,
      )
      .toList();

  Future<void> writeCharacteristicWithResponse() async {
    await widget.writeWithResponse(widget.characteristic, [89]);
    setState(() {
      writeOutput = 'Ok';
    });
  }

  Future<void> writeCharacteristicWithoutResponse() async {
    await widget.writeWithoutResponse(widget.characteristic, _parseInput());
    setState(() {
      writeOutput = 'Done';
    });
  }

  Widget sectionHeader(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  List<Widget> get writeSection => [
        sectionHeader('Write characteristic'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: textEditingController,
            onChanged: (value){

            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Value',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: (){
                subscribeCharacteristic();
                writeCharacteristicWithResponse();
              },

              child: const Text('With response'),
            ),
            ElevatedButton(
              onPressed: writeCharacteristicWithoutResponse,
              child: const Text('Without response'),
            ),
          ],
        ),
    ElevatedButton(
      onPressed: () {
        if(response>0) {
          // Navigator.of(context).pushAndRemoveUntil<void>(
          //   MaterialPageRoute<void>(builder: (context) => const StoreData()),
          //       (route) => false,
          // );
        }
      },
      child: const Text('data stored'),
    ),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 8.0),
          child: Text('Output: $writeOutput'),
        ),
      ];

  List<Widget> get readSection => [
        sectionHeader('Read characteristic'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: readCharacteristic,
              child: const Text('Read'),
            ),
            Text('Output: $readOutput'),
          ],
        ),
      ];

  List<Widget> get subscribeSection => [
        sectionHeader('Subscribe / notify'),
        Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: subscribeCharacteristic,
              child: const Text('Subscribe'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('clientID: $clientID'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('totalReading: $totalReading'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('pulses: $pulses'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('totalCredit: $totalCredit'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('currentTarrif: $currentTarrif'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('tarrifVersion: $tarrifVersion'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('valveStatus: $valveStatus'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('leackageFlag: $leackageFlag'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('fraudFlag: $fraudFlag'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('fraudHour: $fraudHours'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('fraudMinutes  : $fraudMinutes  '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('fraudDayOfWeek : $fraudDayOfWeek '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('fraudDayOfMonth : $fraudDayOfMonth'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('fraudMonth : $fraudMonth'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('fraudYear : $fraudYear'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('totalDebit : $totalDebit '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('currentConsumption : $currentConsumption '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('lcHour : $lcHour '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('lcMinutes : $lcMinutes '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('lcDayWeek : $lcDayWeek '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('lcDayMonth : $lcDayMonth '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('lcMonth : $lcMonth '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('lcYear : $lcYear '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('lastChargeValueNumber : $lastChargeValueNumber '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('month1 : $month1 '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('month2 : $month2 '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('month3 : $month3 '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('month4 : $month4 '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('month5 : $month5 '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('month6 : $month6 '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('warningLimit : $warningLimit '),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: Text('checkSum : $checkSum '),
            ),
            // Padding(
            //   padding: const EdgeInsetsDirectional.only(top: 8.0),
            //   child: Text('summing : $sum '),
            // ),
          ],
        ),
      ];

  Widget get divider => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Divider(thickness: 2.0),
      );

  @override
  Widget build(BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Select an operation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  widget.characteristic.characteristicId.toString(),
                ),
              ),
              divider,
              ...readSection,
              divider,
              ...writeSection,
              divider,
              ...subscribeSection,
              divider,
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('close')),
                ),
              )
            ],
          ),
        ),
      );
}

num convertToInt(String data, int start, int size) {
  List<String> dataArrayTwoDgit = data.split(", ");
  List<String> buffer = List<String>.filled(size, '');
  StringBuffer sb = StringBuffer();
  StringBuffer hex = StringBuffer();
  for (int x = start, y = 0; x < start + size && y < size; x++, y++) {
    buffer[y] = dataArrayTwoDgit[x];
    int value = int.parse(buffer[y]);
    var hexadecimalValue = value.toRadixString(16).toUpperCase().padLeft(2, '0');
    sb.write(buffer[y]);
    hex.write(hexadecimalValue);
  }
  String hexa = hex.toString();
  int converted = int.parse(hexa, radix: 16);
  return converted;

}
