import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';

import '../../../t_key.dart';
import 'electric_data.dart';

class WaterData extends StatefulWidget {
  const WaterData({
    required this.name,
    super.key,
  });
  final String name;
  @override
  State<WaterData> createState() => _WaterDataState();
}

class _WaterDataState extends State<WaterData> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => WaterData(name: widget.name),
                ),
              );
            });
          }),
          child: SizedBox(
            height: height * .95,
            child: FutureBuilder(future: sqlDb.editingList(widget.name), builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xff4CAF50),),
                );
              }else{
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * .07, vertical: 10.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: width * .03),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18.0),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xff4CAF50),
                                  )),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  AutoSizeText(
                                    widget.name,
                                    style: Theme.of(context).textTheme.displayMedium,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Divider(),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: width * .39,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // SizedBox(width: width * .07),
                                                AutoSizeText(
                                                  '${TKeys.tarrif.translate(context)}: ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  minFontSize: 20,
                                                ),
                                                AutoSizeText(
                                                  widget.name == meterName
                                                      ? watMeter[4].toString()
                                                      : ('${watMeters[widget.name]?[0]}'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  minFontSize: 18,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                AutoSizeText(
                                                  '${TKeys.totalReadings.translate(context)}: ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  minFontSize: 20,
                                                ),
                                                AutoSizeText(
                                                  widget.name == meterName
                                                      ? watMeter[1].toString()
                                                      : ('${watMeters[widget.name]?[1]}'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  minFontSize: 18,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .39,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                AutoSizeText(
                                                  '${TKeys.balance.translate(context)}: ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  minFontSize: 20,
                                                ),
                                                AutoSizeText(
                                                  widget.name == meterName
                                                      ? watMeter[3].toString()
                                                      : ('${watMeters[widget.name]?[2]}'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  minFontSize: 18,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                AutoSizeText(
                                                  '${TKeys.valveStatus.translate(context)}: ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  minFontSize: 20,
                                                ),
                                                Icon(
                                                  widget.name == meterName
                                                      ? watMeter[5].toString() == '1'
                                                      ? Icons.lock_open
                                                      : Icons.lock
                                                      : ('${watMeters[widget.name]?[4]}') ==
                                                      '1'
                                                      ? Icons.lock_open
                                                      : Icons.lock,
                                                  color: Colors.green.shade900,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      AutoSizeText(
                                        '${TKeys.consumption.translate(context)}: ',
                                        style: Theme.of(context).textTheme.titleMedium,
                                        minFontSize: 20,
                                      ),
                                      AutoSizeText(
                                        widget.name == meterName
                                            ? watMeter[8].toString()
                                            : ('${watMeters[widget.name]?[3]}'),
                                        style: Theme.of(context).textTheme.bodySmall,
                                        minFontSize: 18,
                                      ),
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
                                  mainDataWater(context),
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
                            TKeys.history.translate(context),
                            style: Theme.of(context).textTheme.displayMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          FutureBuilder(
                              future: readWat(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Map>> snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    physics: const NeverScrollableScrollPhysics(),
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
                                            color: const Color(0xff4CAF50),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: AutoSizeText(
                                                "${snapshot.data![i]['time']}",
                                                textAlign: TextAlign.center,minFontSize: 18,),),
                                            Expanded(
                                              flex: 3,
                                              child: AutoSizeText(
                                                '${TKeys.consumption.translate(context)}: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                "${snapshot.data![i]['currentConsumption']}",
                                                textAlign: TextAlign.center,minFontSize: 18,),
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
        ),
      ),
    );
  }

  Future<List<Map>> readWat() async {
    final response = await sqlDb.read(widget.name, 'Water');
    return response;
  }
}

LineChartData mainDataWater(BuildContext context) {
  double minY = watReadings.reduce((a, b) => a < b ? a : b);
  double maxY = watReadings.reduce((a, b) => a > b ? a : b);

  // Determine interval and ensure we cover the maximum value
  double interval = (maxY - minY) / 6;
  interval = interval.roundToDouble();
  if (interval < 1.0) {
    interval = 1.0;
  }
  double adjustedMaxY = (maxY % interval == 0) ? maxY : (maxY + interval - (maxY % interval));

  List<int> yValues = [];
  for (int value = minY.toInt(); value <= adjustedMaxY.toInt(); value += interval.toInt()) {
    yValues.add(value);
  }

  return LineChartData(
    backgroundColor: Colors.transparent,
    gridData: const FlGridData(
      verticalInterval: 1,
    ),
    titlesData: FlTitlesData(
      show: true,
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
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
          getTitlesWidget: (value, meta) {
            return leftTitleWidgets(value, meta, yValues);
          },
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: Colors.grey.shade700),
    ),
    minX: 0,
    maxX: watReadings.length.toDouble() - 1,
    minY: minY,
    maxY: adjustedMaxY,
    lineBarsData: [
      LineChartBarData(
        spots: watReadings
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
            colors: gradientColors
                .map((color) => color.withOpacity(0.3))
                .toList(),
          ),
        ),
      ),
    ],
  );
}