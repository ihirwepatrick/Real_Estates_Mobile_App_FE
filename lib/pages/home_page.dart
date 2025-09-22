import 'package:flutter/material.dart';
import '../components/property_card.dart';
import '../components/location_card.dart';
import '../components/category_button.dart';
import '../components/search_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../models/property.dart';
import '../models/location.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  String _selectedCategory = "All";
  final List<String> _categories = ["All", "House", "Apartment", "Villa"];

  // Sample data
  final List<Property> _featuredProperties = [
    Property(
      id: "1",
      title: "Sky Dandelions Apartment",
      imageUrl:
          "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400",
      type: "Apartment",
      rating: 4.9,
      location: "Jakarta, Indonesia",
      price: "\$290/month",
      isFavorite: true,
    ),
    Property(
      id: "2",
      title: "Modern City Apartment",
      imageUrl:
          "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400",
      type: "Apartment",
      rating: 4.8,
      location: "Jakarta, Indonesia",
      price: "\$320/month",
      isFavorite: false,
    ),
    Property(
      id: "3",
      title: "Wings Tower",
      imageUrl:
          "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400",
      type: "House",
      rating: 4.9,
      location: "Jakarta, Indonesia",
      price: "\$220/month",
      isFavorite: true,
    ),
    Property(
      id: "4",
      title: "Luxury Villa",
      imageUrl:
          "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=400",
      type: "Villa",
      rating: 4.7,
      location: "Jakarta, Indonesia",
      price: "\$450/month",
      isFavorite: false,
    ),
  ];

  final List<Location> _topLocations = [
    Location(
      id: "1",
      name: "Nyamata",
      imageUrl:
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=100",
    ),
    Location(
      id: "2",
      name: "Muhanga",
      imageUrl:
          "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=100",
    ),
    Location(
      id: "3",
      name: "Rubavu",
      imageUrl:
          "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=100",
    ),
    Location(
      id: "4",
      name: "Nyarutarama",
      imageUrl:
          "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=100",
    ),
    Location(
      id: "5",
      name: "Kabuye",
      imageUrl:
          "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=100",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildUserGreeting(),
                _buildSearchSection(),
                _buildCategoriesSection(),
                _buildFeaturedEstatesSection(),
                _buildTopLocationsSection(),
                _buildAroundEstatesSection(),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.home,
              color: Colors.white,
              size: 24,
            ),
          ),
          Row(
            children: [
              _buildHeaderIcon(LucideIcons.user),
              const SizedBox(width: 12),
              _buildHeaderIcon(LucideIcons.bell),
              const SizedBox(width: 12),
              _buildHeaderIcon(LucideIcons.messageCircle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E7)),
        color: const Color(0xFFF8F9FB),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey[600], size: 20),
    );
  }

  Widget _buildUserGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[200],
            backgroundImage: const NetworkImage(
              "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100",
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good Morning 👋",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "Olivia Irwin",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD9D6FE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.checkCheck,
                    size: 12, color: const Color(0xFF7F56D9)),
                const SizedBox(width: 4),
                Text(
                  "Free Plan",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7F56D9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Upgrade →",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: CustomSearchBar(
        hintText: "Search",
        onFilterTap: () {
          // Handle filter tap
        },
        onChanged: (value) {
          // Handle search
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            return CategoryButton(
              label: category,
              isSelected: _selectedCategory == category,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFeaturedEstatesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Featured Estates",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Text(
                "view all",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredProperties.length,
              itemBuilder: (context, index) {
                return PropertyCard(
                  property: _featuredProperties[index],
                  onTap: () {
                    // Handle property tap
                  },
                  onFavoriteTap: () {
                    setState(() {
                      _featuredProperties[index] = Property(
                        id: _featuredProperties[index].id,
                        title: _featuredProperties[index].title,
                        imageUrl: _featuredProperties[index].imageUrl,
                        type: _featuredProperties[index].type,
                        rating: _featuredProperties[index].rating,
                        location: _featuredProperties[index].location,
                        price: _featuredProperties[index].price,
                        isFavorite: !_featuredProperties[index].isFavorite,
                      );
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopLocationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Top Locations",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Explore",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _topLocations.length,
              itemBuilder: (context, index) {
                return LocationCard(
                  location: _topLocations[index],
                  onTap: () {
                    // Handle location tap
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAroundEstatesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Estates Around",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    "Jakarta, Indonesia",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredProperties.length,
              itemBuilder: (context, index) {
                return PropertyCard(
                  property: _featuredProperties[index],
                  onTap: () {
                    // Handle property tap
                  },
                  onFavoriteTap: () {
                    setState(() {
                      _featuredProperties[index] = Property(
                        id: _featuredProperties[index].id,
                        title: _featuredProperties[index].title,
                        imageUrl: _featuredProperties[index].imageUrl,
                        type: _featuredProperties[index].type,
                        rating: _featuredProperties[index].rating,
                        location: _featuredProperties[index].location,
                        price: _featuredProperties[index].price,
                        isFavorite: !_featuredProperties[index].isFavorite,
                      );
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
