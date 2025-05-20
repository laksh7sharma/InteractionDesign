import 'package:flutter/material.dart';
import "API.dart";
import 'alerts.dart';
import 'package:weather_icons/weather_icons.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherHomePage(title: 'Weather Dashboard'),
    /// Define the app routes
    initialRoute: '/',
    routes: {
      '/second': (context) => const SecondPage(),
    }
    );
  }
}

class WeatherHomePage extends StatelessWidget {
  final String title;
  const WeatherHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(title),
      backgroundColor: Color(0xFFefd98a),
      elevation: 0,
      actions: [
        // ── Navigation button that pushes MyHomePage ──
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          tooltip: 'Go to Counter Page',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SecondPage(),
              ),
            );
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
            colors: [
              Color(0xFF86ca97),
              Color(0xFFefd98a),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOCATION section
                const Text(
                  'LOCATION',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // YESTERDAY and TODAY in a row
                Row(
                  children: [
                    // YESTERDAY section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YESTERDAY',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                          const Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 20),

                // TEMPERATURE GRAPH and WEATHER ICONS section
                const Text(
                  'TEMPERATURE GRAPH',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0x55909090),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'WEATHER ICONS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 20),

                // RAINFALL GRAPHS and ALERTS section
                const Text(
                  'RAINFALL GRAPHS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'ALERTS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
            color: Colors.red,              // solid red
            child: PageView.builder(         // swipe if >1 alert
              itemCount: alerts.length,
              itemBuilder: (ctx, i) {
                final a = alerts[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      '${a.title}: ${a.message}',
                      style: const TextStyle(
                        color: Colors.white,     // white text
                        fontSize: 14,            // smaller font
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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
      ),
    );
  }
}




class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);
  final String title = 'Second Page';
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage>  {
  final API locData = API('EN5 5DS');
  String lowTemp = '';
  String highTemp = '';
  String conditions = '';
  String precip = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWeatherData(1);
  }

  Future<void> loadWeatherData(int i) async {
    Map<String, Map<String, dynamic>> data = await locData.getFutureData();
    final day = data[i];
    setState(() {
      lowTemp = day?["lowTemperature"].toString() ?? 'N/A';
      print(lowTemp);
      highTemp = day?["highTemperature"].toString() ?? 'N/A';
      conditions = day?["conditions"] ?? 'N/A';
      precip = day?["precip"]?? 'N/A';
      loading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        
      ),
        body: Stack( //use flutter_neumorphic: ^3.3.0??
        children: [
          GridView.count(
            primary: false,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 1,
            childAspectRatio: 7,
            children: <Widget>[

              //test widget

              Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: BoxDecoration(
                  color: Colors.teal[100], //could add gradient?
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
                        children: const [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 8),
                              Text('Monday'), //need to add text style
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom Left
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 8),
                              Text("L: $lowTemp° H: $highTemp°"),

                            ],
                          ),
                        ],
                      ),
                    ),

                    // Center
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(Icons.water_drop, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              //Text("Rainfall: $precip"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right (fourth Expanded)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: const [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              SizedBox(width: 8),
                              DynamicWeatherIcon(icon: WeatherIcons.rain_wind, size: 25,),
                              Text('...mm'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text('Monday', style: TextStyle(fontSize: 18)),
              ),

              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.teal[100],
                child: const Text("Tuesday"),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.teal[200],
                child: const Text('Wednesday'),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.teal[300],
                child: const Text('Thursday'),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.teal[400],
                child: const Text('Friday'),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.teal[500],
                child: const Text('Saturday'),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.teal[600],
                child: const Text('Sunday'),
              ),
            ],
          ),
          Positioned( // Proper placement within Stack
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                child: Text("Go back"),
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