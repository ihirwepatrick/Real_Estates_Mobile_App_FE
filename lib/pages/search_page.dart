import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/category_button.dart';
import '../components/property_card.dart';
import '../components/search_bar.dart';
import '../providers/listings_provider.dart';
import '../theme/app_colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.initialQuery,
    this.initialLocationId,
  });

  final String? initialQuery;
  final String? initialLocationId;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _query;
  String _propertyType = 'All';
  String? _listingType;
  String? _locationId;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery ?? '');
    _locationId = widget.initialLocationId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() {
    return context.read<ListingsProvider>().loadListings(
          q: _query.text.trim(),
          propertyType: _propertyType,
          listingType: _listingType,
          locationId: _locationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: CustomSearchBar(
              controller: _query,
              hintText: 'Search title, area…',
              onSubmitted: (_) => _search(),
              onFilterTap: _search,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final c in ['All', 'House', 'Apartment', 'Villa'])
                  CategoryButton(
                    label: c,
                    isSelected: _propertyType == c,
                    onTap: () {
                      setState(() => _propertyType = c);
                      _search();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _chip('Rent', _listingType == 'rent', () {
                  setState(() {
                    _listingType = _listingType == 'rent' ? null : 'rent';
                  });
                  _search();
                }),
                const SizedBox(width: 8),
                _chip('Sale', _listingType == 'sale', () {
                  setState(() {
                    _listingType = _listingType == 'sale' ? null : 'sale';
                  });
                  _search();
                }),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _locationId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      hintText: 'Location',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All locations'),
                      ),
                      ...listings.locations.map(
                        (l) => DropdownMenuItem<String?>(
                          value: l.id,
                          child: Text(l.name),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _locationId = v);
                      _search();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: listings.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.brand500),
                  )
                : listings.listings.isEmpty
                    ? const Center(
                        child: Text(
                          'No listings match your filters.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 4, 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: listings.listings.length,
                        itemBuilder: (context, index) {
                          final p = listings.listings[index];
                          return PropertyCard(
                            property: p,
                            width: double.infinity,
                            onTap: () => context.push('/listing/${p.id}'),
                            onFavoriteTap: () =>
                                listings.toggleFavorite(p.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand500 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.brand500 : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
