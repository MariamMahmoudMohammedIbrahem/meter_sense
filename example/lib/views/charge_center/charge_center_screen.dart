
import '../../commons.dart';
part 'charge_center_controller.dart';

class ChargeCenterScreen extends StatefulWidget {
  const ChargeCenterScreen({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
  });
  final ChargeCenterViewModel viewModel;

  final QualifiedCharacteristic characteristic;

  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;

  @override
  _ChargeCenterScreen createState() => _ChargeCenterScreen();
}

class _ChargeCenterScreen extends ChargeCenterController {
  @override
  Widget build(BuildContext context) {

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
                        child: width1,
                    ),
                    Flexible(
                      flex: 2,
                      child: SizedBox(
                        height: 55,
                        child: PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              selectedName = value;
                              getSpecifiedList(value, 'none');
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
                height10,
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
                height20,
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
                              height10,
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
                              height10,
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
                              height10,
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
                              height10,
                              dividerGrey,
                              Text(TKeys.chargingData.translate(context), style: Theme.of(context).textTheme.displayMedium,),
                              height10,
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
                              height10,
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
                              height10,
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
                              height20,
                                  Center(
                                    child: SizedBox(
                                      width: width * .6,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff4CAF50),
                                        ),
                                        onPressed: () async {
                                          await widget.writeWithoutResponse(
                                              widget.characteristic, [0xAA]);
                                          await subscribeCharacteristic();
                                        },
                                        child: Text(
                                          TKeys.charge.translate(context),
                                        ),
                                      ),
                                    ),
                                  ),
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
}
