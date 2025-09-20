class Property {
  final String id;
  final String title;
  final String imageUrl;
  final String type;
  final double rating;
  final String location;
  final String price;
  final bool isFavorite;

  Property({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.type,
    required this.rating,
    required this.location,
    required this.price,
    this.isFavorite = false,
  });
}
