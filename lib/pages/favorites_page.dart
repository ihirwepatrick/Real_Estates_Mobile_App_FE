import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/property_card.dart';
import '../providers/listings_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();
    final favs = listings.favoriteListings;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: favs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No favorites yet.\nTap the heart on a listing to save it on this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.4),
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 4, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                mainAxisSpacing: 12,
              ),
              itemCount: favs.length,
              itemBuilder: (context, index) {
                final p = favs[index];
                return PropertyCard(
                  property: p,
                  width: double.infinity,
                  onTap: () => context.push('/listing/${p.id}'),
                  onFavoriteTap: () => listings.toggleFavorite(p.id),
                );
              },
            ),
    );
  }
}
