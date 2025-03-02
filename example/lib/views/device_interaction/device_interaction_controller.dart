part of 'device_interaction_screen.dart';

abstract class DeviceInteractionController extends State<DeviceInteractionScreen>{

  bool isLoading = false;
  StreamSubscription<List<int>>? balanceTariff;
  StreamSubscription<List<int>>? dateTimeListener;
  StreamSubscription<List<int>>? resettingChargeListener;
  var previousEventData = <int>[];
  var newEventData = <int>[];
  num lastChargeNumber = 0;
  num chargeNumberStation = 0;
  bool recharge = false;

  List<int> zeroingBalance = [0x0B, 0X00, 0x00, 0X00, 0x00, 0x0B];
  List<int> zeroingChargeNumber = [0x09, 0X00, 0x00, 0X00, 0x00, 0x09];
  int retryAttempts = 0;
  final int maxRetries = 3; // Max retry attempts before timeout

  @override
  void initState() {
    super.initState();
    subscribeOutput = [];
    counter = 0;
    start = 0;
    recharge = false;

    getSpecifiedList(widget.name, 'balance').whenComplete(() =>
    chargeNumberStation = myList[myList.length-2]
    );
    if (widget.viewModel.connectionStatus !=
        DeviceConnectionState.connected) {
      connecting();
    } else {
      startConnectionTimer();
    }
  }
  void connecting() {
    if (widget.viewModel.connectionStatus == DeviceConnectionState.connected ||
        widget.viewModel.connectionStatus == DeviceConnectionState.connecting) {
      widget.viewModel.disconnect();
    } else {
      widget.viewModel.connect();
      startConnectionTimer();  // Reusing timer function
    }
  }

  void deviceWidgetInteracting () {
    editingList(widget.name).then((value) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => DeviceHistoryScreen(
              name: widget.name,
            ),
          ),
        );
    });
  }



  Future<void> refreshing () async {
    subscribeOutput.clear();
    isLoading = true;
    start = 0;
    timer.cancel();
    if (widget.viewModel.connectionStatus != DeviceConnectionState.connected) {
      connecting();
    } else {
      startConnectionTimer();
    }
  }

  void subscribeCharacteristic() {
    subscribeStream?.cancel(); // Cancel any existing subscription
    subscribeOutput.clear(); // Clear previous data

    subscribeStream = widget.subscribeToCharacteristic(widget.characteristic)
        .listen((event) {

          if (event.isEmpty) return;
          newEventData = event;
          if (newEventData.first == 89 && subscribeOutput.isEmpty) {
            // Case 1: First packet, start accumulating data
            subscribeOutput += newEventData;
            previousEventData = newEventData;
          } else if (subscribeOutput.length < 72 && subscribeOutput.isNotEmpty) {
            // Case 2: Continue accumulating if data length < 72
            final isDuplicate = (previousEventData.length == newEventData.length) &&
                const ListEquality<int>().equals(previousEventData, newEventData);

            if (!isDuplicate) {
              subscribeOutput += newEventData;
              previousEventData = newEventData;
            } else {
              newEventData = []; // Ignore duplicate data
            }
          }

      if (subscribeOutput.length >= 72) {
        lastChargeNumber = subscribeOutput[45];
        final calculatedSum = checkSum(subscribeOutput);
        if (calculatedSum != subscribeOutput.last) {
          subscribeOutput.clear();
          subscribeStream?.cancel();
        }
      }
    }, onError: (error) {
      debugPrint("Subscription error: $error");
    }, onDone: () {
      debugPrint("Subscription completed.");
    });
  }

  Future<void> setDateAndTime() async{
    await widget.writeWithoutResponse(
        widget.characteristic, composeDateTimePacket());
    dateTimeListener =widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
      if(event.first == 13){
        dateTimeListener?.cancel();
        startTimer();
      } else{
        setDateAndTime();
      }
    });
  }

  Future<void> resettingCharge() async {
    await widget.writeWithoutResponse(widget.characteristic,zeroingBalance);
    resettingChargeListener = widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
      if(event.first == zeroingBalance.first){
        widget.writeWithoutResponse(widget.characteristic, zeroingChargeNumber);
        resettingChargeListener?.cancel();
      }
    });
    await refreshing();
  }

  void startConnectionTimer() {
    timer = Timer.periodic(timerInterval, (timer) {
      print(start);
      start++;
      if (widget.viewModel.connectionStatus == DeviceConnectionState.connected) {
        if(start < 15) {
          if (subscribeOutput.length < 72) {
            setState(() {
              isLoading = true;
            });
            subscribeCharacteristic();
            widget.writeWithoutResponse(widget.characteristic, [0x59]);
          } else {
            isFunctionCalled = false;
            calculateMeterData(subscribeOutput, widget.name);
            if (lastChargeNumber == chargeNumberStation) {
              if(tariffCond) {
                updateDatabase("tariff");
                tariffCond = false;
              }
              if(balanceCond) {
                updateDatabase("balance");
                balanceCond = false;
              }
            }
            setState(() {
              isLoading = false;
            });
            showToast(TKeys.upToDate.translate(context), MyColors.lightGreen,
                Colors.black);
            timer.cancel();
          }
        } else {
          start = 0;
        }
      } else if (start == 5) {
        start = 0;
        widget.viewModel.disconnect();
        if(retryAttempts>maxRetries){
          timer.cancel();
          showToast(TKeys.connectionFailed.translate(context), MyColors.lightGreen, Colors.black);
        } else {
          widget.viewModel.connect();
          showToast(TKeys.reconnect.translate(context), MyColors.lightGreen, Colors.black);
        }
        retryAttempts++;
      }
    });
  }

  Future<void> cancelSubscriptions() async {
    await subscribeStream?.cancel();
    await balanceTariff?.cancel();
  }

  void updateDatabase(String column) {
    sqlDb.updateData('''
    UPDATE Meters
    SET
    $column = 0
    WHERE name = '${widget.name}'
  ''');
  }

  Future<void> startTimer() async {
    await cancelSubscriptions();

    if (balanceCond || tariffCond) {
      await getSpecifiedList(widget.name, balanceCond ? 'balance' : 'tariff');

      if (myList.first == (balanceCond ? 9 : 16)) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTariff = widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
          print(event);
          setState(() {
            if (event.length == 1) {
              if (event.first == 9) {
                balanceCond = false;
                updateDatabase('balance');
              } else if (event.first == 0x10) {
                tariffCond = false;
                updateDatabase('tariff');
              }
              balanceTariff?.cancel();
              Fluttertoast.showToast(
                msg: TKeys.chargeSuccess.translate(context),
              );
            }
          });
        });
      }
    } else {
      await balanceTariff?.cancel();
    }

    recharge = true;
    await refreshing();
  }

  @override
  void dispose() {
    cancelSubscriptions();
    widget.viewModel.disconnect();
    timer.cancel();
    Fluttertoast.cancel();
    start = 0;
    meterData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    super.dispose();
  }
}