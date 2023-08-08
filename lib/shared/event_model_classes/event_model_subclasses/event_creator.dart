class Creator {
  Creator({
    this.displayName,
    this.email,
    this.id,
    this.self,
  });
  Creator.details(this.displayName, this.email, this.id, this.self);

  String? displayName;
  String? email;
  String? id;
  bool? self;

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    email: json["email"],
    self: json["self"],
    displayName : json["displayName"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "self": self,
    "displayName": displayName,
    "id": id,
  };
}