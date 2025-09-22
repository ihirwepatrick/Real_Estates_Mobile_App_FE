import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    super.key,
    this.hintText = "Search",
    this.onFilterTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon:
              const Icon(Icons.search, size: 20, color: AppColors.gray400),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          // Suffix filter button inside the input decoration so the whole field
          // uses the theme's InputDecoration (border, fill, radius, etc)
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(17),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.brand500,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 18),
              ),
            ),
          ),
          suffixIconConstraints:
              const BoxConstraints(minHeight: 34, minWidth: 34),
          hintStyle: const TextStyle(color: AppColors.gray400),
        ),
      ),
    );
  }
}
