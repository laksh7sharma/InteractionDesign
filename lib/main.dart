import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interaction_design/temp_graph.dart';
import 'API.dart';
import 'alerts.dart';
import 'package:weather_icons/weather_icons.dart';
import 'temp_graph.dart';
import 'rain_graph.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class DynamicWeatherIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const DynamicWeatherIcon({
    Key? key,
    required this.icon,
    this.size = 40,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BoxedIcon(icon, size: size, color: color);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'weather app',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherHomePage(title: 'Weather Dashboard'),
      initialRoute: '/',
      routes: {'/second': (context) => const SecondPage()},
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  final String title;

  const WeatherHomePage({super.key, required this.title});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _postcodeController = TextEditingController();
  String? _savedPostcode;
  String _currentPostcode = 'CB2 8PH';
  final RegExp _postcodeRegex = RegExp(
    r'^[A-Z]{1,2}\d{1,2}[A-Z]?\s*\d[A-Z]{2}$',
    caseSensitive: false,
  );
  late ScrollController _scrollController1 = ScrollController();
  late ScrollController _scrollController2 = ScrollController();
  bool _isSyncingScroll = false;

  final titleColour = Colors.black;

  @override
  void initState() {
    super.initState();
    _loadSavedPostcode().then((_) {
      _checkAlerts();
      if (_savedPostcode != null) {
        setState(() {
          _currentPostcode = _savedPostcode!;
          _postcodeController.text = _savedPostcode!;
        });
      }
    });

    _scrollController1.addListener(() {
      if (!_scrollController2.hasClients) return;
      if (_isSyncingScroll) return;
      _isSyncingScroll = true;
      _scrollController2.jumpTo(_scrollController1.offset);
      _isSyncingScroll = false;
    });

    _scrollController2.addListener(() {
      if (_isSyncingScroll) return;
      _isSyncingScroll = true;
      _scrollController1.jumpTo(_scrollController2.offset);
      _isSyncingScroll = false;
    });
  }

  Future<void> _loadSavedPostcode() async {
    final prefs = await SharedPreferences.getInstance();
    _savedPostcode = prefs.getString('uk_postcode');
  }

  Future<void> _savePostcode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uk_postcode', value);
    setState(() {
      _savedPostcode = value;
      _currentPostcode = value;
    });
  }

  void _onPostcodeSubmitted(String value) {
    final trimmed = value.trim().toUpperCase();
    if (_postcodeRegex.hasMatch(trimmed)) {
      _savePostcode(trimmed);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Postcode saved: $trimmed')));
      // Trigger rebuild of temperature graph by updating state
      setState(() {});
      _checkAlerts();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid UK postcode.')));
    }
  }

  Future<void> _checkAlerts() async {
    try {
      final api = await API.create(_currentPostcode);
      final info = api.getTodayOverallInfo();
      if (info['frostPresent'] == true) {
        AlertUtils.showPopup(
          title: 'Frost Alert',
          message: 'Temperatures have dropped below freezing!',
        );
      }
      if (info['extremeWindsPresent'] == true) {
        AlertUtils.showPopup(
          title: 'Wind Alert',
          message: 'Extreme wind speeds detected (>30 mph)!',
        );
      }
      if (info['lowTemperature'] < 100) {
        AlertUtils.showPopup(
          title: 'Low Temperature Alert',
          message: 'Low temperature detected (${info['lowTemperature']}°C)!',
        );
      }
    } catch (e) {
      debugPrint('Error checking alerts: $e');
    }
  }

  @override
  void dispose() {
    _postcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xff91ca95),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'See Future Overview',
            onPressed: () {
              Navigator.pushNamed(context, '/second');
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF86ca97), Color(0xFFefd98a)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOCATION section
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: titleColour,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _postcodeController,
                decoration: InputDecoration(
                  hintText: 'Enter UK postcode',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: _onPostcodeSubmitted,
              ),
              if (_savedPostcode != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Saved postcode: $_savedPostcode',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
              const SizedBox(height: 20),
              // YESTERDAY and TODAY in a row
              Row(
                children: [
                  // YESTERDAY section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YESTERDAY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: titleColour,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0x55303030),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'SUMMARY',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // TODAY section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: titleColour,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0x55303030),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'SUMMARY',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Divider line
              Container(height: 2, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 20),

              // TEMPERATURE GRAPH and WEATHER ICONS section
              Text(
                'TEMPERATURE (°C)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColour,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                padding: EdgeInsets.only(top: 20, bottom: 10, left: 10),
                decoration: BoxDecoration(
                  color: const Color(0x44FFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TempGraph(_currentPostcode, _scrollController1),
              ),

              const SizedBox(height: 15),
              Text(
                'WEATHER ICONS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColour,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),

              // Divider line
              Container(height: 2, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 20),

              // RAINFALL GRAPHS and ALERTS section
              Text(
                'RAINFALL (mm)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColour,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.only(top: 20, bottom: 10, left: 10),
                decoration: BoxDecoration(
                  color: const Color(0x44FFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RainGraph(_currentPostcode, _scrollController2),
              ),

              const SizedBox(height: 15),
              Text(
                'ALERTS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColour,
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<List<AlertData>>(
                valueListenable: alertsNotifier,
                builder: (context, alerts, _) {
                  if (alerts.isEmpty) {
                    // keep the space reserved even when no alerts
                    return SizedBox(height: 60);
                  }

                  return Container(
                    height: 60,
                    color: Colors.red,
                    child: PageView.builder(
                      itemCount: alerts.length,
                      itemBuilder: (ctx, i) {
                        final a = alerts[i];
                        return Dismissible(
                          key: ValueKey(a),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            final current = List<AlertData>.from(
                              alertsNotifier.value,
                            );
                            current.removeAt(i);
                            alertsNotifier.value = current;
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Center(
                              child: Text(
                                '${a.title}: ${a.message}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);
  final String title = 'Future Overview';

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late Future<API> _locDataFuture;

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
    return FutureBuilder<API>(
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

          var day_data = [
            data["1"],
            data["2"],
            data["3"],
            data["4"],
            data["5"],
            data["6"],
            data["7"],
          ];
          final day2 = data["2"];
          final day3 = data["3"];
          final day4 = data["4"];
          final day5 = data["5"];
          final day6 = data["6"];
          final day7 = data["7"];

          final Map<String, IconData> weatherIconMap = {
            'Clear': WeatherIcons.day_sunny,
            'Partially cloudy': WeatherIcons.day_cloudy,
            'Overcast': WeatherIcons.cloudy,
            'Rain': WeatherIcons.rain,
            'Snow': WeatherIcons.snow,
            'Thunderstorm': WeatherIcons.thunderstorm,
          };

          final String lowTemp =
              (((day1?["lowTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString() ??
              'N/A';
          ;
          final String highTemp =
              (((day1?["highTemperature"]).toDouble() - 32) * (5 / 9))
                  .truncate()
                  .toString() ??
              'N/A';
          ;
          final String precip = day1?["rainfall"].toString() ?? '...';
          final String conditions = day1?["conditions"].toString() ?? '';
          final defaultWeather = WeatherIcons.day_sunny;

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

          return Scaffold(
            appBar: AppBar(
              //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  //fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Color(0xff91ca95),
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
                                        'Wednesday',
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
                                        "L: $lowTemp° H: $highTemp°",
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
                                        '$precip mm',
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
                                                weatherIconMap['$conditions'] ??
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
                    for (var day in [
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday',
                      'Monday',
                      'Tuesday',
                    ])
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

                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      child: const Text("Go back"),
                      onPressed: () {
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

class InfoBox extends StatefulWidget {
  final String initialData;

  InfoBox({required this.initialData});

  @override
  _InfoBoxState createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> {
  String displayText = "";

  @override
  void initState() {
    super.initState();
    displayText = widget.initialData;
  }

  void updateData(String newData) {
    setState(() {
      displayText = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(displayText, style: TextStyle(fontSize: 18)),
    );
  }
}
