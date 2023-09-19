import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/constants.dart';
import 'package:flutter_reactive_ble_example/src/ui/device_detail/device_interaction_tab.dart';
import 'package:fl_chart/fl_chart.dart';

class StoreData extends StatefulWidget {
  const StoreData({
    Key? key,
  }) : super(key: key);
  // final DiscoveredDevice device;
  @override
  State<StoreData> createState() => _StoreDataState();
}

class _StoreDataState extends State<StoreData> {
  Future<List<Map>> readEle() async {
    final response  = await sqlDb.readData("SELECT * FROM Electricity");
    return response;
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        items: const [
          Icon(
            Icons.electric_bolt_outlined,
            size: 30,
          ),
          Icon(Icons.add_circle_outline, size: 30),
          Icon(Icons.water_drop_outlined, size: 30),
        ],
        color: Colors.deepPurple.shade50,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          if (index == 0) {}
          else if (index == 1) {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (context) => DeviceInteractionTab(
                device: dataStored, characteristic: QualifiedCharacteristic(
                  characteristicId: Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb"),
                  serviceId: Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb"),
                  //device id get from register page when connected
                  deviceId: dataStored.id),
              )
              ),
            );
          }
          else if (index == 2) {
          }
        },
      ),
      body: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: width * .05,
                right: width * .05,
                top: 10,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'Usage',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'value',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Date',
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ],
              ),
            ),
            //graph
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
                    showAvg ? avgData() : mainData(),
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
            const Text(
              'History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
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
                                  const Text("Consumption:",),
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
    case 1:
      text = const Text('1', style: style);
      break;
    case 2:
      text = const Text('2', style: style);
      break;
    case 3:
      text = const Text('3', style: style);
      break;
    case 4:
      text = const Text('4', style: style);
      break;
    case 5:
      text = const Text('5', style: style);
      break;
    case 6:
      text = const Text('6', style: style);
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

LineChartData mainData() => LineChartData(
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
  maxX: 6,
  minY: 0,
  maxY: 100,
  lineBarsData: [
    LineChartBarData(
      spots: data.map((e)=>FlSpot(data.indexOf(e).toDouble(), e)).toList(),
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
        show: false,
        // gradient: LinearGradient(
        //   colors: gradientColors
        //       .map((color) => color.withOpacity(0.3))
        //       .toList(),
        // ),
      ),
    ),
  ],
);

LineChartData avgData() => LineChartData(
  lineTouchData: const LineTouchData(enabled: false),
  gridData: FlGridData(
    show: true,
    drawHorizontalLine: true,
    verticalInterval: 1,
    horizontalInterval: 1,
    getDrawingVerticalLine: (value) => const FlLine(
      color: Color(0xff37434d),
      strokeWidth: 1,
    ),
    getDrawingHorizontalLine: (value) => const FlLine(
      color: Color(0xff37434d),
      strokeWidth: 1,
    ),
  ),
  titlesData: const FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: bottomTitleWidgets,
        interval: 1,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: leftTitleWidgets,
        reservedSize: 42,
        interval: 1,
      ),
    ),
    topTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  ),
  borderData: FlBorderData(
    show: true,
    border: Border.all(color: const Color(0xff37434d)),
  ),
  minX: 0,
  maxX: 11,
  minY: 0,
  maxY: 6,
  lineBarsData: [
    LineChartBarData(
      spots: const [
        FlSpot(0, 3.44),
        FlSpot(2.6, 3.44),
        FlSpot(4.9, 3.44),
        FlSpot(6.8, 3.44),
        FlSpot(8, 3.44),
        FlSpot(9.5, 3.44),
        FlSpot(11, 3.44),
      ],
      isCurved: true,
      gradient: LinearGradient(
        colors: [
          ColorTween(begin: gradientColors[0], end: gradientColors[1])
              .lerp(0.2)!,
          ColorTween(begin: gradientColors[0], end: gradientColors[1])
              .lerp(0.2)!,
        ],
      ),
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: const FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)!
                .withOpacity(0.1),
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)!
                .withOpacity(0.1),
          ],
        ),
      ),
    ),
  ],
);
