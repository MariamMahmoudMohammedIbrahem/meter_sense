import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';

import '../../../t_key.dart';


class StoreData extends StatefulWidget {
    const StoreData({
      required this.name,
      // required this.count,
    super.key,
  });
    final String name;
    // final int count;
  // final DiscoveredDevice device;
  @override
  State<StoreData> createState() => _StoreDataState();
}

class _StoreDataState extends State<StoreData> {
  Future<List<Map>> readEle() async {
    final response  = await sqlDb.read(widget.name,'Electricity');
    return response;
  }
  @override
  void initState() {
    // sqlDb.editingList(widget.name,'Electricity');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: ()=> Future.delayed(
            const Duration(seconds: 1),(){
          setState(() {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => StoreData(name: widget.name),
              ),
            );
          });
        }),
        child: ListView(
          children: [
            SizedBox(
              height: height*.87,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:width*.07,vertical: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(width: 1,color: Colors.deepPurple.shade100,)
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(widget.name, style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20)),
                          Padding(
                            padding: EdgeInsets.only(
                              left: width * .07,
                              right: width * .07,
                              top: 10,
                            ),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              indent: 0,
                              endIndent: 10,
                              color: Colors.deepPurple.shade50,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width:width*.07),
                                  Text(
                                    '${TKeys.currentTarrif.translate(context)}: ',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    widget.name == meterName
                                        ?eleMeter[4].toString()
                                        :('${eleMeters[widget.name]?[0]}'),
                                    // eleMeter[4].toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(width:width*.07),
                                  Text(
                                    '${TKeys.balance.translate(context)}: ',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    widget.name == meterName ?eleMeter[3].toString():('${eleMeters[widget.name]?[2]}'),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
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
                        color: Colors.deepPurple.shade50,
                        border: Border.all(color: Colors.deepPurple.shade50, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left:8.0,right:8.0,top: 8.0,),
                        child: LineChart(
                          mainDataEle(),
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
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      indent: 0,
                      endIndent: 10,
                      color: Colors.deepPurple.shade50,
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Text(
                    TKeys.history.translate(context),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Expanded(
                    child: SingleChildScrollView(
                      child: FutureBuilder(
                          future: readEle(),
                          builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot){
                            if(snapshot.hasData){
                              return ListView.builder(
                                itemCount: snapshot.data!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context,i)=> Padding(
                                  padding:  EdgeInsets.only(left: width*.07,right: width*.07,bottom: 5,),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border:
                                      Border.all(color: Colors.deepPurple.shade50, width: 2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text("${snapshot.data![i]['time']}"),
                                        Text('${TKeys.consumption.translate(context)}: ',),
                                        Text("${snapshot.data![i]['currentConsumption']}"),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const Center(child: CircularProgressIndicator(),);
                          }
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.brown,
    fontWeight: FontWeight.bold,

    fontSize: 16,

  );
  Widget text;
  switch (value.toInt()) {
    case 0:
      text = Text(monthList[5], style: style);
      break;
    case 1:
      text = Text(monthList[4], style: style);
      break;
    case 2:
      text = Text(monthList[3], style: style);
      break;
    case 3:
      text = Text(monthList[2], style: style);
      break;
    case 4:
      text = Text(monthList[1], style: style);
      break;
    case 5:
      text = Text(monthList[0], style: style);
      break;
    default:
      text = const Text('', style: style);
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}

Widget leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.brown,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );
  String text;
  switch (value.toInt()) {
    case 10:
      text = '10%';
      break;
    case 20:
      text = '20%';
      break;
    case 30:
      text = '30%';
      break;
    case 40:
      text = '40%';
      break;
    case 50:
      text = '50%';
      break;
    case 60:
      text = '60%';
      break;
    case 70:
      text = '70%';
      break;
    case 80:
      text = '80%';
      break;
    case 90:
      text = '90%';
      break;
    case 100:
      text = '100%';
      break;
    default:
      return Container();
  }

  return Text(text, style: style, textAlign: TextAlign.left);
}

LineChartData mainDataEle() => LineChartData(
  backgroundColor: Colors.transparent,
  gridData: FlGridData(
    show: true,
    drawVerticalLine: true,
    horizontalInterval: 10,
    verticalInterval: 1,
    getDrawingHorizontalLine: (value) => const FlLine(
      color: Colors.grey,
      strokeWidth: 1,
    ),
    getDrawingVerticalLine: (value) => const FlLine(
      color: Colors.grey,
      strokeWidth: 1,
    ),
  ),
  titlesData: const FlTitlesData(
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
        interval: 1,
        getTitlesWidget: leftTitleWidgets,
        reservedSize: 42,
      ),
    ),
  ),
  //outline border
  borderData: FlBorderData(
    show: true,
    border: Border.all(color: Colors.grey),
  ),
  minX: 0,
  maxX: 5,
  minY: 0,
  maxY: 100,
  lineBarsData: [
    LineChartBarData(
      spots: eleReadings.map((e)=>FlSpot(eleReadings.indexOf(e).toDouble(), e)).toList(),
      isCurved: true,
      gradient: LinearGradient(
        colors: gradientColors,
      ),
      // width of curve
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
