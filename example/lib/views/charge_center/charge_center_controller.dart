part of 'charge_center_screen.dart';

abstract class ChargeCenterController extends State<ChargeCenterScreen>{

  String? selectedName ;
  bool charging = false;
  num tariffMaster = 0;
  num tariffVersionMaster = 0;
  List<int> balance = [];
  num balanceMaster = 0;
  List<int> tariff = [];

  @override
  void initState() {
    timer = Timer.periodic(timerInterval, (timer) {
      if (start == 15) {
        if (widget.viewModel.connectionStatus !=
            DeviceConnectionState.connected) {
          widget.viewModel.disconnect();
          showToast(TKeys.timeOut.translate(context), Colors.red, Colors.white);
        }
        timer.cancel();
        start = 0;
      } else {
        if (widget.viewModel.connectionStatus ==
            DeviceConnectionState.disconnected &&
            start == 0) {
          widget.viewModel.connect();
        }
        start++;
      }
    });
    widget.viewModel.connect();
    fetchData();
    super.initState();
  }

  Future<void> writeCharacteristicWithoutResponse() async {
    const chunkSize = 20;
    print(myList);
    for (var i = 0; i < myList.length; i += chunkSize) {
      var end = i + chunkSize;
      if (end > myList.length) {
        end = myList.length;
      }
      final chunk = myList.sublist(i, end);
      await widget.writeWithoutResponse(widget.characteristic, chunk);
    }
  }

  Future<void> subscribeCharacteristic() async {
    if (subscribeStream!=null){
      await subscribeStream!.cancel();
    }
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
          if (event.first == 0xA3 || event.first == 0xA5) {
            print(event);
            setState(() {
              tariff = [];
              tariff
                ..insert(0, 0x10)
                ..addAll(event.sublist(1, 13));
              setState(() {
                tariffMaster = convertToInt(event, 1, 11);
                tariffVersionMaster = convertToInt(event, 1, 2);
              });

            });
          }
          if (event.first == 0xA4 || event.first == 0xA6) {
            balance = [];
            balance
              ..insert(0, 0x09)
              ..addAll(event.sublist(1, 6));
            setState(() {
              balanceMaster = convertToInt(event, 1, 4) / 100;
            });
            widget.writeWithoutResponse(widget.characteristic,[0xBB]);
            if (balance.isNotEmpty &&
                tariff.isEmpty) {
                saveList(
                    balance,
                    '$selectedName',
                    '$listType',
                    'balance').then((value) {

                    sqlDb.updateData('''
                      UPDATE Meters
                      SET balance = 1
                      WHERE name = '$selectedName'
                      ''');}
                );
            } else if (tariff.isNotEmpty &&
                balance.isEmpty) {
              saveList(
                  tariff,
                  '$selectedName',
                  '$listType',
                  'tariff').then((value) =>
                  sqlDb.updateData('''
                                              UPDATE Meters
                                              SET tariff = 1
                                              WHERE name = '$selectedName'
                                              '''));
            } else {
              saveList(
                  balance,
                  '$selectedName',
                  '$listType',
                  'balance').then((value) =>
                  saveList(
                      tariff,
                      '$selectedName',
                      '$listType',
                      'tariff').then((value) =>
                      sqlDb.updateData('''
                                              UPDATE Meters
                                              SET
                                              balance = 1,
                                              tariff = 1
                                              WHERE name = '$selectedName'
                                              '''),),
              );
            }


          }
        });

  }

  Future<void> refreshing() async {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (!widget.viewModel.deviceConnected) {
          widget.viewModel.connect();
        } else if (widget.viewModel.deviceConnected) {
          subscribeCharacteristic();
        }
      });
    });
  }

  void connecting() {
    if (widget.viewModel.connectionStatus ==
        DeviceConnectionState.connecting ||
        widget.viewModel.connectionStatus ==
            DeviceConnectionState.connected) {
      widget.viewModel.disconnect();
      start = 0;
      timer.cancel();
    } else if (widget.viewModel.connectionStatus ==
        DeviceConnectionState.disconnecting ||
        widget.viewModel.connectionStatus ==
            DeviceConnectionState.disconnected) {
      timer = Timer.periodic(timerInterval, (timer) {
        if (start == 15 ||
            widget.viewModel.connectionStatus ==
                DeviceConnectionState.connected) {
          if (widget.viewModel.connectionStatus !=
              DeviceConnectionState.connected) {
            widget.viewModel.disconnect();
            showToast(TKeys.timeOut.translate(context), Colors.red, Colors.white);
          }
          timer.cancel();
          start = 0;
        } else {
          widget.viewModel.connect();
          start++;
        }
      });
    }
  }

  void selectingMeter(String? value) {
      setState(() {
        selectedName = value;
        myList = [];
        balanceMaster = 0;
        tariffMaster = 0;
        tariffVersionMaster = 0;
        getSpecifiedList(value, 'none');
        charging = false;
      });
  }

  Future<void> submittingMeterData() async {
    if (!widget.viewModel.deviceConnected) {
      widget.viewModel.connect();
    } else {
      await writeCharacteristicWithoutResponse();
      Timer(const Duration(seconds: 2), () async {
        await widget.writeWithoutResponse(
            widget.characteristic, [0xAA]);
        await subscribeCharacteristic();
      });
      setState(() {
        charging = true;
      });
      showToast(TKeys.dataSent.translate(context), MyColors.lightGreen, Colors.white);
    }
  }

  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    timer.cancel();
    start = 0;
    selectedName = null;
    charging = false;
    clientID = 0;
    currentBalance = 0;
    tariffMaster = 0;
    balanceMaster = 0;
    tariff = [];
    super.dispose();
  }
}