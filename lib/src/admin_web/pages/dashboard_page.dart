import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'users_page.dart';
import 'security_page.dart';
import 'contacts_page.dart';
import 'activity_page.dart';
import 'admin_profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  final List<Widget> _pages = const [
    UsersPage(),
    SecurityPage(),
    ContactsPage(),
    ActivityPage(),
    AdminProfilePage(),
  ];

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }
  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _pages.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Users'),
            Tab(icon: Icon(Icons.security), text: 'Security'),
            Tab(icon: Icon(Icons.contacts), text: 'Contacts'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
            Tab(icon: Icon(Icons.account_circle), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: _pages,
      ),
    );
  }
}