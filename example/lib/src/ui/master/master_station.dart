
import '../../../commons.dart';

class MasterInteractionTab extends StatelessWidget {
  const MasterInteractionTab({
    required this.device,
    required this.characteristic,
    super.key,
  });
  final DiscoveredDevice device;
  final QualifiedCharacteristic characteristic;

  @override
  Widget build(BuildContext context) => Consumer4<BleDeviceConnector,
          ConnectionStateUpdate, BleDeviceInteractor, BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
                interactor, __) =>
            _MasterStation(
          viewModel: MasterInteractionViewModel(
              deviceId: device.id,
              connectableStatus: device.connectable,
              connectionStatus: connectionStateUpdate.connectionState,
              deviceConnector: deviceConnector,
              discoverServices: () =>
                  serviceDiscoverer.discoverServices(device.id)),
          characteristic: characteristic,
          writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
          subscribeToCharacteristic: interactor.subScribeToCharacteristic,
        ),
      );
}

@FunctionalData()
class MasterInteractionViewModel extends $DeviceInteractionViewModel {
  const MasterInteractionViewModel({
    required this.deviceId,
    required this.connectableStatus,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
  });

  @override
  final String deviceId;
  @override
  final Connectable connectableStatus;
  @override
  final DeviceConnectionState connectionStatus;
  @override
  final BleDeviceConnector deviceConnector;
  @override
  @CustomEquality(Ignore())
  final Future<List<Service>> Function() discoverServices;

  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class _MasterStation extends StatefulWidget {
  const _MasterStation({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
  });
  final MasterInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;

  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;

  @override
  State<_MasterStation> createState() => _MasterStationState();
}

class _MasterStationState extends State<_MasterStation> {
  @override
  Widget build(BuildContext context) {
    final nameLabelStyle = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 17,
    );

    final nameValueStyle = TextStyle(
      color: Colors.green.shade900,
      fontWeight: FontWeight.bold,
      fontSize: 19,
    );
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              if (!widget.viewModel.deviceConnected) {
                widget.viewModel.connect();
              } else if (widget.viewModel.deviceConnected) {
                subscribeCharacteristic();
              }
            });
          }),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .07),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TKeys.welcome.translate(context),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4CAF50),
                      ),
                      onPressed: () {
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
                      },
                      child: Text(
                        (widget.viewModel.connectionStatus ==
                                DeviceConnectionState.connected)
                            ? TKeys.disconnect.translate(context)
                            : (widget.viewModel.connectionStatus ==
                                    DeviceConnectionState.connecting)
                                ? TKeys.connecting.translate(context)
                                : (widget.viewModel.connectionStatus ==
                                        DeviceConnectionState.disconnected)
                                    ? TKeys.connect.translate(context)
                                    : TKeys.disconnecting.translate(context),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 2,
                        child: Text(
                          TKeys.choose.translate(context),
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )),
                    const Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: 1,
                        )),
                    Flexible(
                      flex: 2,
                      child: SizedBox(
                        height: 55,
                        child: PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              selectedName = value;
                              sqlDb.getSpecifiedList(value, 'none');
                              charging = false;
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            final items = <PopupMenuEntry<String>>[];
                            for (final item in nameList) {
                              items.add(
                                PopupMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              );
                              if (item != nameList.last) {
                                items.add(
                                  const PopupMenuDivider(),
                                );
                              }
                            }
                            return items;
                          },
                          offset: const Offset(0, 50),
                          tooltip: TKeys.selectDevice.translate(context),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedName ??
                                        TKeys.meter.translate(context),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: selectedName != null,
                  child: Container(
                    width: width * .86,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(
                        40.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: TKeys.uploadData.translate(context),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Color(0xff4CAF50),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width * .4,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff4CAF50),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
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
                                await Fluttertoast.showToast(
                                  msg: TKeys.dataSent.translate(context),
                                );
                              }
                            },
                            child: Text(
                              TKeys.submit.translate(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Visibility(
                  visible: charging,
                  child: Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(TKeys.meterData.translate(context), style: Theme.of(context).textTheme.displayMedium,),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${TKeys.id.translate(context)}:',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    '$clientID',
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${TKeys.totalReadings.translate(context)}: ',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    totalReadingsPulses.toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TKeys.balance.translate(context),
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    '$currentBalance',
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              /*Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TKeys.currentTariff.translate(context),
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    '$currentTariff',
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),*/
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TKeys.tariffVersion.translate(context),
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    currentTariffVersion.toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              Text(TKeys.chargingData.translate(context), style: Theme.of(context).textTheme.displayMedium,),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${TKeys.balanceStation.translate(context)}: ',
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    balanceMaster.toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TKeys.tariffPrice.translate(context),
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    (tariffMaster/100).toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TKeys.tariffVersion.translate(context),
                                    style: nameLabelStyle,
                                  ),
                                  Text(
                                    tariffVersionMaster.toString(),
                                    style: nameValueStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Row(
                              //   mainAxisAlignment:
                              //   (updatingMaster && !updated)?MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
                              //   children: [
                                  Center(
                                    child: SizedBox(
                                      width: /*(updatingMaster && !updated)?width * .4:*/width * .6,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff4CAF50),
                                        ),
                                        onPressed: () async {
                                          await widget.writeWithoutResponse(
                                              widget.characteristic, [0xAA]);
                                          await subscribeCharacteristic();
                                          setState(() {
                                            updatingMaster = true;
                                          });
                                        },
                                        child: Text(
                                          TKeys.charge.translate(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                  /*Visibility(
                                    visible: updatingMaster && !updated,
                                    child: SizedBox(
                                    width: width * .4,
                                    child: ElevatedButton(
                                      onPressed: !updated?() async {
                                              final myInstance = SqlDb();
                                              if (balance.isNotEmpty &&
                                                  tariff.isEmpty) {
                                                await myInstance.saveList(
                                                    balance,
                                                    '$selectedName',
                                                    '$listType',
                                                    'balance');
                                                await myInstance.updateData('''
                                              UPDATE Meters
                                              SET balance = 1
                                              WHERE name = '$selectedName'
                                              ''');
                                                setState(() {
                                                  updated = true;
                                                });
                                              } else if (tariff.isNotEmpty &&
                                                  balance.isEmpty) {
                                                await myInstance.saveList(
                                                    tariff,
                                                    '$selectedName',
                                                    '$listType',
                                                    'tariff');
                                                await myInstance.updateData('''
                                              UPDATE Meters
                                              SET tariff = 1
                                              WHERE name = '$selectedName'
                                              ''');
                                                setState(() {
                                                  updated = true;
                                                });
                                              } else {
                                                await myInstance.saveList(
                                                    balance,
                                                    '$selectedName',
                                                    '$listType',
                                                    'balance');
                                                await myInstance.saveList(
                                                    tariff,
                                                    '$selectedName',
                                                    '$listType',
                                                    'tariff');
                                                await myInstance.updateData('''
                                              UPDATE Meters
                                              SET 
                                              balance = 1,
                                              tariff = 1
                                              WHERE name = '$selectedName'
                                              ''');
                                                setState(() {
                                                  updated = true;
                                                });
                                              }
                                            }:null,
                                      child: Text(
                                        TKeys.update.translate(context),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ),*/
                                // ],
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> writeCharacteristicWithoutResponse() async {
    const chunkSize = 20;
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
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
      if (event.first == 0xA3 || event.first == 0xA5) {
        setState(() {
          tariff = [];
          tariff
            ..insert(0, 0x10)
            ..addAll(event.sublist(1, 13));
            // ..add(random.nextInt(255));
          tariffMaster = convertToInt(event, 1, 11);
          tariffVersionMaster = convertToInt(event, 1, 2);
        });
      }
      if (event.first == 0xA4 || event.first == 0xA6) {
        // setState(() {
          balance = [];
          // updated = false;
          balance
            ..insert(0, 0x09)
            ..addAll(event.sublist(1, 6));
          balanceMaster = convertToInt(event, 1, 4) / 100;
          // });
            final myInstance = SqlDb();
            if (balance.isNotEmpty &&
                tariff.isEmpty) {
              myInstance.saveList(
                  balance,
                  '$selectedName',
                  '$listType',
                  'balance').then((value) =>
                    myInstance.updateData('''
                      UPDATE Meters
                      SET balance = 1
                      WHERE name = '$selectedName'
                      '''),
              );
            } else if (tariff.isNotEmpty &&
                balance.isEmpty) {
              myInstance.saveList(
                  tariff,
                  '$selectedName',
                  '$listType',
                  'tariff').then((value) =>
              myInstance.updateData('''
                                              UPDATE Meters
                                              SET tariff = 1
                                              WHERE name = '$selectedName'
                                              '''));
            } else {
              myInstance.saveList(
                  balance,
                  '$selectedName',
                  '$listType',
                  'balance').then((value) =>
              myInstance.saveList(
                  tariff,
                  '$selectedName',
                  '$listType',
                  'tariff').then((value) =>
              myInstance.updateData('''
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

  @override
  void initState() {
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

  @override
  void dispose() {
    subscribeStream?.cancel();
    widget.viewModel.disconnect();
    timer.cancel();
    start = 0;
    selectedName = null;
    charging = false;
    clientID = 0;
    currentTariff = 0;
    currentBalance = 0;
    tariffMaster = 0;
    balanceMaster = 0;
    tariff = [];
    super.dispose();
  }
}
