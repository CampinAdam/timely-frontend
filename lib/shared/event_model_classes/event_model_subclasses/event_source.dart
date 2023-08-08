class Source {
  Source({
    this.url,
    this.title,
  });

  String? url;
  String? title;

  Source.details(this.url, this.title);

  factory Source.fromJson(Map<String, dynamic> json) => Source(
    url: json["url"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "title": title,
  };
}