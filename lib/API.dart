// Main Page:

// yesterday total rainfall
// yesterday high, low
// today current temperature
// today feels like 
// today wind 
// today high, low
// today weather conditions (ie. cloudy), temperature, rainfall over time 

// Second Page:

// next 7 days each containing:
// high, low, rainfall, weather conditions


import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class API {

late final String _url;
late Map<String, dynamic> _data;
// Map<String, dynamic> _data;

/// Returns a map containing yesterday's weather summary.
/// The map has keys: "rainfall", "lowTemperature", and "highTemperature",
/// corresponding to total rainfall, yesterday's low temperature, and yesterday's high temperature.
Map<String, dynamic> getYesterdaySummary() {
  List<dynamic> hours = _data['days'][0]['hours'];
  int range = 6; // Using 00:00 to 05:00 as a proxy for yesterday

  double totalRain = 0;
  double minTemp = double.infinity;
  double maxTemp = double.negativeInfinity;

  for (int i = 0; i < range; i++) {
    var hourData = hours[i];
    double temp = hourData['temp'];
    double rain = hourData['precip'];

    totalRain += rain;
    if (temp < minTemp) minTemp = temp;
    if (temp > maxTemp) maxTemp = temp;
  }

  return {
    "rainfall": totalRain,
    "lowTemperature": minTemp,
    "highTemperature": maxTemp,
  };
}

/// Returns a JSON structure containing today’s overall weather information.
/// Keys: "currentTemperature", "feelsLikeTemperature", "windSpeed", "windDirection",
/// "lowTemperature", "highTemperature", "frostPresent", "extremeWindsPresent".
Map<String, dynamic> getTodayOverallInfo() {
  var today = _data['days'][0];
  var hours = today['hours'];
  int currentHour = DateTime.now().hour;

  var currentHourData = hours[currentHour];

  double currentTemp = currentHourData['temp'];
  double feelsLike = currentHourData['feelslike'];
  double windSpeed = currentHourData['windspeed'];
  double windDir = currentHourData['winddir'];
  double tempMin = today['tempmin'];
  double tempMax = today['tempmax'];

  bool frostPresent = tempMin < 0;
  bool extremeWindsPresent = windSpeed > 30;

  return {
    "currentTemperature": currentTemp,
    "feelsLikeTemperature": feelsLike,
    "windSpeed": windSpeed,
    "windDirection": windDir,
    "lowTemperature": tempMin,
    "highTemperature": tempMax,
    "frostPresent": frostPresent,
    "extremeWindsPresent": extremeWindsPresent,
  };
}

/// Returns a JSON structure with keys from 0 to 23 representing each hour of the day.
/// Each value is a nested map with keys: "hour" in format of a string 'hh:mm:ss', "temperature" in fahrenheit, "rainfall", and "conditions".
Map<int, Map<String, dynamic>> getHourlyData() {
  final now = DateTime.now();
  final currentHour = now.hour;  
  final days = _data['days'] as List<dynamic>;
  final todayHours = days[0]['hours'] as List<dynamic>;
  final tomorrowHours = days.length > 1 
      ? days[1]['hours'] as List<dynamic> 
      : <dynamic>[];

  final result = <int, Map<String, dynamic>>{};
  int offset = 0;

  // 1) From currentHour → 23 today
  for (int h = currentHour; h < todayHours.length && offset < 24; h++) {
    final hourData = todayHours[h];
    final formattedHour = h.toString().padLeft(2, '0') + ':00';

    result[offset] = {
      "temperature": hourData["temp"],
      "rainfall":    hourData["precipprob"],
      "conditions":  hourData["conditions"],
      "hours":       formattedHour,
    };
    offset++;
  }

  // 2) Then 00 → currentHour−1 tomorrow
  for (int h = 0; h < tomorrowHours.length && offset < 25; h++) {
    final hourData = tomorrowHours[h];
    final formattedHour = h.toString().padLeft(2, '0') + ':00';

    result[offset] = {
      "temperature": hourData["temp"],
      "rainfall":    hourData["precipprob"],
      "conditions":  hourData["conditions"],
      "hours":       formattedHour,
    };
    offset++;
  }

  return result;
}

/// Returns a JSON structure with keys "1" to "7" and values representing daily forecasts.
/// Each structure contains "lowTemperature", "highTemperature", "rainfall", and "conditions".
Map<String, Map<String, dynamic>> getFutureData() {
  List<dynamic> days = _data['days'];

  Map<String, Map<String, dynamic>> result = {};

  for (int i = 1; i <= 7 && i < days.length; i++) {
    var dayData = days[i];

    result[i.toString()] = {
      "lowTemperature": dayData["tempmin"],
      "highTemperature": dayData["tempmax"],
      "rainfall": dayData["precip"],
      "conditions": dayData["conditions"]
    };
  }

  return result;
}


  // Private constructor
  API._(this._url, this._data);

  // Async factory constructor
  static Future<API> create(String postCode) async {
    String apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('API key is missing. Please add it to your .env file.');
    }

    String formattedPostCode = postCode.replaceAll(' ', '%20');
    String url =
        "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$formattedPostCode?unitGroup=us&key=$apiKey&contentType=json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return API._(url, data);
      } else {
        throw Exception("Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error occurred while fetching weather data: $e");
    }
  }

  // Example method that uses _data
  Map<String, dynamic> getTodaySummary() {
    return _data['days'][0];
  }

}
