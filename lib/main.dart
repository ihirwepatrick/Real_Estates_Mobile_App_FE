import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pages/onboarding_page.dart';
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
  final onboardingDone = await OnboardingPreferences.isDone();

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
      child: EasyHomesRoot(showOnboarding: !onboardingDone),
    ),
  );
}

class EasyHomesRoot extends StatefulWidget {
  const EasyHomesRoot({super.key, required this.showOnboarding});

  final bool showOnboarding;

  @override
  State<EasyHomesRoot> createState() => _EasyHomesRootState();
}

class _EasyHomesRootState extends State<EasyHomesRoot> {
  late bool _showOnboarding = widget.showOnboarding;
  late final GoRouter _router = createRouter();
  String? _pendingRoute;

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return MaterialApp(
        title: 'Easy Homes',
        theme: AppTheme.light().copyWith(
          textTheme: GoogleFonts.montserratTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
        home: OnboardingPage(
          onFinished: ({required bool openRegister}) {
            setState(() {
              _showOnboarding = false;
              _pendingRoute = openRegister ? '/register' : null;
            });
          },
        ),
      );
    }

    return MaterialApp.router(
      title: 'Easy Homes',
      theme: AppTheme.light().copyWith(
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (_pendingRoute != null) {
          final route = _pendingRoute!;
          _pendingRoute = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _router.push(route);
          });
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
