import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'API.dart';
import 'dart:math';

class TempGraph extends StatelessWidget {
  String postcode = "";

  TempGraph (String postcode) {
    this.postcode = postcode;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<API>(
      future: API.create(postcode),
      builder: (context, snapshot) {
        if (!(snapshot.connectionState == ConnectionState.waiting)) {
          var hourlyData = snapshot.data!.getHourlyData();
          if (hourlyData == null) {
            return const CircularProgressIndicator();
          }
          double maxTemp = -double.maxFinite;
          double minTemp = double.maxFinite;
          List<FlSpot> dataPoints = [];
          for (MapEntry<int, Map<String, dynamic>> hourEntry in hourlyData.entries) {
            double temp = hourEntry.value["temperature"].toDouble();
            FlSpot dataPoint = FlSpot(hourEntry.key.toDouble(), temp);
            if (temp < minTemp) {
              minTemp = temp;
            }
            if (temp > maxTemp) {
              maxTemp = temp;
            }
            dataPoints.add(dataPoint);
          }
          return LineChart(
            LineChartData(
              minY: minTemp.floorToDouble(),
              maxY: maxTemp.ceilToDouble(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: 5,
              ),
              titlesData: FlTitlesData (
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false
                  )
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: false
                  )
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    reservedSize: 30
                  )
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    reservedSize: 40
                  )
                )
              ),
              lineTouchData: LineTouchData(
                enabled: false
              ),
              lineBarsData: [
              LineChartBarData(
                dotData: FlDotData(
                    show: false
                ),
                color: Colors.red,
                spots: dataPoints,
                isCurved: true,
                curveSmoothness: 0.3
              )]
            )
          );
        }
        else {
          return const CircularProgressIndicator();
        }
      }
    );

  }
}