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
        // If waiting for API to finish getting response, show progress circle.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Catch and report an error occurs
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // The future is done so the api has been created, and may be retrieved.
        final api = snapshot.data;

        if (api == null) {
          // This really shouldn’t happen if your Future<T> never returns null,
          // but guard anyway to keep the compiler happy.
          return const Center(child: Text('No data'));
        }

        // API is valid, so retrieve data about the coming day.
        final hourlyData = api.getHourlyData();  // type: Map<int, Map<String,dynamic>>?

        if (hourlyData == null || hourlyData.isEmpty) {
          // Either there was literally no hourly data, or getHourlyData() chose to return null.
          return const Center(child: Text('No hourly data available'));
        }

        double maxTemp = -double.infinity;
        double minTemp = double.infinity;
        final List<FlSpot> dataPoints = [];

        for (final entry in hourlyData.entries) {
          final hour = entry.key.toDouble();
          final temp = ((entry.value['temperature'] as num).toDouble() - 32) * (5/9);
          dataPoints.add(FlSpot(hour, temp));
          if (temp < minTemp) minTemp = temp;
          if (temp > maxTemp) maxTemp = temp;
        }

        // Build chart
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