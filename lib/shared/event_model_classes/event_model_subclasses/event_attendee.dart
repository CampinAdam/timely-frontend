class Attendee {
  Attendee({
    this.email,
    this.self,
    this.responseStatus,
  });

  Attendee.details(this.email, this.self, this.responseStatus);

  String? email;
  bool? self;
  String? responseStatus;

  factory Attendee.fromJson(Map<String, dynamic> json) => Attendee(
    email: json["email"],
    self: json["self"],
    responseStatus: json["responseStatus"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "self": self,
    "responseStatus": responseStatus,
  };
}
