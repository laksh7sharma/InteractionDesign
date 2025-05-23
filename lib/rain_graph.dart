import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'API.dart';
import 'dart:math';

class RainGraph extends StatelessWidget {
  final String postcode;
  final ScrollController scrollController;
  bool isRain = false;

  RainGraph(this.postcode, this.scrollController, {Key? key}) : super(key: key);

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
        final hourlyData =
            api.getHourlyData(); // type: Map<int, Map<String,dynamic>>?

        if (hourlyData == null || hourlyData.isEmpty) {
          // Either there was literally no hourly data, or getHourlyData() chose to return null.
          return const Center(child: Text('No hourly data available'));
        }

        final List<BarChartGroupData> bars = [];

        double maxRain = 0;

        for (final entry in hourlyData.entries) {
          if (entry.key == 24) {
            continue;
          }

          final hour = entry.key.toDouble();
          final rainfall = entry.value['rainfall'];
          if (rainfall > maxRain) {
            maxRain = rainfall;
          }
          bars.add(
            BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: rainfall,
                  width: 35,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10),
                    bottom: Radius.zero,
                  ),
                ),
              ],
            ),
          );
        }

        if (maxRain == 0) {
          // Build no rain message
          return Row(
            children: [
              Expanded(
                child: Text(
                  "No rain today!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),
            ],
          );
        } else {
          // Build chart
          return Container(
            height: 150,
            child: Row(
              children: [
                Container(
                  width: 40,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [BarChartRodData(toY: maxRain, width: 0)],
                        ),
                      ],
                      alignment: BarChartAlignment.end,
                      barTouchData: BarTouchData(enabled: false),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            minIncluded: false,
                            maxIncluded: true,
                            interval: 1000,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value == maxRain) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    maxRain.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: scrollController,
                        child: Container(
                          width: 1000,
                          child: BarChart(
                            BarChartData(
                              barGroups: bars,
                              extraLinesData: ExtraLinesData(
                                horizontalLines: [HorizontalLine(y: maxRain, color: Colors.grey)],
                              ),
                              alignment: BarChartAlignment.center,
                              barTouchData: BarTouchData(enabled: false),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                    reservedSize: 0,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 2,
                                    reservedSize: 30,
                                    getTitlesWidget:
                                        (value, meta) =>
                                            value % 2 == 0
                                                ? SideTitleWidget(
                                                  meta: meta,
                                                  child: Text(
                                                    hourlyData[value
                                                        .toInt()]!['hours'],
                                                  ),
                                                )
                                                : SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IgnorePointer(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                      colors: [
                                        Colors.black.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
