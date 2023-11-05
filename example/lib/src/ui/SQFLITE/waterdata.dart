import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ui/device_detail/device_interaction_tab.dart';

import '../../../t_key.dart';
import 'dataPage.dart';

class WaterData extends StatefulWidget {
  const WaterData({required this.name,required this.count,Key? key,}) : super(key: key);
  final String name;
  final int count;
  @override
  State<WaterData> createState() => _WaterDataState();
}

class _WaterDataState extends State<WaterData> {
  Future<List<Map>> readWat() async {
    // final response = await sqlDb.read(widget.name,'Water');
    final response = await sqlDb.readData('''SELECT * FROM Water''');
    print("object =>1 $response");
    return response;
  }
  @override
  void initState() {
    sqlDb.editingList(widget.name,2);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text('water'),),
      body: RefreshIndicator(
        onRefresh: ()=> Future.delayed(
            const Duration(seconds: 1),(){
          setState(() {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => WaterData(name: widget.name, count: widget.count),
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
                          Text(widget.name, style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20)),
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
                                        ?watMeter[4].toString()
                                        :('${watMeters[widget.name]?[0]}'),
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
                                    widget.name==meterName?watMeter[3].toString():('${watMeters[widget.name]?[2]}'),
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
                          mainDataWater(),
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
                  Expanded(
                    child: SingleChildScrollView(
                        child: FutureBuilder(
                            future: readWat(),
                            builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot){
                              if(snapshot.hasData){
                                return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context,i)=>
                                        Padding(
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
                                                Text('${TKeys.balance.translate(context)}: ',),
                                                Text("${snapshot.data![i]['totalCredit']}"),
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
    );}
}
LineChartData mainDataWater() => LineChartData(
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
      spots: watReadings.map((e)=>FlSpot(watReadings.indexOf(e).toDouble(), e)).toList(),
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