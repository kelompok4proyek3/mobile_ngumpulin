import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../features/notification/services/notification_api_service.dart';

class FcmService {
  static final _messaging = FirebaseMessaging.instance;

  // Panggil ini setelah user login berhasil
  static Future<void> initFCM(BuildContext context) async {
    // Buat instance baru setiap kali initFCM dipanggil
    // supaya Dio selalu ambil auth_token yang sudah tersimpan
    final apiService = NotificationApiService();

    // 1. Minta izin notifikasi (iOS & Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // 2. Ambil FCM token dan kirim ke server
    final token = await _messaging.getToken();
    if (token != null) {
      await apiService.saveToken(token);
    }

    // 3. Refresh token otomatis kalau berubah
    _messaging.onTokenRefresh.listen((newToken) async {
      await NotificationApiService().saveToken(newToken);
    });

    // 4. Handle notifikasi saat app di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      if (notif != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
                if (notif.body != null)
                  Text(notif.body!,
                      style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    // 5. Handle tap notifikasi saat app di background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotifTap(message, context);
    });

    // 6. Handle tap notifikasi saat app terminated (cold start)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotifTap(initialMessage, context);
    }
  }

  static void _handleNotifTap(RemoteMessage message, BuildContext context) {
    final data = message.data;
    final tipe = data['tipe'] ?? 'system';

    // Tambahkan navigasi sesuai tipe di sini nanti
    // if (tipe == 'promo' && data['spot_id'] != null) {
    //   Navigator.push(context, MaterialPageRoute(
    //     builder: (_) => DetailScreen(spotId: int.parse(data['spot_id'])),
    //   ));
    // }
  }
}