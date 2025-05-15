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


class API {

late final String _url;
late final Map<String, dynamic> _data;

// Returns a map containing yesterday's weather summary.
// The map has keys: "rainfall", "lowTemperature", and "highTemperature",
// corresponding to total rainfall, yesterday's low temperature, and yesterday's high temperature.
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


// Returns a json structure containing today’s overall weather information.
// The json structure has keys: "currentTemperature", "feelsLikeTemperature", "windSpeed", "frostPresent", "extremeWindsPresent"
// "windDirection", "lowTemperature", and "highTemperature".
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

// Returns a json structure with keys from 0 to 23 representing each hour of the day.
// Each value is a nested map with keys "temperature", "rainfall", and "conditions",
// representing hourly temperature, rainfall, and weather condition (e.g., "cloudy").
Map<int, Map<String, dynamic>> getHourlyData() {
  List<dynamic> hours = _data['days'][0]['hours'];

  Map<int, Map<String, dynamic>> result = {};

  for (int i = 0; i < hours.length; i++) {
    var hourData = hours[i];
    result[i] = {
      "temperature": hourData["temp"],
      "rainfall": hourData["precip"],
      "conditions": hourData["conditions"]
    };
  }

  return result;
}


// Returns a json structure which has keys "1", "2", .. "7" and values which are json structures representing the weather for the next 7 days. 
// Each structure contains "lowTemperature", "highTemperature", "rainfall", and "conditions".
Map<String, Map<String, dynamic>> getFutureData() {
  List<dynamic> days = _data['days'];
  Map<String, Map<String, dynamic>> result = {};

  for (int i = 1; i <= 7; i++) {
    var day = days[i];

    result[i.toString()] = {
      "lowTemperature": day["tempmin"],
      "highTemperature": day["tempmax"],
      "rainfall": day["precip"],
      "conditions": day["conditions"]
    };
  }

  return result;
}


// Initializer - postCode is a string of the form "XXX XXX"
API(String postCode) {
    String formattedPostCode = postCode.replaceAll(' ', '%20');
    _url =
        "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$formattedPostCode?unitGroup=us&key=TB7ZNBTHMPNQXYBA5ZW3HXQQ4&contentType=json";

    _fetchData();
  }

// Asynchronous method to fetch and print the weather data
Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        _data = jsonDecode(response.body);
        print("Weather data for the given postcode:");
        // print(jsonEncode(data)); // Pretty raw, you can refine this later
      } else {
        print("Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

}
