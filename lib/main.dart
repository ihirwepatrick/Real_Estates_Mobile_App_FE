import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Homes',
      theme: AppTheme.light().copyWith(
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
