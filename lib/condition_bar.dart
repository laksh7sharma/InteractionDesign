import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:interaction_design/main.dart';
import 'package:weather_icons/weather_icons.dart';
import 'API.dart';
import 'dart:math';

class ConditionBar extends StatelessWidget {
  final String postcode;
  final ScrollController scrollController;
  final _width = 1000;

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

        final List<Widget> icons = [];

        for (final entry in hourlyData.entries) {
          if (entry.key == 24) {
            continue;
          }

          final condition = entry.value['conditions'];
          icons.add(
            Container(
              width: _width / 24,
              child: DynamicWeatherIcon(
                icon: weatherIconMap['$condition'] ?? WeatherIcons.day_sunny,
                size: 20,
                color: Colors.black,
              ),
            ),
          );
        }

        return Container(
          height: 25,
          child: Row(
            children: [
              SizedBox(width: 40),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: scrollController,
                  child: Container(
                    width: _width.toDouble(),
                    child: Row(children: icons),
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
