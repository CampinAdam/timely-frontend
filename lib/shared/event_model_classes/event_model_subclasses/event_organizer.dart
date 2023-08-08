class Organizer {
  Organizer({
    this.email,
    this.displayName,
    this.self,
  });

  Organizer.details(this.email, this.displayName, this.self);

  String? email;
  String? displayName;
  bool? self;

  factory Organizer.fromJson(Map<String, dynamic> json) => Organizer(
    email: json["email"],
    displayName: json["displayName"] == null ? null : json["displayName"],
    self: json["self"] == null ? null : json["self"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "displayName": displayName == null ? null : displayName,
    "self": self == null ? null : self,
  };
}