import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'API.dart';

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
          List<FlSpot> dataPoints = [];
          for (MapEntry<int, Map<String, dynamic>> hourEntry in hourlyData.entries) {
            FlSpot dataPoint = FlSpot(hourEntry.key.toDouble(), hourEntry.value["temperature"].toDouble());
            dataPoints.add(dataPoint);
          }
          return LineChart(
            LineChartData(
              lineBarsData: [
              LineChartBarData(
                spots: [FlSpot(1, 2)]
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