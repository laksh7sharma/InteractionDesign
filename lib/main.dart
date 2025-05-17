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
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        // 
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    /// Define the app routes
    initialRoute: '/',
    routes: {
      '/second': (context) => const SecondPage(),
    }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            tooltip: 'Go to Second Page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecondPage()),
              );
            },
          ),
        ],
      ),

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AlertUtils.showPopup(context:context, title:"Test Popup", message:"This is a test popup", );
          AlertUtils.showPopup(context:context, title:"Test Popup 2", message:"This is a test popup", );
            
          
        },
        child: const Text('Test Popup'),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {

  void updateFutureInfo (postCode){
    API LocData = new API(postCode);
    Map<String, Map<String, dynamic>> data = LocData.getFutureData();
    print(data);



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Future Overview"),
      ),
      body: Stack( // Use Stack to overlay button
        children: [
          GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 1,
            childAspectRatio: 7,
            children: <Widget>[

              Container(
                padding: const EdgeInsets.all(16),
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.teal[100],
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
                        crossAxisAlignment: CrossAxisAlignment.start,  // changed to start for left alignment
                        children: const [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 8),
                              Text('Monday '),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom Left
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 8),
                              Text('H: L:'),
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.water_drop),
                              SizedBox(width: 8),
                              Text('Rainfall ...%'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right (fourth Expanded)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
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