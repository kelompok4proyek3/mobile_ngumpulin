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

  final GlobalKey<_MyListRefreshState> _myListKey = GlobalKey();

  // Tab yang butuh login
  static const _authRequiredTabs = {1, 3};

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

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
          // Cek login untuk tab rekomendasi & profil
          if (_authRequiredTabs.contains(index)) {
            final loggedIn = await _isLoggedIn();
            if (!mounted) return;

            if (!loggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
              return;
            }
          }

          // Reload list saat pindah ke tab List
          if (index == 2) {
            _myListKey.currentState?.reload();
          }

          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _MyListRefresh extends StatefulWidget {
  const _MyListRefresh({super.key});

  @override
  State<_MyListRefresh> createState() => _MyListRefreshState();
}

class _MyListRefreshState extends State<_MyListRefresh> {
  Key _key = UniqueKey();

  void reload() {
    setState(() => _key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return MyListScreen(key: _key);
  }
}