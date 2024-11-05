import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/Model/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // ignore: constant_identifier_names
  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService({required this.apiKey});

  Future<Weather> getWeather(String cityName) async {
    final response = await http
        .get(Uri.parse("$BASE_URL?q=$cityName&appid=$apiKey&units=metric"));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    // get permission from user
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // fetch the current location
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true,
    );

    // convert the location into a of placemark objects
    List<Placemark> placemark = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);

    // Extract the city name from the first placemark
    String? city = placemark[0].locality;

    // if null just return blank
    return city ?? "";
  }

  Future<void> searchNewLocation(String cityName) async {

    // Use geocoding to retrieve the latitude and longitude for the city name

    // Read location from address name
    List<Location> locations = await locationFromAddress(cityName);
    
    // Check if any location were found
    if (locations.isEmpty){
      throw Exception('Location not found for $cityName');
    }

    // Use the first location's coordinates to update the current location
    await setNewLocation(locations[0].latitude, locations[0].longitude);
  }

  Future<String> setNewLocation(double latitude, double longitude) async {
    // Convert the coordinates into a placemark to get the city name
    List<Placemark> placemark = await placemarkFromCoordinates(latitude, longitude);

    // Extract the city name from the first placemark
    String? city = placemark[0].locality;

    // If null, return an empty string
    return city ?? "";
  }

}
