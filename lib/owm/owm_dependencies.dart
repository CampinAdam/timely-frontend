
/// Shared classes ///

class WeatherType {
  int id;
  String? main;
  String? description;
  String? icon;

  WeatherType(this.id, this.main, this.description, this.icon);

  factory WeatherType.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    String? main;
    String? description;
    String? icon;

    if (json['main'] != null) {
      main = json['main'].toString();
    }
    if (json['description'] != null) {
      description = json['description'].toString();
    }
    if (json['icon'] != null) {
      icon = json['icon'].toString();
    }

    // Use JSON values and parsed values to return an instance
    return WeatherType(
        json['id'].toInt(),
        main,
        description,
        icon
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    'id': id,
    'main': main,
    'description': description,
    'icon': icon
  };
}

class Temperature {
  double temp;
  double? feels_like;
  double? temp_min;
  double? temp_max;
  double? pressure;
  double? humidity;
  int? sea_level;
  int? grnd_level;

  Temperature(this.temp, this.feels_like, this.temp_min, this.temp_max,
      this.pressure, this.humidity, this.sea_level, this.grnd_level);

  factory Temperature.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    double? feels_like;
    double? temp_min;
    double? temp_max;
    double? pressure;
    double? humidity;
    int? sea_level;
    int? grnd_level;

    if (json['feels_like'] != null) {
      feels_like = json['feels_like'].toDouble();
    }
    if (json['temp_min'] != null) {
      temp_min = json['temp_min'].toDouble();
    }
    if (json['temp_max'] != null) {
      temp_max = json['temp_max'].toDouble();
    }
    if (json['pressure'] != null) {
      pressure = json['pressure'].toDouble();
    }
    if (json['humidity'] != null) {
      humidity = json['humidity'].toDouble();
    }
    if (json['sea_level'] != null) {
      sea_level = json['sea_level'].toInt();
    }
    if (json['grnd_level'] != null) {
      grnd_level = json['grnd_level'].toInt();
    }

    // Use JSON values and parsed values to return an instance
    return Temperature(
        json['temp'].toDouble(),
        feels_like,
        temp_min,
        temp_max,
        pressure,
        humidity,
        sea_level,
        grnd_level
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    'temp': temp,
    'feels_like': feels_like,
    'temp_min': temp_min,
    'temp_max': temp_max,
    'pressure': pressure,
    'humidity': humidity,
    'sea_level': sea_level,
    'grnd_level': grnd_level
  };
}

class WindData {
  double? speed;
  double? deg;
  double? gust;

  WindData(this.speed, this.deg, this.gust);

  factory WindData.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    double? speed;
    double? deg;
    double? gust;

    if (json['speed'] != null) {
      speed = json['speed'].toDouble();
    }
    if (json['deg'] != null) {
      deg = json['deg'].toDouble();
    }
    if (json['gust'] != null) {
      gust = json['gust'].toDouble();
    }

    // Use parsed values to return an instance
    return WindData(
        speed,
        deg,
        gust
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    'speed': speed,
    'deg': deg,
    'gust': gust
  };
}

class Cloud {
  double? all;

  Cloud(this.all);

  factory Cloud.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    double? all;

    if (json['all'] != null) {
      all = json['all'].toDouble();
    }

    // Use parsed values to return an instance
    return Cloud(
        all
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    'all': all
  };
}

class RainData {
  double? oneHr;
  double? threeHr;

  RainData(this.oneHr, this.threeHr);

  factory RainData.fromJson(Map<String, dynamic> json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    double? oneHr;
    double? threeHr;

    if (json['1h'] != null) {
      oneHr = json['1h']?.toDouble();
    }
    if (json['3h'] != null) {
      threeHr = json['3h']?.toDouble();
    }

    // Use parsed values to return an instance
    return RainData(
        oneHr,
        threeHr
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    '1h': oneHr,
    '3h': threeHr
  };
}

class SnowData {
  double? oneHr;
  double? threeHr;

  SnowData(this.oneHr, this.threeHr);

  factory SnowData.fromJson(Map<String, dynamic> json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    double? oneHr;
    double? threeHr;

    if (json['1h'] != null) {
      oneHr = json['1h'].toDouble();
    }
    if (json['3h'] != null) {
      threeHr = json['3h'].toDouble();
    }

    // Use and parsed values to return an instance
    return SnowData(
        oneHr,
        threeHr
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    '1h': oneHr,
    '3h': threeHr
  };
}


/// OWMCurrentWeather specific classes ///

class Coordinates {
  double lat;
  double lon;

  Coordinates(this.lat, this.lon);

  factory Coordinates.fromJson(dynamic json) {
    // Return values parsed directly from JSON in an instance
    return Coordinates(
        json['lat'].toDouble(),
        json['lon'].toDouble()
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    'lat': lat,
    'lon': lon
  };
}

class SystemData {
  int? type;
  int? id;
  String? message;
  String? country;
  int? sunrise;
  int? sunset;

  SystemData(this.type, this.id, this.message, this.country, this.sunrise, this.sunset);

  factory SystemData.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    int? type;
    int? id;
    String? message;
    String? country;
    int? sunrise;
    int? sunset;

    if (json['type'] != null) {
      type = json['type'].toInt();
    }
    if (json['id'] != null) {
      id = json['id'].toInt();
    }
    if (json['message'] != null) {
      message = json['message'].toString();
    }
    if (json['country'] != null) {
      country = json['country'].toString();
    }
    if (json['sunrise'] != null) {
      sunrise = json['sunrise'].toInt();
    }
    if (json['sunset'] != null) {
      sunset = json['sunset'].toInt();
    }

    // Use parsed values to return an instance
    return SystemData(
        type,
        id,
        message,
        country,
        sunrise,
        sunset
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    'type': type,
    'id': id,
    'message': message,
    'country': country,
    'sunrise': sunrise,
    'sunset': sunset
  };
}


/// OWMForecastWeather specific classes ///

class CityData {
  int? id;
  String? name;
  Coordinates coord;
  String? country;
  int? population;
  int? timezone;
  int? sunrise;
  int? sunset;

  CityData(this.id, this.name, this.coord, this.country, this.population, this.timezone, this.sunrise, this.sunset);

  factory CityData.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    int? id;
    String? name;
    String? country;
    int? population;
    int? timezone;
    int? sunrise;
    int? sunset;

    if (json['id'] != null) {
      id = json['id'].toInt();
    }
    if (json['name'] != null) {
      name = json['name'].toString();
    }
    if (json['country'] != null) {
      country = json['country'].toString();
    }
    if (json['population'] != null) {
      population = json['population'].toInt();
    }
    if (json['timezone'] != null) {
      timezone = json['timezone'].toInt();
    }
    if (json['sunrise'] != null) {
      sunrise = json['sunrise'].toInt();
    }
    if (json['sunset'] != null) {
      sunset = json['sunset'].toInt();
    }

    // Use parsed values to return an instance
    return CityData(
        id,
        name,
        Coordinates.fromJson(json['coord']),
        country,
        population,
        timezone,
        sunrise,
        sunset
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    'id': id,
    'name': name,
    'coord': coord.toJson(),
    'country': country,
    'population': population,
    'timezone': timezone,
    'sunrise': sunrise,
    'sunset': sunset
  };
}

class ForecastData {
  int dt;
  Temperature main;
  List<WeatherType>? weather;
  Cloud? clouds;
  WindData? wind;
  int? visibility;
  double? pop;
  RainData? rain;
  SnowData? snow;
  SysTime? sys;
  String? dt_txt;

  ForecastData(this.dt, this.main, this.weather, this.clouds, this.wind,
      this.visibility, this.pop, this.rain, this.snow, this.sys, this.dt_txt);

  //https://www.bezkoder.com/dart-flutter-parse-json-string-array-to-object-list/
  factory ForecastData.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    List<WeatherType>? weather;
    Cloud? clouds;
    WindData? wind;
    int? visibility;
    double? pop;
    RainData? rain;
    SnowData? snow;
    SysTime? sys;
    String? dt_txt;

    if (json['weather'] != null) {
      var weatherObjsJson = json['weather'] as List;
      weather = weatherObjsJson
          .map((weatherJson) => WeatherType.fromJson(weatherJson))
          .toList();
    }
    if (json['clouds'] != null) {
      clouds = Cloud.fromJson(json['clouds']);
    }
    if (json['wind'] != null) {
      wind = WindData.fromJson(json['wind']);
    }
    if (json['visibility'] != null) {
      visibility = json['visibility'].toInt();
    }
    if (json['pop'] != null) {
      pop = json['pop'].toDouble();
    }
    if (json['rain'] != null) {
      rain = RainData.fromJson(json['rain']);
    }
    if (json['snow'] != null) {
      snow = SnowData.fromJson(json['snow']);
    }
    if (json['sys'] != null) {
      sys = SysTime.fromJson(json['sys']);
    }
    if (json['dt_txt'] != null) {
      dt_txt = json['dt_txt'].toString();
    }

    // Use JSON values and parsed values to return an instance
    return ForecastData(
        json['dt'].toInt(),
        Temperature.fromJson(json['main']),
        weather,
        clouds,
        wind,
        visibility,
        pop,
        rain,
        snow,
        sys,
        dt_txt
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  // https://www.bezkoder.com/dart-flutter-convert-object-to-json-string/
  Map toJson() {
    List<Map>? weather;
    if (this.weather != null) {
      weather = this.weather!.map((i) => i.toJson()).toList();
    }
    Map? clouds;
    if (this.clouds != null) {
      clouds = this.clouds!.toJson();
    }
    Map? wind;
    if (this.wind != null) {
      wind = this.wind!.toJson();
    }
    Map? rain;
    if (this.rain != null) {
      rain = this.rain!.toJson();
    }
    Map? snow;
    if (this.snow != null) {
      snow = this.snow!.toJson();
    }
    Map? sys;
    if (this.sys != null) {
      sys = this.sys!.toJson();
    }
    return {
      'dt': dt,
      'main': main.toJson(),
      'weather': weather,
      'clouds': clouds,
      'wind': wind,
      'visibility': visibility,
      'pop': pop,
      'rain': rain,
      'snow': snow,
      'sys': sys,
      'dt_txt': dt_txt
    };
  }
}

class SysTime {
  // Stands for 'part of day' ('n'=night, 'd'=day)
  String? pod;

  SysTime(this.pod);

  factory SysTime.fromJson(dynamic json) {
    // Each of the following types are not required, so check if
    // they are not null in the JSON before parsing them
    String? pod;

    if (json['pod'] != null) {
      pod = json['pod'].toString();
    }

    // Use parsed values to return an instance
    return SysTime(
        pod
    );
  }

  // Defines how fields are mapped in this object's JSON representation
  Map toJson() => {
    'pod': pod
  };
}