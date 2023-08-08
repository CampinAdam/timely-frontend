import 'dart:core';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:timely/models/theme_model.dart';

class SettingsProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = true;

  /// This is the default mode of transport that the user will use to arrive at events
  TransportMode _transportMode = TransportMode.driving;

  /// This is the default alarm sound that the user wants
  AlarmSound _sound = AlarmSound.thePurgeAlarm;

  /// This is the default number of minutes that the user wants to be notified before they should leave
  int _getReadyMinutes = 0;

  /// This is the default number of minutes that the user desires to arrive early
  int _arriveEarlyMinutes = 0;

  /// This is the default priority for events
  Priority _priority = Priority.medium;

  /// This is the default color that SmartBulbs will turn to when it is time to leave
  SmartBulbColor _smartBulbColor = SmartBulbColor.blue;
  List<SmartSpeaker> _smartSpeakers = SmartSpeaker.generateDummySmartSpeakers();

  String? _homeAddress = null;

  /// Default constructor just uses default values for the fields
  SettingsProvider();

  static final List<int> getReadyMinutePossibilities =
      List<int>.generate(9, (int index) => index * 5);
  static final List<int> arriveEarlyMinutePossibilities =
      List<int>.generate(9, (int index) => index * 5);

  bool get darkTheme => _darkTheme; //TODO: Remove

  SettingsProvider.fromJson(Map<String, dynamic> json) {
    _darkTheme = json['darkTheme'] ?? false;
    _transportMode = TransportMode.fromString(
        json['transportMode'] ?? 'Driving');
    _sound = AlarmSound.fromString(json['sound'] ?? 'The Purge Alarm');
    _getReadyMinutes = int.parse(json['getReadyMinutes'] ?? '0');
    _arriveEarlyMinutes = int.parse(json['arriveEarlyMinutes'] ?? '0');
    _priority = Priority.fromString(json['priority'] ?? 'Medium');
    _smartBulbColor =
        SmartBulbColor.fromString(json['smartBulb'] ?? 'Blue');
    _homeAddress = json['homeAddress'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'darkTheme': darkTheme,
        'transportMode': transportMode.description,
        'sound': sound.description,
        'getReadyMinutes': getReadyMinutes.toString(),
        'arriveEarlyMinutes': arriveEarlyMinutes.toString(),
        'priority': priority.description,
        'smartBulb': smartBulbColor.description,
        'homeAddress': homeAddress,
      };

  String? get homeAddress=> _homeAddress;

  set homeAddress(String? home) {
    _homeAddress = home;
    notifyListeners();
  }

  set darkTheme(bool value) {
    //TODO: Remove
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }

  TransportMode get transportMode => _transportMode;

  set transportMode(TransportMode value) {
    _transportMode = value;
    notifyListeners();
  }

  List<SmartSpeaker> get smartSpeakers => _smartSpeakers;

  set smartSpeakers(List<SmartSpeaker> value) {
    _smartSpeakers = value;
    notifyListeners();
  }

  SmartBulbColor get smartBulbColor => _smartBulbColor;

  set smartBulbColor(SmartBulbColor value) {
    _smartBulbColor = value;
    notifyListeners();
  }

  Priority get priority => _priority;

  set priority(Priority value) {
    _priority = value;
    notifyListeners();
  }

  int get arriveEarlyMinutes => _arriveEarlyMinutes;

  set arriveEarlyMinutes(int value) {
    _arriveEarlyMinutes = value;
    notifyListeners();
  }

  int get getReadyMinutes => _getReadyMinutes;

  set getReadyMinutes(int value) {
    _getReadyMinutes = value;
    notifyListeners();
  }

  AlarmSound get sound => _sound;

  set sound(AlarmSound value) {
    _sound = value;
    notifyListeners();
  }
}

enum TransportMode {
  driving('Driving'),
  transit('Transit'),
  bicycling('Bicycling'),
  walking('Walking');

  //The description of the TransportMode. Also the value of the json Field
  final String description;

  const TransportMode(this.description);

  Icon get icon {
    switch (this) {
      case TransportMode.driving:
        return const Icon(Icons.directions_car);
      case TransportMode.transit:
        return const Icon(Icons.directions_bus);
      case TransportMode.bicycling:
        return const Icon(Icons.directions_bike);
      case TransportMode.walking:
        return const Icon(Icons.directions_walk);
    }
  }

  factory TransportMode.fromString(String str) {
    for (TransportMode transportMode in TransportMode.values) {
      if (transportMode.description == str) {
        return transportMode;
      }
    }
    throw ArgumentError("There is no matching TransportMode for '$str'.");
  }
}

enum AlarmSound {
  thePurgeAlarm('The Purge Alarm'),
  beepBeep('Beep Beep'),
  alarmClock('Alarm Clock');

  final String description;

  const AlarmSound(this.description);

  Icon get icon {
    switch (this) {
      case AlarmSound.thePurgeAlarm:
        return const Icon(LineAwesome.skull_crossbones_solid);
      case AlarmSound.beepBeep:
        return const Icon(LineAwesome.car_crash_solid);
      case AlarmSound.alarmClock:
        return const Icon(Icons.alarm);
    }
  }

  factory AlarmSound.fromString(String str) {
    for (AlarmSound alarmSound in AlarmSound.values) {
      if (alarmSound.description == str) {
        return alarmSound;
      }
    }
    throw ArgumentError("There is no matching AlarmSound for '$str'.");
  }
}

enum SmartBulbColor {
  red('Red'),
  blue('Blue'),
  green('Green'),
  yellow('Yellow'),
  purple('Purple'),
  orange('Orange');

  final String description;

  const SmartBulbColor(this.description);

  Icon get icon => Icon(
        Icons.lightbulb_outline,
        color: color,
      );

  Color get color {
    switch (this) {
      case SmartBulbColor.red:
        return Colors.red;
      case SmartBulbColor.blue:
        return Colors.blue;
      case SmartBulbColor.green:
        return Colors.green;
      case SmartBulbColor.yellow:
        return Colors.yellow;
      case SmartBulbColor.purple:
        return Colors.purple;
      case SmartBulbColor.orange:
        return Colors.orange;
    }
  }

  Text asText() {
    return Text(description, style: TextStyle(color: color));
  }

  factory SmartBulbColor.fromString(String str) {
    for (SmartBulbColor smartBulbColor in SmartBulbColor.values) {
      if (smartBulbColor.description == str) {
        return smartBulbColor;
      }
    }
    throw ArgumentError("There is no matching SmartBulbColor for '$str'.");
  }
}

enum Priority {
  high('High'),
  medium('Medium'),
  low('Low');

  final String description;

  const Priority(this.description);

  Color get color {
    switch (this) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  Text asText() {
    return Text(description);
  }

  factory Priority.fromString(String str) {
    for (Priority priority in Priority.values) {
      if (priority.description == str) {
        return priority;
      }
    }
    throw ArgumentError("There is no matching SmartBulbColor for '$str'.");
  }
}

class SmartSpeaker {
  late Text name;
  bool enabled;
  Icon icon;

  SmartSpeaker(String name, this.enabled, this.icon) {
    this.name = Text(name);
  }

  static generateDummySmartSpeakers() {
    return <SmartSpeaker>[
      SmartSpeaker('Google Home', false, const Icon(LineAwesome.google)),
      SmartSpeaker('Amazon Echo', false, const Icon(LineAwesome.amazon)),
      SmartSpeaker('Apple HomePod', false, const Icon(LineAwesome.apple)),
    ];
  }
}
