///device_interaction_controller
// functions before optimization

/*@override
  void initState() {
    subscribeOutput = [];
    counter = 0;
    start = 0;
    recharge = false;
    getSpecifiedList(widget.name, 'balance').whenComplete(() =>
      chargeNumberStation = myList[myList.length-2]
    );
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
              calculateMeterData(subscribeOutput, widget.name);
            });
            timer.cancel();
            start = 0;
            isLoading = false;
            showToast(TKeys.upToDate.translate(context),
                MyColors.lightGreen, Colors.black);
          }
            start++;
        }
      });
    });
    super.initState();
  }*/

/*Future<void> refreshing () async{
    Future.delayed(const Duration(seconds: 1), () {
      subscribeOutput = [];
        timer = Timer.periodic(timerInterval, (timer) {
          if (start == 15) {
            showToast(TKeys.timeOut.translate(context), Colors.red, Colors.white);
            timer.cancel();
            setState(() {
              start = 0;
              isLoading = false;
            });
          } else {
              start++;
            if (!widget.viewModel.deviceConnected) {
              widget.viewModel.connect();
            } else if (subscribeOutput.length != 72) {
              setState(() {
                isLoading = true;
              });
              subscribeCharacteristic();
              widget.writeWithoutResponse(widget.characteristic, [0x59]);
            } else if (subscribeOutput.length == 72) {
                isFunctionCalled = false;
                calculateMeterData(subscribeOutput, widget.name);
                if(lastChargeNumber == chargeNumberStation && (tariffCond||balanceCond)) {
                      sqlDb.updateData('''
                    UPDATE Meters
                    SET
                    balance = 0
                    WHERE name = '${widget.name}'
                  ''');
                }
                setState((){isLoading = false;});
              showToast(TKeys.upToDate.translate(context),
                  MyColors.lightGreen, Colors.black);
              timer.cancel();
              start = 0;
            }
          }
        });
    });
  }*/


/*void connecting(){
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
      timer = Timer.periodic(timerInterval, (timer) {
        start++;
        if(widget.viewModel.connectionStatus == DeviceConnectionState.connected) {
          start = 0;
          timer.cancel();
        } else if (start == 15 && widget.viewModel.connectionStatus != DeviceConnectionState.connected) {
          start = 0;
          timer.cancel();
          widget.viewModel.disconnect();
        }
      });
    }
  }*/

/*Future<void> subscribeCharacteristic() async {
    if (subscribeStream!=null){
      await subscribeStream!.cancel();
    }
    if (balanceTariff!=null){
      await balanceTariff!.cancel();
    }
    var newEventData = <int>[];
    subscribeOutput = [];

    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
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
            lastChargeNumber = convertToInt(subscribeOutput, 45, 1);
            final calculatedSum = checkSum(subscribeOutput);
            if (calculatedSum != subscribeOutput.last) {
              subscribeOutput.clear();
              subscribeStream?.cancel();
            }
          }
        });
  }*/

/*Future<void> startTimer() async {
    if (balanceTariff!=null){
      await balanceTariff!.cancel();
    }
    if (subscribeStream!=null){
      await subscribeStream!.cancel();
    }
    if (balanceCond && !tariffCond) {
      await getSpecifiedList(widget.name, 'balance');
      if (myList.first == 9) {
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
                print('2');
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
                print('4');
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
  }*/

