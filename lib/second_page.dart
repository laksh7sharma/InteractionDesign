import 'package:flutter/material.dart';
import 'API.dart';
import 'package:weather_icons/weather_icons.dart';
import 'dynamic_weather_icon.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);
  final String title = 'Future Overview';

  @override
  _SecondPageState createState() => _SecondPageState();
}
//second page class for the future overview page
class _SecondPageState extends State<SecondPage> {
  late Future<API> _locDataFuture;
//initialise variables for fields to be displayed for each day
  String lowTemp = '';
  String highTemp = '';
  String conditions = '';
  String precip = '';
  bool loading = true;

  List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  @override
  void initState() {
    super.initState();
    _locDataFuture = API.create('EN5 5DS');
  }

  //get data from the API class
  Future<void> loadWeatherData(API locData, int i) async {
    Map<String, Map<String, dynamic>> data = await locData.getFutureData();
    final day = data[i.toString()];
    setState(() {
      lowTemp = day?["lowTemperature"].toString() ?? 'N/A';
      highTemp = day?["highTemperature"].toString() ?? 'N/A';
      conditions = day?["conditions"].toString() ?? 'N/A';
      precip = day?["rainfall"].toString() ?? 'N/A';
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<API>( //using the API class
      future: _locDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final API locData = snapshot.data!;
          final data = locData.getFutureData();
          final day1 = data["1"];


          /*var day_data = [
            data["1"],
            data["2"],
            data["3"],
            data["4"],
            data["5"],
            data["6"],
            data["7"],
          ];*/

          //stored data for each day from the API class - this could be made more efficient using an array
          final day2 = data["2"];
          final day3 = data["3"];
          final day4 = data["4"];
          final day5 = data["5"];
          final day6 = data["6"];
          final day7 = data["7"];

          //assigned weather icons for weather forecast conditions using the icons package
          final Map<String, IconData> weatherIconMap = {
            'Clear': WeatherIcons.day_sunny,
            'Partially cloudy': WeatherIcons.day_cloudy,
            'Overcast': WeatherIcons.cloudy,
            'Rain': WeatherIcons.rain,
            'Snow': WeatherIcons.snow,
            'Thunderstorm': WeatherIcons.thunderstorm,
          };
          //for day1 stored the low and high temperature and converted Fahrenheit to Celsius
          final String lowTemp =
          (((day1?["lowTemperature"]).toDouble() - 32) * (5 / 9))
              .truncate()
              .toString();

          final String highTemp =
          (((day1?["highTemperature"]).toDouble() - 32) * (5 / 9))
              .truncate()
              .toString();
          //similarly stored the precipitation and conditions data for day 1
          final String precip = day1?["rainfall"].toString() ?? '...';
          final String conditions = day1?["conditions"].toString() ?? '';
          final defaultWeather = WeatherIcons.day_sunny; //in case the weather conditions were not received

          //for more efficient implementation in the future
          Map<String, String> lowTempData = {};
          Map<String, String> highTempData = {};
          Map<String, String> precipData = {};
          Map<String, String> conditionsData = {};

          /*for (var day in day_data) {
            lowTempData['Monday']= day?["lowTemperature"].toString() ?? 'N/A';
            highTempData.add(day?["highTemperature"].toString() ?? 'N/A');
            precipData.add(day?["rainfall"].toString() ?? '...');
            conditionsData.add(day?["conditions"].toString() ?? '');
          }*/
          //similarly repeated for the the other 6 days of the week
          //this code could be made cleaner by using a for loop, this change can be made in the next stage of the development process
          //as this is just a prototype
          lowTempData['Thursday'] =
              (((day2?["lowTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          highTempData['Thursday'] =
              (((day2?["highTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          precipData['Thursday'] = day2?["rainfall"].toString() ?? '...';
          conditionsData['Thursday'] = day2?["conditions"].toString() ?? '';

          lowTempData['Friday'] =
              (((day3?["lowTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          highTempData['Friday'] =
              (((day3?["highTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          precipData['Friday'] = day3?["rainfall"].toString() ?? '...';
          conditionsData['Friday'] = day3?["conditions"].toString() ?? '';

          lowTempData['Saturday'] =
              (((day4?["lowTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          highTempData['Saturday'] =
              (((day4?["highTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          precipData['Saturday'] = day4?["rainfall"].toString() ?? '...';
          conditionsData['Saturday'] = day4?["conditions"].toString() ?? '';

          lowTempData['Sunday'] =
              (((day5?["lowTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          highTempData['Sunday'] =
              (((day5?["highTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          precipData['Sunday'] = day5?["rainfall"].toString() ?? '...';
          conditionsData['Sunday'] = day5?["conditions"].toString() ?? '';

          lowTempData['Monday'] =
              (((day6?["lowTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          highTempData['Monday'] =
              (((day6?["highTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          precipData['Monday'] = day6?["rainfall"].toString() ?? '...';
          conditionsData['Monday'] = day6?["conditions"].toString() ?? '';

          lowTempData['Tuesday'] =
              (((day7?["lowTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          highTempData['Tuesday'] =
              (((day7?["highTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString();
          precipData['Tuesday'] = day7?["rainfall"].toString() ?? '...';
          conditionsData['Tuesday'] = day7?["conditions"].toString() ?? '';

          //designing page UI
          return Scaffold(
            appBar: AppBar( //design for the top section of the page
              //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text( //
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  //fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Color(0xff91ca95), //same colour as the main page to make it cohesive
            ),
            body: Stack(
              children: [
                GridView.count(
                  primary: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 1,
                  childAspectRatio: 7,
                  children: <Widget>[
                    Container( //container for the first day
                      padding: const EdgeInsets.all(16),
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: BoxDecoration(
                        color: const Color(0xffb4cf90),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Wednesday', //display day
                                        overflow: TextOverflow.ellipsis,//to avoid overflow errors - ellipsis will show if content too long
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(width: 1),
                                    Flexible(
                                      child: Text(
                                        "L: $lowTemp° H: $highTemp°", //display high and low temp
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.water_drop, //icon for precipitation
                                      color: Color(0xff8ae0ef),
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        '$precip mm', //display precipitation
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: DynamicWeatherIcon(
                                            icon:
                                            weatherIconMap['$conditions'] ?? //display the appropriate icon depending on condition as defined above
                                                WeatherIcons.day_sunny, //else revert to default day icon
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (var day in [ //in the exact same way - create containers for the other 6 days
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday',
                      'Monday',
                      'Tuesday',
                    ])
                    // the container below is identical to the one above
                    // in the next stage of development (after the prototype stage
                    // can reduce the length of code by just having 1 singular for loop for all the containers rather than splitting into 2 like this)
                      Container(
                        padding: const EdgeInsets.all(16),
                        height: MediaQuery.of(context).size.height * 0.2,
                        decoration: BoxDecoration(
                          color: const Color(0xffb4cf90),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          day,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 1),
                                      Flexible(
                                        child: Text(
                                          "L: ${lowTempData[day]}° H: ${highTempData[day]}°",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.water_drop,
                                        color: Color(0xff8ae0ef),
                                      ),
                                      const SizedBox(width: 2),
                                      Flexible(
                                        child: Text(
                                          '${precipData[day]} mm',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: DynamicWeatherIcon(
                                              icon:
                                              weatherIconMap['${conditionsData[day]}'] ??
                                                  WeatherIcons.day_sunny,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                //back button to return to main page again - added to the bottom of the page as this will be the user's natural line of sight
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      child: const Text("Go back"),
                      onPressed: () { //button is highlighted when hovered over
                        Navigator.pop(context);
                      },
                    ),
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