import 'package:dio/dio.dart';
import '../models/location.dart';
import '../models/property.dart';
import 'api_client.dart';

class ListingsRepository {
  ListingsRepository(this._api);

  final ApiClient _api;

  Future<List<Location>> fetchLocations() async {
    final res = await _api.dio.get('/api/locations');
    final list = res.data['locations'] as List<dynamic>? ?? [];
    return list
        .map((e) => Location.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Property>> fetchListings({
    String? q,
    String? propertyType,
    String? listingType,
    String? locationId,
    num? minPrice,
    num? maxPrice,
  }) async {
    final res = await _api.dio.get(
      '/api/listings',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (propertyType != null &&
            propertyType.isNotEmpty &&
            propertyType.toLowerCase() != 'all')
          'property_type': propertyType.toLowerCase(),
        if (listingType != null && listingType.isNotEmpty)
          'listing_type': listingType.toLowerCase(),
        if (locationId != null && locationId.isNotEmpty)
          'location_id': locationId,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
      },
    );
    final list = res.data['listings'] as List<dynamic>? ?? [];
    return list
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Property> fetchListing(String id) async {
    final res = await _api.dio.get('/api/listings/$id');
    return Property.fromJson(res.data['listing'] as Map<String, dynamic>);
  }

  Future<List<Property>> fetchMyListings() async {
    final res = await _api.dio.get('/api/my/listings');
    final list = res.data['listings'] as List<dynamic>? ?? [];
    return list
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Property> createListing({
    required String title,
    required String description,
    required String propertyType,
    required String listingType,
    required num price,
    required int bedrooms,
    required int bathrooms,
    required String address,
    String? locationId,
    List<MultipartFile>? photos,
  }) async {
    final form = FormData();
    form.fields.addAll([
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('propertyType', propertyType),
      MapEntry('listingType', listingType),
      MapEntry('price', price.toString()),
      MapEntry('bedrooms', bedrooms.toString()),
      MapEntry('bathrooms', bathrooms.toString()),
      MapEntry('address', address),
      if (locationId != null) MapEntry('locationId', locationId),
    ]);
    if (photos != null) {
      for (final photo in photos) {
        form.files.add(MapEntry('photos', photo));
      }
    }

    final res = await _api.dio.post('/api/listings', data: form);
    return Property.fromJson(res.data['listing'] as Map<String, dynamic>);
  }
}
