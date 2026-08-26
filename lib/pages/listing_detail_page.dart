import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property.dart';
import '../providers/listings_provider.dart';
import '../theme/app_colors.dart';

class ListingDetailPage extends StatefulWidget {
  const ListingDetailPage({super.key, required this.listingId});

  final String listingId;

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  Property? _listing;
  bool _loading = true;
  String? _error;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p =
          await context.read<ListingsProvider>().getListing(widget.listingId);
      setState(() {
        _listing = p;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.brand500))
          : _error != null
              ? Center(child: Text(_error!))
              : _listing == null
                  ? const Center(child: Text('Not found'))
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 280,
                          pinned: true,
                          backgroundColor: AppColors.brand500,
                          foregroundColor: Colors.white,
                          actions: [
                            IconButton(
                              icon: Icon(
                                _listing!.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              onPressed: () async {
                                await listings.toggleFavorite(_listing!.id);
                                setState(() {
                                  _listing = _listing!.copyWith(
                                    isFavorite: !_listing!.isFavorite,
                                  );
                                });
                              },
                            ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: PageView.builder(
                              itemCount: _listing!.images.isEmpty
                                  ? 1
                                  : _listing!.images.length,
                              onPageChanged: (i) =>
                                  setState(() => _imageIndex = i),
                              itemBuilder: (context, index) {
                                final url = _listing!.images.isEmpty
                                    ? _listing!.imageUrl
                                    : _listing!.images[index].url;
                                if (url.isEmpty) {
                                  return Container(
                                    color: AppColors.brand50,
                                    child: const Icon(Icons.home,
                                        size: 64, color: AppColors.brand300),
                                  );
                                }
                                return Image.network(url, fit: BoxFit.cover);
                              },
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_listing!.images.length > 1)
                                  Text(
                                    '${_imageIndex + 1}/${_listing!.images.length}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  _listing!.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _listing!.formattedPrice,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brand500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _badge(_listing!.type),
                                    _badge(_listing!.listingType.toUpperCase()),
                                    _badge(
                                        '${_listing!.bedrooms} bed'),
                                    _badge(
                                        '${_listing!.bathrooms} bath'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: AppColors.brand500, size: 20),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        [
                                          if (_listing!.address.isNotEmpty)
                                            _listing!.address,
                                          _listing!.locationLabel,
                                        ].where((e) => e.isNotEmpty).join(' · '),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _listing!.description.isEmpty
                                      ? 'No description provided.'
                                      : _listing!.description,
                                  style: const TextStyle(
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (_listing!.owner != null) ...[
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Listed by',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_listing!.owner!.fullName),
                                  if (_listing!.owner!.phone != null)
                                    Text(
                                      _listing!.owner!.phone!,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                ],
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brand50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.brand700,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
