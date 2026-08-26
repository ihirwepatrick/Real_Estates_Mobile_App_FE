class Location {
  final String id;
  final String name;
  final String imageUrl;

  const Location({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}
