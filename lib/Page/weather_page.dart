import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/Model/weather_model.dart';
import 'package:weather_app/Service/weather_service.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  TextEditingController controller = TextEditingController();
  // api key
  final _weatherService =
      WeatherService(apiKey: '76c5575849c2fcee694ad13ce9b8e37a');
  Weather? _weather;

  // fetch weather
  _fetchWeather() async {
    // get the current city
    String cityName = await _weatherService.getCurrentCity();

    //get weather for city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    }

    //any error
    catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    // fetch weather on startup
    _fetchWeather();
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny_animation.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'fug':
      case 'dust':
        return 'assets/cloudy_animation.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/cloudy_animation.json';
      case 'thunderstorm':
        return 'assets/thunder_animation.json';
      case 'clear':
        return 'assets/sunny_animation.json';
      default:
        return 'assets/sunny_animation.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                    ),
                  ),
                  IconButton(
                    onPressed: searchCity,
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              Align(
                child: Text(_weather?.cityName ?? "Loading city..",
                    style: GoogleFonts.inter(
                      textStyle: Theme.of(context).textTheme.displayMedium,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    )),
                //alignment: Alignment.topCenter,
              ),

              const SizedBox(height: 50),

              // animation
              Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),

              const SizedBox(height: 100),
              // city temperature
              Align(
                  child: Text("${_weather?.temperature.round()} °C",
                      style: GoogleFonts.inter(
                        textStyle: Theme.of(context).textTheme.displayMedium,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  void searchCity() async {
    String cityName = controller.text;
    try {
      final newWeather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = newWeather;
      });
    } catch (e) {
      // Handle potential errors during weather retrieval
      // For example, you may want to show an error message to the user.
      // ignore: avoid_print
      print(e);
    }
  }
}
