import 'package:flutter/material.dart';
import '../models/location.dart';

class LocationCard extends StatelessWidget {
  final Location location;
  final VoidCallback? onTap;

  const LocationCard({
    super.key,
    required this.location,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                image: location.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(location.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: location.imageUrl.isEmpty
                  ? const Icon(Icons.location_city,
                      size: 30, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              location.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
