import 'package:timely/owm/owm_dependencies.dart';

/// Represents the response from OpenWeatherMaps 5 Day Weather Forecast API
///
/// Uses JSON to construct an object from the response
/// Reuses some subclasses for the OWMCurrentWeather
class OWMForecastWeather {
  String? cod;
  int? message;
  int cnt;
  List<ForecastData>? weather;
  CityData city;
  DateTime recorded_at;

  OWMForecastWeather(this.cod, this.message, this.cnt, this.weather, this.city,
      this.recorded_at);

  //https://www.bezkoder.com/dart-flutter-parse-json-string-array-to-object-list/
  factory OWMForecastWeather.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    String? cod;
    int? message;
    List<ForecastData>? weather;

    if (json['cod'] != null) {
      cod = json['cod'].toString();
    }
    if (json['message'] != null) {
      message = json['message'].toInt();
    }
    if (json['list'] != null) {
      var weatherObjsJson = json['list'] as List;
      weather = weatherObjsJson
          .map((weatherJson) => ForecastData.fromJson(weatherJson))
          .toList();
    }

    // Use JSON values and parsed values to return an instance
    return OWMForecastWeather(
        cod,
        message,
        json['cnt'].toInt(),
        weather,
        CityData.fromJson(json['city']),
        DateTime.now()
    );
  }
}