part of 'device_interaction_screen.dart';

abstract class DeviceInteractionController extends State<DeviceInteractionScreen>{

  bool isLoading = false;
  StreamSubscription<List<int>>? balanceTariff;
  StreamSubscription<List<int>>? dateTimeListener;
  StreamSubscription<List<int>>? resettingChargeListener;
  List<int> previousEventData = [];
  num eleMeterOld = -1000000;
  num watMeterOld = -1000000;
  bool recharge = false;
  @override
  void initState() {
    subscribeOutput = [];
    counter = 0;
    eleMeterOld = -1000000;
    watMeterOld = -1000000;
    recharge = false;
    setState(() {
      timer = Timer.periodic(timerInterval, (timer) {
        if (start == 15) {
          if (widget.viewModel.connectionStatus !=
              DeviceConnectionState.connected) {
            widget.viewModel.disconnect();
            showToast(
                TKeys.timeOut.translate(context), Colors.red, Colors.white);
          }
          timer.cancel();
          setState(() {
            start = 0;
            isLoading = false;
          });
        } else {
          if (!widget.viewModel.deviceConnected && start == 0) {
            widget.viewModel.connect();
          } else if (subscribeOutput.length != 72 &&
              widget.viewModel.deviceConnected) {
            isLoading = true;
            subscribeCharacteristic();
            widget.writeWithoutResponse(widget.characteristic, [0x59]);
          } else if (subscribeOutput.length == 72 &&
              widget.viewModel.deviceConnected) {
            setState(() {
              if (paddingType == "Electricity") {
                calculateElectric(subscribeOutput, widget.name);
              } else {
                calculateElectric(subscribeOutput, widget.name);
              }
            });
            timer.cancel();
            isLoading = false;
            showToast(TKeys.upToDate.translate(context),
                MyColors.lightGreen, Colors.black);
          }
          setState(() {
            start++;
          });
        }
      });
    });
    super.initState();
  }

  void connecting(){
    if (widget.viewModel.connectionStatus ==
        DeviceConnectionState.connecting ||
        widget.viewModel.connectionStatus ==
            DeviceConnectionState.connected) {
      widget.viewModel.disconnect();
    } else if (widget.viewModel.connectionStatus ==
        DeviceConnectionState.disconnecting ||
        widget.viewModel.connectionStatus ==
            DeviceConnectionState.disconnected) {
      widget.viewModel.connect();
    }
  }

  void deviceWidgetInteracting () {
    editingList(widget.name).then((value) {
      // if (paddingType == "Electricity") {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => DeviceHistoryScreen(
              name: widget.name,
            ),
          ),
        );
      /*} else {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => WaterData(
              name: widget.name,
            ),
          ),
        );
      }*/
    });
  }

  Future<void> refreshing () async{
    Future.delayed(const Duration(seconds: 1), () {
      subscribeOutput = [];
      setState(() {
        timer = Timer.periodic(timerInterval, (timer) {
          if (start == 15) {
            showToast(TKeys.timeOut.translate(context), Colors.red, Colors.white);
            timer.cancel();
            setState(() {
              start = 0;
              isLoading = false;
            });
          } else {
            setState(() {
              start++;
            });
            if (!widget.viewModel.deviceConnected) {
              widget.viewModel.connect();
            } else if (subscribeOutput.length != 72) {
              isLoading = true;
              subscribeCharacteristic();
              widget.writeWithoutResponse(widget.characteristic, [0x59]);
            } else if (subscribeOutput.length == 72) {
              setState(() {
                if (paddingType == "Electricity") {
                  isFunctionCalled = false;
                  calculateElectric(subscribeOutput, widget.name);
                } else {
                  calculateElectric(subscribeOutput, widget.name);
                }
                if(((paddingType == 'Electricity' && meterData[3] > eleMeterOld && counter > 1) || (paddingType == 'Water' && meterData[3] > watMeterOld && counter > 1))&&recharge){
                  balanceCond = false;
                  sqlDb.updateData('''
                UPDATE Meters
                SET
                balance = 0
                WHERE name = '${widget.name}'
              ''');
                  Fluttertoast.showToast(
                    msg: TKeys.chargeSuccess.translate(context),
                  );
                }
              });
              isLoading = false;
              showToast(TKeys.upToDate.translate(context),
                  const Color(0xff4CAF50), Colors.black);
              timer.cancel();
            }
          }
        });
      });
    });
  }

  Future<void> subscribeCharacteristic() async {
    var newEventData = <int>[];
    subscribeOutput = [];
    await balanceTariff?.cancel();
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
          print(event);
          newEventData = event;
          if (event.first == 89 && subscribeOutput.isEmpty) {
            subscribeOutput += newEventData;
            previousEventData = newEventData;
          } else if (subscribeOutput.length < 72 && subscribeOutput.isNotEmpty) {
            final equal = (previousEventData.length == newEventData.length) &&
                const ListEquality<int>().equals(previousEventData, newEventData);
            if (!equal) {
              subscribeOutput += newEventData;
              previousEventData = newEventData;
            } else {
              newEventData = [];
            }
          } else if (subscribeOutput.length == 72) {
            checkSum(subscribeOutput);
            subscribeStream?.cancel();
          }
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

  Future<void> startTimer() async {
    await subscribeStream?.cancel();
    await balanceTariff?.cancel();
    if (balanceCond && !tariffCond) {
      await getSpecifiedList(widget.name, 'balance');
      if (myList.first == 9) {
        print('myList is => $myList');
        if(watMeterOld == -1000000 && paddingType=='Water') {
          watMeterOld = meterData[3];
        } else if(eleMeterOld == -1000000) {
          eleMeterOld = meterData[3];
        }
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTariff = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          print('event $event');
          setState(() {
            if (event.length == 1) {
              if (event.first == 9) {
                balanceCond = false;
                sqlDb.updateData('''
                UPDATE Meters
                SET
                balance = 0
                WHERE name = '${widget.name}'
              ''');
                balanceTariff?.cancel();
                Fluttertoast.showToast(
                  msg: TKeys.chargeSuccess.translate(context),
                );
              }
            }
          });
        });
      }
    }
    else if (tariffCond && !balanceCond) {
      await getSpecifiedList(widget.name, 'tariff');
      if (myList.first == 16) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTariff = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          setState(() {
            if (event.length == 1) {
              if (event.first == 0x10) {
                tariffCond = false;
                sqlDb.updateData('''
                UPDATE Meters
                SET
                tariff = 0
                WHERE name = '${widget.name}'
              ''');
                balanceTariff?.cancel();
                Fluttertoast.showToast(
                  msg: TKeys.chargeSuccess.translate(context),
                );
              }
            }
          });
        });
      }
    }
    else if (tariffCond && balanceCond) {
      await getSpecifiedList(widget.name, 'tariff');
      if (myList.first == 16) {
        await widget.writeWithoutResponse(widget.characteristic, myList);
        balanceTariff = widget
            .subscribeToCharacteristic(widget.characteristic)
            .listen((event) {
          setState(() {
            if (event.length == 1) {
              if (event.first == 0x10) {
                tariffCond = false;
                getSpecifiedList(widget.name, 'balance').then((value) => {
                  if(watMeterOld == -1000000 && paddingType=='Water') {
                    watMeterOld = meterData[3],
                  } else if(eleMeterOld == -1000000) {
                    eleMeterOld = meterData[3],
                  },
                  widget.writeWithoutResponse(widget.characteristic, myList),
                });
              }
              if (event.first == 9) {
                balanceCond = false;
                sqlDb.updateData('''
              UPDATE Meters
              SET
              balance = 0,
              tariff = 0
              WHERE name = '${widget.name}'
              ''');
                balanceTariff?.cancel();
                Fluttertoast.showToast(
                  msg: TKeys.chargeSuccess.translate(context),
                );
              }
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

  void checkSum(List<int> response) {
    final checksum = response.last;
    final calculatedSum = response.sublist(0, response.length - 1).reduce((a, b) => a + b) & 0xFF;

    if (calculatedSum != checksum) {
      subscribeOutput.clear();
    }
  }
  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    timer.cancel();
    Fluttertoast.cancel();
    // watMeter = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    meterData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    super.dispose();
  }
}