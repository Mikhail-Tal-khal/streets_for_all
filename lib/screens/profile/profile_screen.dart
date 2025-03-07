import 'package:diabetes_test/providers/user_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userAuth = context.watch<UserAuthProvider>();
    final user = userAuth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'User',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildProfileTile(
            icon: Icons.email,
            title: 'Email',
            subtitle: user?.email ?? 'Not set',
          ),
          _buildProfileTile(
            icon: Icons.calendar_today,
            title: 'Member Since',
            subtitle: user?.createdAt != null 
                ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}' 
                : 'Unknown',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await context.read<UserAuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}