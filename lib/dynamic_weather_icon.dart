import 'package:flutter/material.dart';
import 'package:interaction_design/condition_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interaction_design/temp_graph.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'API.dart';
import 'alerts.dart';
import 'temp_graph.dart';
import 'rain_graph.dart';
import 'second_page.dart';

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