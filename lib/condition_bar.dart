import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:interaction_design/main.dart';
import 'package:weather_icons/weather_icons.dart';
import 'API.dart';
import 'dart:math';

class ConditionBar extends StatelessWidget {
  final String postcode;
  final ScrollController scrollController;
  final _width = 1000; // Total width of the horizontal bar

  // Map weather condition strings to corresponding icons
  final Map<String, IconData> weatherIconMap = {
    'Clear': WeatherIcons.day_sunny,
    'Partially cloudy': WeatherIcons.day_cloudy,
    'Overcast': WeatherIcons.cloudy,
    'Rain': WeatherIcons.rain,
    'Snow': WeatherIcons.snow,
    'Thunderstorm': WeatherIcons.thunderstorm,
  };

  ConditionBar(this.postcode, this.scrollController, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<API>(
      future: API.create(postcode),
      builder: (context, snapshot) {
        // If waiting for API to finish getting response, show progress circle.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Catch and report an error if it occurs
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // The future is done so the API has been created, and may be retrieved.
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

        // Build list of weather condition icons for each hour
        final List<Widget> icons = [];

        for (final entry in hourlyData.entries) {
          if (entry.key == 24) {
            continue; // Skip the 24th hour if present (e.g., overflow)
          }

          final condition = entry.value['conditions']; // e.g., 'Rain', 'Clear'
          icons.add(
            Container(
              width: _width / 24, // Each hour gets equal space
              child: DynamicWeatherIcon(
                icon: weatherIconMap['$condition'] ?? WeatherIcons.day_sunny, // Fallback to sunny if unknown
                size: 20,
                color: Colors.black,
              ),
            ),
          );
        }

        // Return scrollable row of icons with left padding for y-axis alignment
        return Container(
          height: 25,
          child: Row(
            children: [
              SizedBox(width: 40), // Space for y-axis (aligns with TempGraph)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: scrollController,
                  child: Container(
                    width: _width.toDouble(),
                    child: Row(children: icons), // All weather icons in a row
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
