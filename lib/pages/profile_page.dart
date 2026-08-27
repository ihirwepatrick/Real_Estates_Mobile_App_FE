import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/auth_bottom_sheet.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.brand50,
                  child: Text(
                    (auth.user?.fullName ?? 'G')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isLoggedIn
                            ? auth.user!.fullName
                            : 'Browsing as guest',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.isLoggedIn
                            ? auth.user!.email
                            : 'Sign in to list your property',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!auth.isLoggedIn) ...[
            _tile(
              icon: Icons.login,
              title: 'Owner login',
              subtitle: 'Access your listings',
              onTap: () => showAuthRequiredSheet(
                context,
                title: 'Welcome back',
                message:
                    'Sign in to manage listings, or create an owner account if you’re new.',
              ),
            ),
            _tile(
              icon: Icons.person_add_alt_1,
              title: 'Create owner account',
              subtitle: 'Register to submit properties',
              onTap: () => context.push('/register'),
            ),
          ] else ...[
            _tile(
              icon: Icons.add_home_work_outlined,
              title: 'Register your place',
              subtitle: 'Submit for admin review',
              onTap: () => context.push('/submit-listing'),
            ),
            _tile(
              icon: Icons.home_work_outlined,
              title: 'My listings',
              subtitle: 'Pending, approved, rejected',
              onTap: () => context.push('/my-listings'),
            ),
            _tile(
              icon: Icons.logout,
              title: 'Log out',
              subtitle: auth.user?.email ?? '',
              onTap: () async {
                await auth.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out')),
                  );
                }
              },
            ),
          ],
          if (!auth.isLoggedIn)
            _tile(
              icon: Icons.add_home_work_outlined,
              title: 'Register your place',
              subtitle: 'Requires an owner account',
              onTap: () => requireAuthThen(
                context,
                route: '/submit-listing',
                title: 'List your property',
                message:
                    'Owners sign in once, submit details and photos, then we review before publishing.',
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Anyone can browse estates. Only property owners need an account to submit listings for admin approval.',
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: const Color(0xFFF8F9FB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.stroke),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.brand50,
          child: Icon(icon, color: AppColors.brand600),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
