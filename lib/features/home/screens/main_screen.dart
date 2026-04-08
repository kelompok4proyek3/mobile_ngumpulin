import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../recommendation/screens/recommendation_screen.dart';
import '../../mylist/screens/my_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/widgets/custom_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/screens/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RecommendationScreen(),
    MyListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 3) { // index 3 = ProfileScreen
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');

            if (!mounted) return;

            if (token == null || token.isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
              return; // jangan pindah index
            }
          }

          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
