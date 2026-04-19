// lib/features/profile/screens/profile_screen.dart
//
// FIX: preferences dari API (PreferenceApiService.getUserPreferences())
// bukan dari DummyData yang hardcode

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_api_service.dart';
import '../../onboarding/screens/preference_screen.dart';
import '../../onboarding/services/preference_api_service.dart';
import 'edit_profile_screen.dart';
import '../../notification/screens/notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name      = '';
  String _email     = '';
  String? _avatarUrl;
  bool _isLoading   = true;

  // Preferences dari API
  List<Map<String, dynamic>> _preferences = [];
  bool _isLoadingPrefs = true;

  final _prefService = PreferenceApiService();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadUserData(), _loadPreferences()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _name      = prefs.getString('user_name')  ?? '';
        _email     = prefs.getString('user_email') ?? '';
        _avatarUrl = prefs.getString('user_avatar');
      });
    }
  }

  // GET /api/preferences/user
  Future<void> _loadPreferences() async {
    setState(() => _isLoadingPrefs = true);
    final result = await _prefService.getUserPreferences();
    if (!mounted) return;

    if (result['success'] == true) {
      final List<dynamic> data = result['data'] ?? [];
      setState(() {
        _preferences = data.map((p) => {
          'id'  : p['id'],
          'nama': (p['nama_preference'] ?? p['nama'] ?? '').toString(),
          'icon': _emojiFor((p['nama_preference'] ?? p['nama'] ?? '').toString()),
        }).toList();
      });
    } else {
      setState(() => _preferences = []);
    }
    setState(() => _isLoadingPrefs = false);
  }

  // Mapping nama preferensi → emoji
  String _emojiFor(String nama) {
    final n = nama.toLowerCase();
    if (n.contains('kafe') || n.contains('coffee'))           return '☕';
    if (n.contains('resto') || n.contains('kuliner'))         return '🍽️';
    if (n.contains('outdoor'))                                 return '🌲';
    if (n.contains('rooftop'))                                 return '🏙️';
    if (n.contains('budget'))                                  return '💰';
    if (n.contains('night') || n.contains('malam'))           return '🌙';
    if (n.contains('wifi'))                                    return '📶';
    if (n.contains('music') || n.contains('musik'))           return '🎵';
    if (n.contains('konser'))                                  return '🎤';
    if (n.contains('kid') || n.contains('anak'))              return '👶';
    if (n.contains('stop') || n.contains('charge'))           return '🔌';
    if (n.contains('olah') || n.contains('sport'))            return '🏃';
    if (n.contains('teknologi') || n.contains('tech'))        return '💻';
    if (n.contains('seni') || n.contains('art'))              return '🎨';
    return '📍';
  }

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

    await AuthApiService().logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Avatar ────────────────────────────────────────────────────
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
                          ? Image.network(_avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildInitial())
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

              Text(
                _name.isNotEmpty ? _name : 'Pengguna',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(_email,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.primary)),
              const SizedBox(height: 20),

              // ── Edit Profil ───────────────────────────────────────────────
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
                  if (updated == true) _loadUserData();
                },
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text(AppStrings.editProfil),
              ),

              const SizedBox(height: 24),

              // ── Minat & Preferensi dari API ───────────────────────────────
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
                          onTap: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PreferenceScreen(isEditing: true),
                              ),
                            );
                            // Reload dari API setelah ubah preferensi
                            if (updated == true) _loadPreferences();
                          },
                          child: const Text(AppStrings.ubah,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Loading
                    if (_isLoadingPrefs)
                      const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        ),
                      )

                    // Empty — ajak tambah preferensi
                    else if (_preferences.isEmpty)
                      GestureDetector(
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PreferenceScreen(isEditing: true),
                            ),
                          );
                          if (updated == true) _loadPreferences();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: const Center(
                            child: Text('+ Tambah preferensi',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      )

                    // Chip preferences dari API
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _preferences.map((pref) {
                          return Container(
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
                                Text(pref['icon'] as String,
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 6),
                                Text(pref['nama'] as String,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Pengaturan Akun ───────────────────────────────────────────
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
                      onTap: () => Navigator.push(
                          context,
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
                            initialTabIndex: 1,
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
              child:
                  Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
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