import 'package:flutter/material.dart';
import 'package:interaction_design/condition_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interaction_design/temp_graph.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'API.dart';
import 'alerts.dart';
import 'temp_graph.dart';
import 'rain_graph.dart';
import 'second_page.dart';
import 'scroll_synchronizer.dart';

// Entry point of the app
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set properties
  if (Platform.isWindows) {
    setWindowTitle('Garden weather app');
    setWindowFrame(Rect.fromLTWH(100, 100, 800, 1400));
    if (args.length >= 2) {
      var width = double.tryParse(args[0]);
      var height = double.tryParse(args[1]);
      if (width!= null && height != null) {
        setWindowFrame(Rect.fromLTWH(100, 100, width, height));
      }
    }
  }

  await NotificationService().init();
  await dotenv.load(fileName: "_env"); // Load environment variables
  runApp(const MyApp());
}

// Root widget of the application
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

// Main home page widget
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

  Map<String, dynamic>? _yesterdaySummary;
  Map<String, dynamic>? _todayInfo;

  final titleColour = Colors.black;

  @override
  void initState() {
    super.initState();
    // On startup, load saved postcode and data
    _loadSavedPostcode().then((_) {
      _checkAlerts();
      _loadSummaries();
      if (_savedPostcode != null) {
        setState(() {
          _currentPostcode = _savedPostcode!;
          _postcodeController.text = _savedPostcode!;
        });
      }
    });
  }

  // Retrieve postcode from persistent storage
  Future<void> _loadSavedPostcode() async {
    final prefs = await SharedPreferences.getInstance();
    _savedPostcode = prefs.getString('uk_postcode');
  }

  // Save postcode to persistent storage
  Future<void> _savePostcode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uk_postcode', value);
    setState(() {
      _savedPostcode = value;
      _currentPostcode = value;
    });
  }

  // Handler when postcode is submitted
  void _onPostcodeSubmitted(String value) {
    final trimmed = value.trim().toUpperCase();
    if (_postcodeRegex.hasMatch(trimmed)) {
      _savePostcode(trimmed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Postcode saved: $trimmed')),
      );
      setState(() {}); // Trigger widget updates
      _checkAlerts();
      _loadSummaries();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid UK postcode.')),
      );
    }
  }

  // Checks for various weather-related alerts and displays popups
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
      if (info['lowTemperature'] < 37) {
        AlertUtils.showPopup(
          title: 'Low temperature alert',
          message: 'Wear a coat, it\'s cold outside!',
        );
      }
      
    } catch (e) {
      debugPrint('Error checking alerts: $e');
    }
  }

  // Loads yesterday's summary and today's weather data
  Future<void> _loadSummaries() async {
    try {
      final api = await API.create(_currentPostcode);
      final y = api.getYesterdaySummary();
      final t = api.getTodayOverallInfo();

      double toC(double f) => ((f - 32) * 5 / 9 * 10).round() / 10;

      setState(() {
        _yesterdaySummary = {
          'lowTemperature': toC(y['lowTemperature']),
          'highTemperature': toC(y['highTemperature']),
          'rainfall': y['rainfall'],
        };
        _todayInfo = {
          'currentTemperature': toC(t['currentTemperature']),
          'feelsLikeTemperature': toC(t['feelsLikeTemperature']),
          'windSpeed': t['windSpeed'],
          'windDir': t['windDir'],
          'lowTemperature': toC(t['lowTemperature']),
          'highTemperature': toC(t['highTemperature']),
        };
      });
    } catch (e) {
      debugPrint('Error loading summaries: $e');
    }
  }

  @override
  void dispose() {
    _postcodeController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScrollSynchronizer scrollSynchronizer = ScrollSynchronizer();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xff91ca95),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'See Future Overview',
            onPressed: () => Navigator.pushNamed(context, '/second'),
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
              // LOCATION INPUT SECTION
              Text('Location', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              _buildPostcodeInput(),

              if (_savedPostcode != null) ...[
                const SizedBox(height: 8),
                Text('Saved postcode: $_savedPostcode',
                    style: const TextStyle(color: Colors.white70)),
              ],
              const SizedBox(height: 20),

              // SUMMARY DATA SECTION (YESTERDAY / TODAY)
              _buildSummaryRow(),
              const SizedBox(height: 20),
              _divider(),

              // TEMPERATURE GRAPH
              Text('TEMPERATURE (°C)', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              _buildTempGraph(scrollSynchronizer),

              const SizedBox(height: 20),
              _divider(),

              // RAINFALL GRAPH
              Text('RAINFALL (% chance)', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              _buildRainGraph(scrollSynchronizer),

              const SizedBox(height: 15),

              // ALERTS SECTION
              Text('ALERTS', style: _sectionTitleStyle()),
              const SizedBox(height: 8),
              _buildAlertsList(),
            ],
          ),
        ),
      ),
    );
  }

  // UI helper: styles
  TextStyle _sectionTitleStyle() => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: titleColour,
  );

  Widget _buildPostcodeInput() => TextField(
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
  );

  Widget _buildSummaryRow() => Row(
    children: [
      _buildInfoColumn('YESTERDAY', _yesterdaySummary),
      const SizedBox(width: 16),
      _buildInfoColumn('TODAY', _todayInfo),
    ],
  );

  Widget _buildInfoColumn(String title, Map<String, dynamic>? data) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTitleStyle()),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0x55303030),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: data == null
                ? const Text('Loading...', style: TextStyle(color: Colors.white))
                : Text(
              title == 'YESTERDAY'
                  ? 'L:${data['lowTemperature']}°\nH:${data['highTemperature']}°\nRainfall:${data['rainfall'].toStringAsFixed(3)}mm'
                  : 'Now: ${data['currentTemperature']}°\nFeels: ${data['feelsLikeTemperature']}°\nL: ${data['lowTemperature']}°  H: ${data['highTemperature']}°\nWind: ${data['windSpeed']}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _divider() => Container(height: 2, color: Colors.white.withOpacity(0.5));

  Widget _buildTempGraph(ScrollSynchronizer sync) => Container(
    height: 250,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(
      color: const Color(0x44FFFFFF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        ConditionBar(_currentPostcode, sync.getNewSynchronizedController()),
        const SizedBox(height: 10),
        Expanded(child: TempGraph(_currentPostcode, sync.getNewSynchronizedController())),
      ],
    ),
  );

  Widget _buildRainGraph(ScrollSynchronizer sync) => Container(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
    decoration: BoxDecoration(
      color: const Color(0x44FFFFFF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: RainGraph(_currentPostcode, sync.getNewSynchronizedController()),
  );

  Widget _buildAlertsList() => ValueListenableBuilder<List<AlertData>>(
    valueListenable: alertsNotifier,
    builder: (context, alerts, _) {
      if (alerts.isEmpty) return const SizedBox(height: 60);
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
                final current = List<AlertData>.from(alertsNotifier.value);
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
  );
}

// A simple reusable info display box (not currently used in main UI)
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
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(displayText, style: const TextStyle(fontSize: 18)),
    );
  }
}
