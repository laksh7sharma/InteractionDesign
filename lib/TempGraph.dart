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
    // 1) While the future is running, show a spinner
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) If the future completed with an error, show it
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    // 3) If we got here, the future is done – check for data
    final api = snapshot.data;
    if (api == null) {
      // This really shouldn’t happen if your Future<T> never returns null,
      // but guard anyway to keep the compiler happy.
      return const Center(child: Text('No data'));
    }

    // 4) Now safely call getHourlyData(); if it can return null, reflect that
    final hourlyData = api.getHourlyData();  // type: Map<int, Map<String,dynamic>>?
    if (hourlyData == null || hourlyData.isEmpty) {
      // Either there was literally no hourly data, or getHourlyData() chose to return null.
      return const Center(child: Text('No hourly data available'));
    }

    // 5) At this point we know hourlyData is non-null and non-empty.
    double maxTemp = -double.infinity;
    double minTemp = double.infinity;
    final List<FlSpot> dataPoints = [];

    for (final entry in hourlyData.entries) {
      final hour = entry.key.toDouble();
      final temp = (entry.value['temperature'] as num).toDouble();
      dataPoints.add(FlSpot(hour, temp));
      if (temp < minTemp) minTemp = temp;
      if (temp > maxTemp) maxTemp = temp;
    }

    // 6) Build your chart
    return LineChart(
      LineChartData(
        minY: minTemp.floorToDouble(),
        maxY: maxTemp.ceilToDouble(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 5,
        ),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 10, reservedSize: 30),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 2, reservedSize: 40),
          ),
        ),
        lineTouchData: LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints,
            isCurved: true,
            curveSmoothness: 0.3,
            dotData: FlDotData(show: false),
            color: Colors.red,
          ),
        ],
      ),
    );
  },
);


  }
}