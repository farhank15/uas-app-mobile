import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uas_flutter_app/utils/guard_util.dart';

class CustomSidebar extends StatelessWidget {
  final String? email;
  final String? name;
  final VoidCallback onClose;

  const CustomSidebar({
    super.key,
    this.email,
    this.name,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1E88E5),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 50,
                color: Color(0xFF1E88E5),
              ),
            ),
            accountName: Text(
              name ?? 'User Name',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              email ?? 'user@example.com',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              onClose();
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              onClose();
              context.go('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              onClose();
              // Tambahkan navigasi ke settings
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await Vania.deleteTokens();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
