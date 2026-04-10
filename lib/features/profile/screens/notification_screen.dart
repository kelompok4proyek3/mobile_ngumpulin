// lib/features/profile/screens/notification_screen.dart
// Stub — bisa dikembangkan lebih lanjut

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifikasi'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 64, color: AppColors.primary),
            SizedBox(height: 12),
            Text('Belum ada notifikasi',
                style: TextStyle(
                    fontSize: 15, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}