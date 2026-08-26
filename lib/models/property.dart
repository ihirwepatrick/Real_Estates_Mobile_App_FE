import 'location.dart';

class ListingImage {
  final String id;
  final String url;
  final int sortOrder;

  const ListingImage({
    required this.id,
    required this.url,
    this.sortOrder = 0,
  });

  factory ListingImage.fromJson(Map<String, dynamic> json) {
    return ListingImage(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}

class ListingOwner {
  final String id;
  final String fullName;
  final String? phone;

  const ListingOwner({
    required this.id,
    required this.fullName,
    this.phone,
  });

  factory ListingOwner.fromJson(Map<String, dynamic> json) {
    return ListingOwner(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }
}

class Property {
  final String id;
  final String title;
  final String description;
  final String propertyType;
  final String listingType;
  final double price;
  final String currency;
  final int bedrooms;
  final int bathrooms;
  final String address;
  final String? locationId;
  final Location? location;
  final String status;
  final String? rejectionReason;
  final List<ListingImage> images;
  final String imageUrl;
  final ListingOwner? owner;
  final bool isFavorite;
  final double rating;

  const Property({
    required this.id,
    required this.title,
    this.description = '',
    required this.propertyType,
    this.listingType = 'rent',
    required this.price,
    this.currency = 'RWF',
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.address = '',
    this.locationId,
    this.location,
    this.status = 'approved',
    this.rejectionReason,
    this.images = const [],
    this.imageUrl = '',
    this.owner,
    this.isFavorite = false,
    this.rating = 4.8,
  });

  String get type => _capitalize(propertyType);

  String get locationLabel =>
      location?.name ?? (address.isNotEmpty ? address : 'Rwanda');

  String get formattedPrice {
    final n = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    final suffix = listingType == 'rent' ? '/month' : '';
    return '$n $currency$suffix';
  }

  /// Legacy UI field used by PropertyCard.
  String get priceDisplay => formattedPrice;

  Property copyWith({
    bool? isFavorite,
    String? status,
    String? rejectionReason,
  }) {
    return Property(
      id: id,
      title: title,
      description: description,
      propertyType: propertyType,
      listingType: listingType,
      price: price,
      currency: currency,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      address: address,
      locationId: locationId,
      location: location,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      images: images,
      imageUrl: imageUrl,
      owner: owner,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating,
    );
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    final images = imagesJson
        .map((e) => ListingImage.fromJson(e as Map<String, dynamic>))
        .toList();
    final loc = json['location'];
    final ownerJson = json['owner'];

    return Property(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? 'house',
      listingType: json['listingType'] as String? ?? 'rent',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'RWF',
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      address: json['address'] as String? ?? '',
      locationId: json['locationId'] as String?,
      location: loc is Map<String, dynamic> ? Location.fromJson(loc) : null,
      status: json['status'] as String? ?? 'approved',
      rejectionReason: json['rejectionReason'] as String?,
      images: images,
      imageUrl: (json['imageUrl'] as String?)?.isNotEmpty == true
          ? json['imageUrl'] as String
          : (images.isNotEmpty ? images.first.url : ''),
      owner: ownerJson is Map<String, dynamic>
          ? ListingOwner.fromJson(ownerJson)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
