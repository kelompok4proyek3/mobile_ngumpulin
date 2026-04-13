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

  // Key untuk trigger reload MyListScreen
  final GlobalKey<_MyListRefreshState> _myListKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const RecommendationScreen(),
          _MyListRefresh(key: _myListKey),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 3) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');

            if (!mounted) return;

            if (token == null || token.isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
              return;
            }
          }

          // Kalau pindah ke tab List, reload datanya
          if (index == 2) {
            _myListKey.currentState?.reload();
          }

          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

// Wrapper tipis untuk expose method reload() ke luar
class _MyListRefresh extends StatefulWidget {
  const _MyListRefresh({super.key});

  @override
  State<_MyListRefresh> createState() => _MyListRefreshState();
}

class _MyListRefreshState extends State<_MyListRefresh> {
  // Key untuk rebuild MyListScreen setiap reload dipanggil
  Key _key = UniqueKey();

  void reload() {
    setState(() => _key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return MyListScreen(key: _key);
  }
}