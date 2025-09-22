import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  // Radial gradient from tokens
  static const RadialGradient brandRadial = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      Color(0xFF0A77FF), // #0a77ff
      Color(0xFF78A1D3), // #78a1d3
    ],
    stops: [0.05, 0.98],
  );

  // Convenience Linear gradient using brand ramp
  static const LinearGradient brandLinear = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.brand300,
      AppColors.brand500,
      AppColors.brand700,
    ],
  );
}
