import '../../commons.dart';
part 'device_interaction_controller.dart';

class DeviceInteractionScreen extends StatefulWidget {
  const DeviceInteractionScreen({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
    required this.name,
  });
  final DeviceInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;
  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;
  final String name;
  @override
  _DeviceInteractionScreen createState() => _DeviceInteractionScreen();
}

class _DeviceInteractionScreen extends DeviceInteractionController {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
          color: MyColors.lightGreen,
          onRefresh: refreshing,
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: height * .95,
                width: width,
                child: Column(children: [
                  Flexible(
                    child: ListView(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * .07),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                TKeys.welcome.translate(context),
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                              ElevatedButton(
                                onPressed: connecting,
                                child: Text((widget
                                            .viewModel.connectionStatus ==
                                        DeviceConnectionState.connected)
                                    ? TKeys.disconnect.translate(context)
                                    : (widget.viewModel.connectionStatus ==
                                            DeviceConnectionState.connecting)
                                        ? TKeys.connecting.translate(context)
                                        : (widget.viewModel.connectionStatus ==
                                                DeviceConnectionState
                                                    .disconnected)
                                            ? TKeys.connect.translate(context)
                                            : TKeys.disconnecting
                                                .translate(context)),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: isLoading,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * .5 - 20),
                            child: const CircularProgressIndicator(
                              color: MyColors.lightGreen,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: width * .07, vertical: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: widget.viewModel.deviceConnected
                                        ? MyColors.lightGreen
                                        : Colors.red.shade900),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: deviceWidgetInteracting,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${TKeys.name.translate(context)}: ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Text(
                                        widget.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  height10,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      width1,
                                      Column(
                                        children: [
                                          Text(
                                            TKeys.totalReadings
                                                .translate(context),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 25,
                                                child: Image.asset(
                                                  paddingType == "Electricity"
                                                      ? "assets/icons/electricityToday.png"
                                                      : "assets/icons/waterToday.png",
                                                ),
                                              ),
                                              Text(
                                                paddingType == "Electricity"
                                                    ? meterData[1].toString()
                                                    : meterData[1].toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              width3,
                                              Text(
                                                paddingType == "Electricity"
                                                    ? TKeys.electricUnit
                                                        .translate(context)
                                                    : TKeys.waterUnit
                                                        .translate(context),
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      width30,
                                      Column(
                                        children: [
                                          Text(
                                            TKeys.consumption
                                                .translate(context),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 25,
                                                child: Image.asset(paddingType ==
                                                        "Electricity"
                                                    ? "assets/icons/electricityMonth.png"
                                                    : "assets/icons/waterMonth.png"),
                                              ),
                                              Text(
                                                paddingType == "Electricity"
                                                    ? meterData[8].toString()
                                                    : meterData[8].toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              width3,
                                              Text(
                                                paddingType == "Electricity"
                                                    ? TKeys.electricUnit
                                                        .translate(context)
                                                    : TKeys.waterUnit
                                                        .translate(context),
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      width1,
                                    ],
                                  ),
                                  height10,
                                  Row(
                                    children: [
                                      SizedBox(width: width * .07),
                                      Text(
                                        "${TKeys.balance.translate(context)}: ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Text(
                                        paddingType == "Electricity"
                                            ? meterData[3].toString()
                                            : meterData[3].toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      width3,
                                      Text(
                                        TKeys.priceUnit.translate(context),
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                  height10,
                                  /*Row(
                                    mainAxisAlignment: (balanceCond || tariffCond) &&
                                        counter > 0?MainAxisAlignment.spaceEvenly:MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onLongPress: resettingCharge,
                                        child: Text(
                                            TKeys.resetting.translate(context),),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: Colors.white,
                                          disabledForegroundColor: Colors.red,
                                        ), onPressed: () {  },
                                      ),*/
                                      Visibility(
                                        visible: (balanceCond || tariffCond) &&
                                            counter > 0,
                                        child: Column(
                                          children: [
                                            ElevatedButton(
                                              onPressed:
                                                  (balanceCond || tariffCond)
                                                      ? () async {
                                                          if (widget.viewModel
                                                                  .connectionStatus !=
                                                              DeviceConnectionState
                                                                  .connected) {
                                                            widget.viewModel
                                                                .connect();
                                                          } else if (widget
                                                              .viewModel
                                                              .deviceConnected) {
                                                            await setDateAndTime();
                                                          }
                                                        }
                                                      : null,
                                              child: Text(
                                                TKeys.recharge
                                                    .translate(context),
                                              ),
                                            ),
                                            height10,
                                          ],
                                        ),
                                      ),
                                    /*],
                                  ),*/
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: nameList.length != 1 && nameList.isNotEmpty,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  AutoSizeText(
                                    TKeys.notConnected.translate(context),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxFontSize: 20,
                                    minFontSize: 18,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: width * .07,
                                  right: width * .07,
                                  top: 10,
                                ),
                                child: dividerGrey800,
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: nameList.length != 1 && nameList.isNotEmpty,
                          child: FutureBuilder(
                              future: sqlDb.readData("SELECT * FROM Meters"),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Map>> snapshot) {
                                if (snapshot.hasData) {
                                  final filteredItems = snapshot.data!
                                      .where(
                                          (item) => item["name"] != widget.name)
                                      .toList();
                                  return ListView.builder(
                                      itemCount: filteredItems.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, i) {
                                        ///editing sqldb
                                        /*sqlDb
                                          ..readMeterData(
                                            "${filteredItems[i]["name"]}",
                                          )
                                          ..editingList(
                                            "${filteredItems[i]["name"]}",
                                          );*/
                                        readMeterData("${filteredItems[i]["name"]}").whenComplete(() => editingList(
                                          "${filteredItems[i]["name"]}",
                                        ));
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: width * .07,
                                              vertical: 10.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                side: BorderSide(
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              /*if ("${filteredItems[i]["name"]}"
                                                  .startsWith("Ele")) {*/
                                                Navigator.of(context)
                                                    .push<void>(
                                                  MaterialPageRoute<void>(
                                                    builder: (context) =>
                                                        DeviceHistoryScreen(
                                                      name:
                                                          "${filteredItems[i]["name"]}",
                                                    ),
                                                  ),
                                                );
                                              /*} else {
                                                Navigator.of(context)
                                                    .push<void>(
                                                  MaterialPageRoute<void>(
                                                    builder: (context) =>
                                                        WaterData(
                                                      name: filteredItems[i]
                                                              ["name"]
                                                          .toString(),
                                                    ),
                                                  ),
                                                );
                                              }*/
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "${TKeys.name.translate(context)}: ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium,
                                                      ),
                                                      Text(
                                                        "${filteredItems[i]["name"]}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                    ],
                                                  ),
                                                  height10,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      width1,
                                                      Column(
                                                        children: [
                                                          Text(
                                                            TKeys.totalReadings
                                                                .translate(
                                                                    context),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 25,
                                                                child:
                                                                    Image.asset(
                                                                  ("${filteredItems[i]["name"]}"
                                                                          .startsWith(
                                                                              "Ele"))
                                                                      ? "assets/icons/electricityToday.png"
                                                                      : "assets/icons/waterToday.png",
                                                                ),
                                                              ),
                                                              Text(
                                                                ("${filteredItems[i]["name"]}"
                                                                        .startsWith(
                                                                            "Ele"))
                                                                    ? ("${eleMeters["${filteredItems[i]["name"]}"]?[1]}")
                                                                    : ("${watMeters["${filteredItems[i]["name"]}"]?[1]}"),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              ),
                                                              width3,
                                                              Text(
                                                                ("${filteredItems[i]["name"]}".startsWith(
                                                                        "Ele"))
                                                                    ? TKeys
                                                                        .electricUnit
                                                                        .translate(
                                                                            context)
                                                                    : TKeys
                                                                        .waterUnit
                                                                        .translate(
                                                                            context),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      width30,
                                                      Column(
                                                        children: [
                                                          Text(
                                                            TKeys.consumption
                                                                .translate(
                                                                    context),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 25,
                                                                child: Image.asset("${filteredItems[i]["name"]}"
                                                                        .startsWith(
                                                                            "Ele")
                                                                    ? "assets/icons/electricityMonth.png"
                                                                    : "assets/icons/waterMonth.png"),
                                                              ),
                                                              Text(
                                                                ("${filteredItems[i]["name"]}"
                                                                        .startsWith(
                                                                            "Ele"))
                                                                    ? ("${eleMeters["${filteredItems[i]["name"]}"]?[3]}")
                                                                    : ("${watMeters["${filteredItems[i]["name"]}"]?[3]}"),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              ),
                                                              width3,
                                                              Text(
                                                                ("${filteredItems[i]["name"]}".startsWith(
                                                                        "Ele"))
                                                                    ? TKeys
                                                                        .electricUnit
                                                                        .translate(
                                                                            context)
                                                                    : TKeys
                                                                        .waterUnit
                                                                        .translate(
                                                                            context),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      width1,
                                                    ],
                                                  ),
                                                  height10,
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                          width: width * .07),
                                                      Text(
                                                        "${TKeys.balance.translate(context)}: ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium,
                                                      ),
                                                      Text(
                                                        ("${filteredItems[i]["name"]}"
                                                                .startsWith(
                                                                    "Ele"))
                                                            ? ("${eleMeters["${filteredItems[i]["name"]}"]?[2]}")
                                                            : ("${watMeters["${filteredItems[i]["name"]}"]?[2]}"),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                      width3,
                                                      Text(
                                                        TKeys.priceUnit
                                                            .translate(context),
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontStyle: FontStyle
                                                                .italic),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          )),
    );
  }
}
