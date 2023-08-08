import 'event_override.dart';

class Reminders {
  Reminders({
    this.useDefault,
    this.overrides,
  });

  bool? useDefault;
  List<Override>? overrides;

  Reminders.details(this.useDefault, this.overrides);
  Reminders.someDetails(this.useDefault);

  factory Reminders.fromJson(Map<String, dynamic> json) => Reminders(
    useDefault: json["useDefault"],
    overrides: json["overrides"] == null ? null : List<Override>.from(json["overrides"].map((x) => Override.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "useDefault": useDefault,
    "overrides": overrides == null ? null : List<dynamic>.from(overrides?.map((x) => x.toJson()) ?? <dynamic>[]),
  };
}
