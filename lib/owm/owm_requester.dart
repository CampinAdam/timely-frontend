import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:timely/owm/owm_current_weather.dart';
import 'package:timely/owm/owm_forecast_weather.dart';

/// This class provides a method for getting current weather data from
/// the OpenWeatherMaps API
class OWMRequester {

  final String? owmApiKey = dotenv.env['OWM_API_KEY'];

  /// Use input coordinates to query the OpenWeatherMaps Current Weather API
  Future<OWMCurrentWeather> currentWeather(double lat, double long) async {
    // Check that coordinates are valid
    if (lat < -90 || lat > 90) {
      throw ArgumentError('Invalid latitude value: $lat is not in the expected range');
    }
    if (long < -180 || long > 180) {
      throw ArgumentError('Invalid longitude value: $long is not in the expected range');
    }
    Uri owmUri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$owmApiKey&units=metric');
    final response = await http.get(owmUri);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return OWMCurrentWeather.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load current weather');
    }
  }

  /// Use input coordinates to query the OpenWeatherMaps 5 Day Weather Forecast API
  /// The API returns forecasts at 3 hour intervals for 5 days
  ///
  /// Can specify a limit for how many forecasts to return with the optional third parameter
  Future<OWMForecastWeather> forecastWeather(double lat, double long, [int? limit]) async {
    // Check that coordinates are valid
    if (lat < -90 || lat > 90) {
      throw ArgumentError('Invalid latitude value: $lat is not in the expected range');
    }
    if (long < -180 || long > 180) {
      throw ArgumentError('Invalid longitude value: $long is not in the expected range');
    }
    Uri owmUri;
    if (limit != null) {
      owmUri = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$long&cnt=$limit&appid=$owmApiKey&units=metric');
    } else {
      owmUri = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$long&appid=$owmApiKey&units=metric');
    }
    final response = await http.get(owmUri);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return OWMForecastWeather.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load forecast weather');
    }
  }
}
