class End {
  End({
    this.dateTime,
    this.timeZone,
    this.date,
  });

  End.details(this.dateTime, this.timeZone, this.date);

  DateTime? dateTime;
  String? timeZone;
  DateTime? date;

  factory End.fromJson(Map<String, dynamic> json) => End(
    dateTime: json["dateTime"] == null ? null : DateTime.parse(json["dateTime"]),
    timeZone: json["timeZone"] == null ? null : json["timeZone"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "dateTime": dateTime == null ? null : dateTime?.toIso8601String(),
    "timeZone": timeZone == null ? null : timeZone,
    "date": date == null ? null : "${date?.year.toString().padLeft(4, '0')}-${date?.month.toString().padLeft(2, '0')}-${date?.day.toString().padLeft(2, '0')}",
  };
}