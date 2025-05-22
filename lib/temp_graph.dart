import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'API.dart';
import 'dart:math';

class TempGraph extends StatelessWidget {
  String postcode = "";

  TempGraph(String postcode) {
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
        final hourlyData =
        api.getHourlyData(); // type: Map<int, Map<String,dynamic>>?

        if (hourlyData == null || hourlyData.isEmpty) {
          // Either there was literally no hourly data, or getHourlyData() chose to return null.
          return const Center(child: Text('No hourly data available'));
        }

        double maxTemp = -double.infinity;
        double minTemp = double.infinity;
        final List<FlSpot> dataPoints = [];

        for (final entry in hourlyData.entries) {
          final hour = entry.key.toDouble();
          final temp =
              ((entry.value['temperature'] as num).toDouble() - 32) * (5 / 9);
          dataPoints.add(FlSpot(hour, temp));
          if (temp < minTemp) minTemp = temp;
          if (temp > maxTemp) maxTemp = temp;
        }

        // Build chart
        return Row(
          children: [
            // y-axis Labels.
            Container(
              width: 30,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  minY: (minTemp / 2).floorToDouble() * 2,
                  maxY: (maxTemp / 2).ceilToDouble() * 2,
                  borderData: FlBorderData(show: false),
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
                        interval: 4,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [],
                    ),
                  ],
                ),
              ),
            ),
            // Graph, scrollable
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: 1000,
                      child: LineChart(
                        LineChartData(
                          extraLinesData: ExtraLinesData(
                            verticalLines: [
                              VerticalLine(
                                x: 0,
                                color: Colors.grey,
                                strokeWidth: 1, // optional: dotted line
                              ),
                            ],
                            horizontalLines: [
                              HorizontalLine(
                                y: (maxTemp / 2).ceilToDouble() * 2,
                                color: Colors.grey,
                                strokeWidth: 1,
                              ),
                              HorizontalLine(
                                y: (minTemp / 2).floorToDouble() * 2,
                                color: Colors.grey,
                                strokeWidth: 1,
                              )
                            ]
                          ),
                          minX: 0,
                          minY: (minTemp / 2).floorToDouble() * 2,
                          maxY: (maxTemp / 2).ceilToDouble() * 2,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            drawVerticalLine: true,
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.grey, // Your custom color
                                strokeWidth:
                                1, // Dottedness: [dash length, space length]
                              );
                            },
                            horizontalInterval: 2,
                            checkToShowHorizontalLine:
                                (value) => value % 2 == 0,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey, // Your custom color
                                strokeWidth:
                                1, // Dottedness: [dash length, space length]
                              );
                            },
                          ),
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
                                interval: 4,
                                reservedSize: 30,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  final hour =
                                  hourlyData[value.toInt()]!['hours'];
                                  final label = hour;
                                  return SideTitleWidget(
                                    space: 0,
                                    meta: meta,
                                    child: Transform.translate(
                                      offset: Offset(19.5, 0),
                                      // shift left by label width
                                      child: Container(
                                        width: 40,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.grey,
                                              // or any color
                                              width:
                                              1, // thickness of the border
                                            ),
                                          ),
                                        ),
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          padding: EdgeInsets.only(top:10),
                                          child: Text(
                                            textAlign: TextAlign.right,
                                            label,
                                            style: const TextStyle(fontSize: 15),
                                        ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
