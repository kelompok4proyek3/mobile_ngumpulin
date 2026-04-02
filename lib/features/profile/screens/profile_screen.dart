import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/dummy_data.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = DummyData.userPreferences;
    final prefIcons = ['🎵', '🏃', '🍽️', '💻', '🎨'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
        ),
        title: const Text(AppStrings.profilSaya),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const Text(
                    'N',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Nieman',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'lukmanadiyatna2@gmail.com',
              style: TextStyle(fontSize: 13, color: AppColors.primary),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text(AppStrings.editProfil),
            ),

            const SizedBox(height: 24),

            // Preferences
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
                      const Text(
                        AppStrings.minatPreferensi,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          AppStrings.ubah,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                            Text(
                              preferences[i],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings
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
                    child: Text(
                      AppStrings.pengaturanAkun,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _SettingItem(
                    icon: Icons.notifications_outlined,
                    label: AppStrings.notifikasi,
                    onTap: () {},
                  ),
                  const Divider(
                      color: AppColors.divider, height: 1, indent: 56),
                  _SettingItem(
                    icon: Icons.security_outlined,
                    label: AppStrings.keamanan,
                    onTap: () {},
                  ),
                  const Divider(
                      color: AppColors.divider, height: 1, indent: 56),
                  _SettingItem(
                    icon: Icons.logout_rounded,
                    label: AppStrings.keluarAkun,
                    labelColor: AppColors.error,
                    iconColor: AppColors.error,
                    iconBgColor: AppColors.error.withOpacity(0.1),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
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
              child: Icon(icon,
                  size: 18,
                  color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: labelColor ?? AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
