import 'package:timely/owm/owm_dependencies.dart';

/// Represents the response from OpenWeatherMaps Current Weather API
///
/// Uses JSON to construct an object from the response
class OWMCurrentWeather {
  Coordinates coord;
  List<WeatherType>? weather;
  String? base;
  Temperature main;
  int? visibility;
  WindData? wind;
  Cloud? clouds;
  RainData? rain;
  SnowData? snow;
  int dt;
  SystemData? sys;
  int? timezone;
  int? id;
  String? name;
  int? cod;
  DateTime recorded_at;

  OWMCurrentWeather(this.coord, this.weather, this.base, this.main, this.visibility,
      this.wind, this.clouds, this.rain, this.snow, this.dt, this.sys, this.timezone,
      this.id, this.name, this.cod, this.recorded_at);

  //https://www.bezkoder.com/dart-flutter-parse-json-string-array-to-object-list/
  factory OWMCurrentWeather.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    List<WeatherType>? weather;
    String? base;
    int? visibility;
    WindData? wind;
    Cloud? clouds;
    RainData? rain;
    SnowData? snow;
    int dt = DateTime.now().millisecondsSinceEpoch;
    SystemData? sys;
    int? timezone;
    int? id;
    String? name;
    int? cod;

    if (json['weather'] != null) {
      var weatherObjsJson = json['weather'] as List;
      weather = weatherObjsJson
          .map((weatherJson) => WeatherType.fromJson(weatherJson))
          .toList();
    }
    if (json['base'] != null) {
      base = json['base'].toString();
    }
    if (json['visibility'] != null) {
      visibility = json['visibility'].toInt();
    }
    if (json['wind'] != null) {
      wind = WindData.fromJson(json['wind']);
    }
    if (json['clouds'] != null) {
      clouds = Cloud.fromJson(json['clouds']);
    }
    if (json['rain'] != null) {
      rain = RainData.fromJson(json['rain']);
    }
    if (json['snow'] != null) {
      snow = SnowData.fromJson(json['snow']);
    }
    if (json['dt'] != null) {
      dt = json['dt'].toInt();
    }
    if (json['sys'] != null) {
      sys = SystemData.fromJson(json['sys']);
    }
    if (json['timezone'] != null) {
      timezone = json['timezone'].toInt();
    }
    if (json['id'] != null) {
      id = json['id'].toInt();
    }
    if (json['name'] != null) {
      name = json['name'].toString();
    }
    if (json['cod'] != null) {
      cod = json['cod'].toInt();
    }

    // Use JSON values and parsed values to return an instance
    return OWMCurrentWeather(
        Coordinates.fromJson(json['coord']),
        weather,
        base,
        Temperature.fromJson(json['main']),
        visibility,
        wind,
        clouds,
        rain,
        snow,
        dt,
        sys,
        timezone,
        id,
        name,
        cod,
        DateTime.fromMillisecondsSinceEpoch(dt * 1000)
    );
  }
}