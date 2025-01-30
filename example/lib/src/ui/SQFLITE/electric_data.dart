import '../../../commons.dart';

class StoreData extends StatefulWidget {
  const StoreData({
    required this.name,
    super.key,
  });
  final String name;
  @override
  State<StoreData> createState() => _StoreDataState();
}

class _StoreDataState extends State<StoreData> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          color: const Color(0xFF4CAF50),
          onRefresh: () => Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => StoreData(name: widget.name),
                ),
              );
            });
          }),
          child: Column(
            children: [
              SizedBox(
                height: height * .95,
                child: FutureBuilder(
                    future: sqlDb
                        .editingList(widget.name), // Fetch data asynchronously
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Color(0xff4CAF50),)); // Show a loading indicator while waiting
                      }
                      /*else if(myList.isEmpty){
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.07),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline_rounded, color: Colors.green.shade900,size: 100,),
                                const Text('This Meter doesn\'t have any data yet', style: TextStyle(fontSize: 22,),textAlign: TextAlign.center,),
                                const Text('Please try to connect to it', style: TextStyle(color: Colors.grey, fontSize: 17),),
                              ],
                            ),
                          ),
                        );
                      }*/
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
                                          color: const Color(0xff4CAF50),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
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
                                                widget.name ==
                                                    meterName
                                                    ? eleMeter[5]
                                                    .toString() ==
                                                    '1'
                                                    ? Icons
                                                    .lock_open
                                                    : Icons.lock
                                                    : ('${eleMeters[widget.name]?[4]}') ==
                                                    '1'
                                                    ? Icons
                                                    .lock_open
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
                                            child: Divider(),
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
                                                myList.isEmpty?'0':'${convertToInt(myList, 1, 11)/100??''}',
                                                style:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                minFontSize: 18,
                                              ),
                                              const Text(' L.E.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
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
                                                    ? eleMeter[3]
                                                    .toString()
                                                    : ('${eleMeters[widget.name]?[2]}'),
                                                style:
                                                Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                minFontSize: 18,
                                              ),
                                              const Text(' L.E.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
                                            ],
                                          ),
                                          const SizedBox(height: 5,),
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
                                                    ? eleMeter[1]
                                                        .toString()
                                                    : ('${eleMeters[widget.name]?[1]}'),
                                                style:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                minFontSize: 18,
                                              ),
                                              const Text(' kw', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
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
                                                    ? eleMeter[8].toString()
                                                    : ('${eleMeters[widget.name]?[3]}'),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                minFontSize: 18,
                                              ),
                                              const Text(' kw', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
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
                                          mainDataEle(context),
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
                                    child: const Divider(),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  AutoSizeText(
                                    TKeys.totalReadings.translate(context),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  FutureBuilder(
                                      future: readEle(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<Map>> snapshot) {
                                        if (snapshot.hasData) {
                                          return ListView.builder(
                                            itemCount: snapshot.data!.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, i) =>
                                                Padding(
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
                                                        const Color(0xff4CAF50),
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
                                                          "${snapshot.data![i]['time']}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          minFontSize: 22,
                                                          style: const TextStyle(color: Color(0xff4CAF50)),
                                                        )),
                                                    Expanded(
                                                      flex: 3,
                                                      child: AutoSizeText(
                                                        "${snapshot.data![i]['totalReading']} kw",
                                                        textAlign:
                                                            TextAlign.center,
                                                        minFontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
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

  Future<List<Map>> readEle() async {
    final response = await sqlDb.read(widget.name, 'Electricity');
    return response;
  }
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Color(0xffD6EFD8),
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  Widget text;
  switch (value.toInt()) {
    case 0:
      text = Text(
        monthList[5],
        style: style,
        textScaleFactor: 1.0,
      );
      break;
    case 1:
      text = Text(
        monthList[4],
        style: style,
        textScaleFactor: 1.0,
      );
      break;
    case 2:
      text = Text(
        monthList[3],
        style: style,
        textScaleFactor: 1.0,
      );
      break;
    case 3:
      text = Text(
        monthList[2],
        style: style,
        textScaleFactor: 1.0,
      );
      break;
    case 4:
      text = Text(
        monthList[1],
        style: style,
        textScaleFactor: 1.0,
      );
      break;
    case 5:
      text = Text(
        monthList[0],
        style: style,
        textScaleFactor: 1.0,
      );
      break;
    default:
      text = const Text(
        '',
        style: style,
        textScaleFactor: 1.0,
      );
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}

// Widget leftTitleWidgets(double value, TitleMeta meta) {
//   const style = TextStyle(
//     color: Color(0xffD6EFD8),
//     fontWeight: FontWeight.bold,
//     fontSize: 15,
//   );
//   // String text;
//   // switch (value.toInt()) {
//   //   case 10:
//   //     text = '10%';
//   //     break;
//   //   case 20:
//   //     text = '20%';
//   //     break;
//   //   case 30:
//   //     text = '30%';
//   //     break;
//   //   case 40:
//   //     text = '40%';
//   //     break;
//   //   case 50:
//   //     text = '50%';
//   //     break;
//   //   case 60:
//   //     text = '60%';
//   //     break;
//   //   case 70:
//   //     text = '70%';
//   //     break;
//   //   case 80:
//   //     text = '80%';
//   //     break;
//   //   case 90:
//   //     text = '90%';
//   //     break;
//   //   case 100:
//   //     text = '100%';
//   //     break;
//   //   default:
//   //     return Container();
//   // }
//
//   // Show the title if the value is in the yValues list
//   if (yValues.contains(value)) {
//     return Text(
//       '${value.toStringAsFixed(1)}%', // Format the value as needed
//       style: style,
//       textAlign: TextAlign.left,
//       textScaleFactor: 1.0,
//     );
//   } else {
//     return Container();
//   }
// }
LineChartData mainDataEle(BuildContext context) {
  final minY = eleReadings.reduce((a, b) => a < b ? a : b);
  final maxY = eleReadings.reduce((a, b) => a > b ? a : b);

  // Determine interval and ensure we cover the maximum value
  var interval = (maxY - minY) / 6;
  interval = interval.roundToDouble();
  if (interval < 1.0) {
    interval = 1.0;
  }
  final adjustedMaxY =
      (maxY % interval == 0) ? maxY : (maxY + interval - (maxY % interval));

  final yValues = <int>[];
  for (var value = minY.toInt();
      value <= adjustedMaxY.toInt();
      value += interval.toInt()) {
    yValues.add(value);
  }

  return LineChartData(
    backgroundColor: Colors.transparent,
    gridData: const FlGridData(
      verticalInterval: 1,
    ),
    titlesData: FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: bottomTitleWidgets,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          getTitlesWidget: (value, meta) => leftTitleWidgets(value, meta, yValues),
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: Colors.grey.shade700),
    ),
    minX: 0,
    maxX: eleReadings.length.toDouble() - 1,
    minY: minY,
    maxY: adjustedMaxY,
    lineBarsData: [
      LineChartBarData(
        spots: eleReadings
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
        isCurved: true,
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        barWidth: 5,
        isStrokeCapRound: false,
        dotData: const FlDotData(
          show: true,
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ),
    ],
  );
}

Widget leftTitleWidgets(double value, TitleMeta meta, List<int> yValues) {
  const style = TextStyle(
    color: Color(0xffD6EFD8),
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  // Show the title if the value is in the yValues list
  if (yValues.contains(value.toInt())) {
    return Text(
      '${value.toInt()}', // Format the value as needed
      style: style,
      textAlign: TextAlign.left,
      textScaleFactor: 1.0,
    );
  } else {
    return Container();
  }
}
