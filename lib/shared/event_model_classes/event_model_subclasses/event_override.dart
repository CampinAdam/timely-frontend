class Override {
  Override({
    this.method,
    this.minutes,
  });

  Override.details(this.method, this.minutes);

  String? method;
  int? minutes;

  factory Override.fromJson(Map<String, dynamic> json) => Override(
    method: json["method"],
    minutes: json["minutes"],
  );

  Map<String, dynamic> toJson() => {
    "method": method,
    "minutes": minutes,
  };
}