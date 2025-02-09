import '../../commons.dart';

part 'device_history_controller.dart';

class DeviceHistoryScreen extends StatefulWidget {
  final String name;
  const DeviceHistoryScreen({required this.name, Key? key}) : super(key: key);

  @override
  _DeviceHistoryScreen createState() => _DeviceHistoryScreen();
}

class _DeviceHistoryScreen extends DeviceHistoryController {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          color: MyColors.lightGreen,
          onRefresh: () => Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => DeviceHistoryScreen(name: widget.name),
                ),
              );
            });
          }),
          child: Column(
            children: [
              SizedBox(
                height: height * .95,
                child: FutureBuilder(
                    future: editingList(widget.name), // Fetch data asynchronously
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                            CircularProgressIndicator(color: MyColors.lightGreen,)); // Show a loading indicator while waiting
                      }
                      else {
                        return Column(
                          children: [
                            Expanded(
                              child: ListView(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width * .07,
                                        vertical: 10.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * .03),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(18.0),
                                        border: Border.all(
                                          width: 1,
                                          color: MyColors.lightGreen,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          height10,
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              AutoSizeText(
                                                widget.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium,
                                              ),
                                              Icon(
                                                widget.name == meterName
                                                    ? meterData[5].toString() == '1'
                                                      ? Icons.lock_open
                                                      : Icons.lock
                                                    : (widget.name.startsWith("Ele")
                                                      ?('${eleMeters[widget.name]?[4]}') == '1'
                                                      :('${watMeters[widget.name]?[4]}') == '1')
                                                        ? Icons.lock_open
                                                        : Icons.lock,
                                                color: Colors
                                                    .green.shade900,
                                              ),
                                            ],
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: dividerGrey,
                                          ),
                                          Row(
                                            children: [
                                              AutoSizeText(
                                                '${TKeys.tariffPrice.translate(context)}: ',
                                                style:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                minFontSize: 20,
                                              ),
                                              AutoSizeText(
                                                myList.isEmpty?'0':'${convertToInt(myList, 1, 11)/100}',
                                                style:
                                                Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                minFontSize: 18,
                                              ),
                                              width3,
                                              Text(TKeys.priceUnit.translate(context), style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
                                            ],
                                          ),
                                          height5,
                                          Row(
                                            children: [
                                              AutoSizeText(
                                                '${TKeys.balance.translate(context)}: ',
                                                style:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                minFontSize: 20,
                                              ),
                                              AutoSizeText(
                                                widget.name ==
                                                    meterName
                                                    ? meterData[3]
                                                    .toString()
                                                    : widget.name.startsWith("Ele")?('${eleMeters[widget.name]?[2]}'):('${watMeters[widget.name]?[2]}'),
                                                style:
                                                Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                minFontSize: 18,
                                              ),
                                              width3,
                                              Text(TKeys.priceUnit.translate(context), style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
                                            ],
                                          ),
                                          height5,
                                          Row(
                                            children: [
                                              AutoSizeText(
                                                '${TKeys.totalReadings.translate(context)}: ',
                                                style:
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                minFontSize: 20,
                                              ),
                                              AutoSizeText(
                                                widget.name ==
                                                    meterName
                                                    ? meterData[1]
                                                    .toString()
                                                    : widget.name.startsWith("Ele")?('${eleMeters[widget.name]?[1]}'):('${watMeters[widget.name]?[1]}'),
                                                style:
                                                Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                minFontSize: 18,
                                              ),
                                              width3,
                                              Text(widget.name.startsWith("Ele")?TKeys.electricUnit.translate(context):TKeys.waterUnit.translate(context), style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
                                            ],
                                          ),
                                          height5,
                                          Row(
                                            children: [
                                              AutoSizeText(
                                                '${TKeys.consumption.translate(context)}: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                minFontSize: 20,
                                              ),
                                              AutoSizeText(
                                                widget.name == meterName
                                                    ? meterData[8].toString()
                                                    : widget.name.startsWith("Ele")?('${eleMeters[widget.name]?[3]}'):('${watMeters[widget.name]?[3]}'),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                minFontSize: 18,
                                              ),
                                              width3,
                                              Text(widget.name.startsWith("Ele")?TKeys.electricUnit.translate(context):TKeys.waterUnit.translate(context), style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
                                            ],
                                          ),
                                          height10,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: width * .07,
                                      right: width * .07,
                                      top: 5,
                                    ),
                                    child: Container(
                                      height: height * .3,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          top: 8.0,
                                        ),
                                        child: LineChart(
                                          mainMeterData(context, widget.name),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: width * .07,
                                      right: width * .07,
                                      top: 10,
                                    ),
                                    child: dividerGrey,
                                  ),
                                  height5,
                                  AutoSizeText(
                                    TKeys.totalReadings.translate(context),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  height10,
                                  FutureBuilder(
                                      future: readMeterHistory(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<Map>> snapshot) {
                                        if (snapshot.hasData) {
                                          return ListView.builder(
                                              itemCount: snapshot.data!.length,
                                              physics:
                                              const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemBuilder: (context, i) => Padding(
                                                  padding: EdgeInsets.only(
                                                    left: width * .07,
                                                    right: width * .07,
                                                    bottom: 5,
                                                  ),
                                                  child: Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                        MyColors.lightGreen,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                      BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                      children: [
                                                        Expanded(
                                                            flex: 5,
                                                            child: AutoSizeText(
                                                              translateDate(context,snapshot.data![i]['time']),
                                                              textAlign:
                                                              TextAlign.center,
                                                              minFontSize: 22,
                                                              style: const TextStyle(
                                                                  color: MyColors
                                                                      .lightGreen),
                                                            )),
                                                        Expanded(
                                                          flex: 3,
                                                          child: AutoSizeText(
                                                            "${snapshot
                                                                .data![i]['totalReading']} ${TKeys
                                                                .electricUnit
                                                                .translate(
                                                                context)}",
                                                            textAlign:
                                                            TextAlign.center,
                                                            minFontSize: 18,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                          );
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
