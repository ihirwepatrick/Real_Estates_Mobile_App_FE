import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../pages/favorites_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/home_page.dart';
import '../pages/listing_detail_page.dart';
import '../pages/login_page.dart';
import '../pages/main_shell.dart';
import '../pages/my_listings_page.dart';
import '../pages/profile_page.dart';
import '../pages/register_page.dart';
import '../pages/reset_password_page.dart';
import '../pages/search_page.dart';
import '../pages/submit_listing_page.dart';
import '../pages/verify_otp_page.dart';
import '../providers/auth_provider.dart';

GoRouter createRouter({String initialLocation = '/home'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => SearchPage(
                  initialQuery: state.uri.queryParameters['q'],
                  initialLocationId: state.uri.queryParameters['locationId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) => ListingDetailPage(
          listingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ResetPasswordPage(email: email);
        },
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final type = state.uri.queryParameters['type'] ?? 'signup';
          return VerifyOtpPage(email: email, type: type);
        },
      ),
      GoRoute(
        path: '/submit-listing',
        // Auth gate handled in Profile via bottom sheet; keep soft redirect
        redirect: (context, state) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.isLoggedIn) return '/profile';
          return null;
        },
        builder: (context, state) => const SubmitListingPage(),
      ),
      GoRoute(
        path: '/my-listings',
        redirect: (context, state) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.isLoggedIn) return '/profile';
          return null;
        },
        builder: (context, state) => const MyListingsPage(),
      ),
    ],
  );
}
