import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/location.dart';
import '../models/property.dart';
import '../services/favorites_service.dart';
import '../services/listings_repository.dart';

class ListingsProvider extends ChangeNotifier {
  ListingsProvider(this._repo, this._favorites);

  final ListingsRepository _repo;
  final FavoritesService _favorites;

  List<Property> _listings = [];
  List<Location> _locations = [];
  Set<String> _favoriteIds = {};
  bool _loading = false;
  String? _error;

  List<Property> get listings => _listings;
  List<Location> get locations => _locations;
  Set<String> get favoriteIds => _favoriteIds;
  bool get loading => _loading;
  String? get error => _error;

  List<Property> get favoriteListings =>
      _listings.where((p) => _favoriteIds.contains(p.id)).toList();

  Future<void> bootstrap() async {
    _favoriteIds = await _favorites.getIds();
    await Future.wait([loadLocations(), loadListings()]);
  }

  Future<void> loadLocations() async {
    try {
      _locations = await _repo.fetchLocations();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadListings({
    String? q,
    String? propertyType,
    String? listingType,
    String? locationId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _repo.fetchListings(
        q: q,
        propertyType: propertyType,
        listingType: listingType,
        locationId: locationId,
      );
      _listings = raw
          .map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)))
          .toList();
    } catch (e) {
      _error = _friendly(e);
    }
    _loading = false;
    notifyListeners();
  }

  Future<Property> getListing(String id) async {
    final p = await _repo.fetchListing(id);
    return p.copyWith(isFavorite: _favoriteIds.contains(p.id));
  }

  Future<List<Property>> myListings() => _repo.fetchMyListings();

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
    required List<String> photoPaths,
  }) async {
    final photos = <MultipartFile>[];
    for (final path in photoPaths) {
      final name = path.split(RegExp(r'[\\/]')).last;
      photos.add(await MultipartFile.fromFile(path, filename: name));
    }

    return _repo.createListing(
      title: title,
      description: description,
      propertyType: propertyType,
      listingType: listingType,
      price: price,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      address: address,
      locationId: locationId,
      photos: photos,
    );
  }

  Future<void> toggleFavorite(String id) async {
    await _favorites.toggle(id);
    _favoriteIds = await _favorites.getIds();
    _listings = _listings
        .map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)))
        .toList();
    notifyListeners();
  }

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('connection')) {
      return 'Cannot reach the server. Check API_BASE_URL and that the backend is running.';
    }
    return s;
  }
}
