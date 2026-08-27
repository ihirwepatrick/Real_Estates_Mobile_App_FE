import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

/// Shows a sliding bottom sheet prompting the user to sign in / register.
/// Returns `true` if the user ends up authenticated.
Future<bool> showAuthRequiredSheet(
  BuildContext context, {
  String title = 'Sign in to continue',
  String message =
      'Create an owner account or sign in to list your property and manage submissions.',
}) async {
  final auth = context.read<AuthProvider>();
  if (auth.isLoggedIn) return true;

  final action = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AuthBottomSheet(title: title, message: message),
  );

  if (!context.mounted) return false;

  if (action == 'login') {
    await context.push('/login');
  } else if (action == 'register') {
    await context.push('/register');
  }

  return context.mounted && context.read<AuthProvider>().isLoggedIn;
}

class _AuthBottomSheet extends StatelessWidget {
  const _AuthBottomSheet({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.stroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.brand50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.brand600,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.grey,
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign in'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop('register'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brand700,
                  side: const BorderSide(color: AppColors.brand200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Create owner account'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('dismiss'),
                child: const Text(
                  'Continue browsing',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper for gated navigation: show sheet if guest, else push [route].
Future<void> requireAuthThen(
  BuildContext context, {
  required String route,
  String title = 'Sign in to continue',
  String? message,
}) async {
  final auth = context.read<AuthProvider>();
  if (auth.isLoggedIn) {
    context.push(route);
    return;
  }
  final ok = await showAuthRequiredSheet(
    context,
    title: title,
    message: message ??
        'You need an owner account for this. Sign in or create one — browsing stays free.',
  );
  if (context.mounted && ok) {
    context.push(route);
  }
}
