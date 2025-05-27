import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'API.dart';
import 'dart:math';

class TempGraph extends StatelessWidget {
  final String postcode;
  final ScrollController scrollController;

  TempGraph(this.postcode, this.scrollController, {Key? key}) : super(key: key);

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

        // Prepare temperature values and line chart points.
        double maxTemp = -double.infinity;
        double minTemp = double.infinity;
        final List<FlSpot> dataPoints = [];

        for (final entry in hourlyData.entries) {
          final hour = entry.key.toDouble();
          final temp =
              ((entry.value['temperature'] as num).toDouble() - 32) *
              (5 / 9); // Convert °F to °C
          dataPoints.add(FlSpot(hour, temp));
          if (temp < minTemp) minTemp = temp;
          if (temp > maxTemp) maxTemp = temp;
        }

        // Round bounds for graph display
        final bottomLineVal = minTemp.floorToDouble();
        final topLineVal = maxTemp.ceilToDouble();

        final lightGrey = Color.fromARGB(255, 175, 175, 175);

        // Build chart UI
        return Row(
          children: [
            // Left-side y-axis with temp labels.
            Container(
              width: 40, // Same width as the left axis reserved size, so that is t7he only part showing
              child: LineChart(
                // We construct a whole line chart, but all but the left axis will be cropped
                LineChartData(
                  minX: 0,
                  minY: bottomLineVal,
                  maxY: topLineVal,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    // Only have left title showing
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          // Show labels only for specific points
                          if (value % 5 == 0) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(0),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          } else if (value == maxTemp.ceilToDouble()) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(0),
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 99, 0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else if (value == minTemp.floorToDouble()) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(0),
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 143, 186),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
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
                  lineBarsData: [LineChartBarData(spots: [])],
                ),
              ),
            ),
            // Scrollable graph area
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    child: Container(
                      width: 1000,
                      child: LineChart(
                        LineChartData(
                          // Reference lines
                          extraLinesData: ExtraLinesData(
                            // Line at x = 0
                            verticalLines: [
                              VerticalLine(
                                x: 0,
                                color: Color.fromARGB(255, 100, 100, 100),
                                strokeWidth: 1,
                              ),
                            ],

                            // 2 lines at y=max and y=min, since these are normally missed
                            horizontalLines: [
                              HorizontalLine(
                                y: topLineVal,
                                color:
                                    topLineVal % 5 == 0
                                        ? Color.fromARGB(255, 100, 100, 100)
                                        : lightGrey,
                                strokeWidth: 1,
                              ),
                              HorizontalLine(
                                y: bottomLineVal,
                                color:
                                    bottomLineVal % 5 == 0
                                        ? Color.fromARGB(255, 100, 100, 100)
                                        : lightGrey,
                                strokeWidth: 1,
                              ),
                            ],
                          ),
                          minX: 0,
                          minY: bottomLineVal,
                          maxY: topLineVal,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            drawVerticalLine: true,
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Color.fromARGB(255, 100, 100, 100),
                                strokeWidth: 1,
                              );
                            },
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              // Make every multiple of 5 line darker.
                              if (value % 5 == 0) {
                                return FlLine(
                                  color: Color.fromARGB(255, 100, 100, 100),
                                  strokeWidth: 1,
                                );
                              } else {
                                return FlLine(color: lightGrey, strokeWidth: 1);
                              }
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
                                  // Display hour label underneath each major tick
                                  final hour =
                                      hourlyData[value.toInt()]!['hours'];
                                  final label = hour;
                                  return SideTitleWidget(
                                    space: 0,
                                    meta: meta,
                                    child: Transform.translate(
                                      offset: Offset(19.5, 0), // Offset so every label is to the right of the tick
                                      child: Container(
                                        width: 40,
                                        decoration: BoxDecoration(
                                          // Add a left border as a tick
                                          border: Border(
                                            left: BorderSide(
                                              color: Color.fromARGB(
                                                255,
                                                100,
                                                100,
                                                100,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Text(
                                            textAlign: TextAlign.right,
                                            label,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
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
                            // Main temperature line
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
                  // Fading gradient on the right to suggest scrollability
                  Align(
                    alignment: Alignment.centerRight,
                    child: IgnorePointer( // To prevent absorbing scrolling input
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
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
        );
      },
    );
  }
}
