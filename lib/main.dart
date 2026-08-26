import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'router/app_router.dart';
import 'services/api_client.dart';
import 'services/auth_repository.dart';
import 'services/favorites_service.dart';
import 'services/listings_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiClient();
  final authRepo = AuthRepository(api);
  final listingsRepo = ListingsRepository(api);
  final favorites = FavoritesService();

  final authProvider = AuthProvider(authRepo);
  final listingsProvider = ListingsProvider(listingsRepo, favorites);

  await Future.wait([
    authProvider.bootstrap(),
    listingsProvider.bootstrap(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: listingsProvider),
        Provider.value(value: api),
      ],
      child: EasyHomesApp(router: createRouter()),
    ),
  );
}

class EasyHomesApp extends StatelessWidget {
  const EasyHomesApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Easy Homes',
      theme: AppTheme.light().copyWith(
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
