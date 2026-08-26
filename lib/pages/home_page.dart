import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../components/category_button.dart';
import '../components/location_card.dart';
import '../components/property_card.dart';
import '../components/search_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'House', 'Apartment', 'Villa'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().loadListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();
    final auth = context.watch<AuthProvider>();
    final filtered = _selectedCategory == 'All'
        ? listings.listings
        : listings.listings
            .where((p) =>
                p.propertyType.toLowerCase() ==
                _selectedCategory.toLowerCase())
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.brand500,
            onRefresh: () => listings.loadListings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildUserGreeting(auth),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: CustomSearchBar(
                      hintText: 'Search in Rwanda',
                      onFilterTap: () => context.go('/search'),
                      onChanged: (_) {},
                      onSubmitted: (value) {
                        context.go('/search?q=${Uri.encodeComponent(value)}');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          return CategoryButton(
                            label: category,
                            isSelected: _selectedCategory == category,
                            onTap: () {
                              setState(() => _selectedCategory = category);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (listings.error != null)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        listings.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (listings.loading && filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.brand500,
                        ),
                      ),
                    ),
                  _section(
                    title: 'Featured Estates',
                    action: 'view all',
                    onAction: () => context.go('/search'),
                    child: filtered.isEmpty && !listings.loading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No approved listings yet. Check back soon.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final p = filtered[index];
                                return PropertyCard(
                                  property: p,
                                  onTap: () => context.push('/listing/${p.id}'),
                                  onFavoriteTap: () =>
                                      listings.toggleFavorite(p.id),
                                );
                              },
                            ),
                          ),
                  ),
                  _section(
                    title: 'Top Locations',
                    action: 'Explore',
                    onAction: () => context.go('/search'),
                    child: SizedBox(
                      height: 96,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: listings.locations.length,
                        itemBuilder: (context, index) {
                          final loc = listings.locations[index];
                          return LocationCard(
                            location: loc,
                            onTap: () => context.go(
                              '/search?locationId=${Uri.encodeComponent(loc.id)}',
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _section(
                    title: 'Estates Around',
                    trailing: Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Kigali, Rwanda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return PropertyCard(
                            property: p,
                            onTap: () => context.push('/listing/${p.id}'),
                            onFavoriteTap: () =>
                                listings.toggleFavorite(p.id),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brand500,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 24),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: _headerIcon(LucideIcons.user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.stroke),
        color: const Color(0xFFF8F9FB),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey[600], size: 20),
    );
  }

  Widget _buildUserGreeting(AuthProvider auth) {
    final name = auth.user?.fullName ?? 'Guest';
    final hour = DateTime.now().hour;
    final greet = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.brand50,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'G',
              style: const TextStyle(
                color: AppColors.brand700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greet 👋',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brand50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brand100),
            ),
            child: const Text(
              'Rwanda',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.brand700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    String? action,
    VoidCallback? onAction,
    Widget? trailing,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              if (trailing != null)
                trailing
              else if (action != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    action,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brand600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
