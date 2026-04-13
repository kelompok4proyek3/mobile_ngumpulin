// lib/features/profile/screens/profile_screen.dart
//
// PERBAIKAN UTAMA:
// - Hapus semua hardcode ('N', 'Nieman', 'lukmanadiyatna2@gmail.com')
// - Nama & email diambil dari SharedPreferences yang diisi AuthApiService.login()
// - Avatar inisial otomatis dari huruf pertama nama login
// - Logout benar redirect ke LoginScreen (bukan MainScreen)
// - Pull-to-refresh untuk reload data

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/dummy_data.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_api_service.dart';
import 'edit_profile_screen.dart';
import '../../notification/screens/notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String? _avatarUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Baca dari SharedPreferences — diisi oleh AuthApiService.login()
  // key: 'user_name', 'user_email', 'user_avatar'
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name     = prefs.getString('user_name')  ?? '';
      _email    = prefs.getString('user_email') ?? '';
      _avatarUrl = prefs.getString('user_avatar');
      _isLoading = false;
    });
  }

  // Inisial huruf pertama nama untuk avatar placeholder
  String get _initial =>
      _name.trim().isNotEmpty ? _name.trim()[0].toUpperCase() : '?';

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text('Yakin ingin keluar dari akun ini?',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Panggil API logout → hapus token di server (Sanctum)
    final authService = AuthApiService();
    await authService.logout();

    // Hapus semua data lokal
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    // Redirect ke LoginScreen, bersihkan semua history
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = DummyData.userPreferences;
    final prefIcons   = ['🎵', '🏃', '🍽️', '💻', '🎨'];

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F0EB),
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(AppStrings.profilSaya),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Avatar ─────────────────────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                      color: AppColors.primaryLight,
                    ),
                    child: ClipOval(
                      child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                          ? Image.network(
                              _avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildInitial(),
                            )
                          : _buildInitial(),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Nama dari SharedPreferences ─────────────────────────────
              Text(
                _name.isNotEmpty ? _name : 'Pengguna',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              // ── Email dari SharedPreferences ────────────────────────────
              Text(
                _email,
                style: const TextStyle(fontSize: 13, color: AppColors.primary),
              ),
              const SizedBox(height: 20),

              // ── Edit Profil ─────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        initialName: _name,
                        initialEmail: _email,
                        initialAvatarUrl: _avatarUrl,
                      ),
                    ),
                  );
                  // Jika edit sukses, reload tampilan dari SharedPreferences
                  if (updated == true) _loadUserData();
                },
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text(AppStrings.editProfil),
              ),

              const SizedBox(height: 24),

              // ── Minat & Preferensi ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(AppStrings.minatPreferensi,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(AppStrings.ubah,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        preferences.length,
                        (i) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(prefIcons[i % prefIcons.length],
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                              Text(preferences[i],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Pengaturan Akun ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(AppStrings.pengaturanAkun,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    _SettingItem(
                      icon: Icons.notifications_outlined,
                      label: AppStrings.notifikasi,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationScreen())),
                    ),
                    const Divider(
                        color: AppColors.divider, height: 1, indent: 56),
                    _SettingItem(
                      icon: Icons.security_outlined,
                      label: AppStrings.keamanan,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            initialName: _name,
                            initialEmail: _email,
                            initialAvatarUrl: _avatarUrl,
                            initialTabIndex: 1, // langsung tab Ubah Password
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                        color: AppColors.divider, height: 1, indent: 56),
                    _SettingItem(
                      icon: Icons.logout_rounded,
                      label: AppStrings.keluarAkun,
                      labelColor: AppColors.error,
                      iconColor: AppColors.error,
                      iconBgColor: AppColors.error.withOpacity(0.1),
                      onTap: _handleLogout,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitial() => Center(
        child: Text(_initial,
            style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: AppColors.primary)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;
  final Color? iconBgColor;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18, color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? AppColors.textPrimary)),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: labelColor ?? AppColors.textHint),
          ],
        ),
      ),
    );
  }
}