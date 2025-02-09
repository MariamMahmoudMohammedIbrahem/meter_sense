
import '../../commons.dart';

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

/*LineChartData mainDataEle(BuildContext context) {
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
}*/

LineChartData mainMeterData(BuildContext context, String name) {
  // if(name.startsWith("Ele")){
  //   meterReadings = eleReadings;
  // } else{
  //   meterReadings = watReadings;
  // }
  final minY = meterReadings.reduce((a, b) => a < b ? a : b);
  final maxY = meterReadings.reduce((a, b) => a > b ? a : b);

  // Determine interval and ensure we cover the maximum value
  var interval = (maxY - minY) / 6;
  interval = interval.roundToDouble();
  if (interval < 1.0) {
    interval = 1.0;
  }
  final adjustedMaxY = (maxY % interval == 0) ? maxY : (maxY + interval - (maxY % interval));

  final yValues = <int>[];
  for (var value = minY.toInt(); value <= adjustedMaxY.toInt(); value += interval.toInt()) {
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
    maxX: meterReadings.length.toDouble() - 1,
    minY: minY,
    maxY: adjustedMaxY,
    lineBarsData: [
      LineChartBarData(
        spots: meterReadings
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
