// lib/features/notification/screens/notification_screen.dart

import 'package:flutter/material.dart';
import '../services/notification_api_service.dart';
import '../../../core/constants/app_colors.dart';

class NotifItem {
  final int id;
  final String judul;
  final String pesan;
  final String tipe;
  final String createdAt;
  bool isRead;

  NotifItem({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.createdAt,
    required this.isRead,
  });

  factory NotifItem.fromJson(Map<String, dynamic> json) => NotifItem(
        id:        (json['id'] as num).toInt(),
        judul:     json['judul'] ?? '',
        pesan:     json['pesan'] ?? '',
        tipe:      json['tipe'] ?? 'system',
        createdAt: json['created_at'] ?? '',
        isRead:    json['is_read'] == true,
      );
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _service = NotificationApiService();
  List<NotifItem> _notifications = [];
  bool _isLoading = true;
  int _filterIndex = 0;
  int _unreadCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await _service.getNotifications();
    if (!mounted) return;
    if (result['success'] == true) {
      final List<dynamic> data = result['data'] ?? [];
      setState(() {
        _notifications = data.map((j) => NotifItem.fromJson(j)).toList();
        _unreadCount   = result['unread_count'] ?? 0;
        _isLoading     = false;
      });
    } else {
      setState(() {
        _error     = result['message'] ?? 'Gagal memuat notifikasi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(NotifItem item) async {
    if (item.isRead) return;
    setState(() {
      item.isRead  = true;
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
    });
    await _service.markAsRead(item.id);
  }

  Future<void> _markAllRead() async {
    setState(() {
      for (final n in _notifications) n.isRead = true;
      _unreadCount = 0;
    });
    await _service.markAllAsRead();
  }

  Future<void> _delete(NotifItem item) async {
    final wasUnread = !item.isRead;
    setState(() {
      _notifications.remove(item);
      if (wasUnread) _unreadCount = (_unreadCount - 1).clamp(0, 999);
    });
    await _service.deleteNotification(item.id);
  }

  List<NotifItem> get _filtered =>
      _filterIndex == 1 ? _notifications.where((n) => !n.isRead).toList() : _notifications;

  IconData _icon(String tipe) {
    switch (tipe) {
      case 'promo':    return Icons.local_offer_rounded;
      case 'rating':   return Icons.star_rounded;
      case 'reminder': return Icons.access_time_rounded;
      default:         return Icons.settings_rounded;
    }
  }

  Color _color(String tipe) {
    switch (tipe) {
      case 'promo':    return AppColors.primary;
      case 'rating':   return const Color(0xFF4A90D9);
      case 'reminder': return const Color(0xFF9C27B0);
      default:         return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.textPrimary),
          ),
        ),
        title: Column(children: [
          const Text('Notifikasi',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          if (_unreadCount > 0)
            Text('$_unreadCount belum dibaca',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
        ]),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Tandai Semua',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(children: [
              _FilterChip(label: 'Semua', isActive: _filterIndex == 0,
                  onTap: () => setState(() => _filterIndex = 0)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Belum Dibaca', isActive: _filterIndex == 1,
                  badge: _unreadCount > 0 ? _unreadCount : null,
                  onTap: () => setState(() => _filterIndex = 1)),
            ]),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: AppColors.textHint)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
                      ]))
                    : list.isEmpty
                        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                              child: const Icon(Icons.notifications_none_rounded, size: 40, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(_filterIndex == 1 ? 'Semua sudah dibaca 👍' : 'Belum ada notifikasi',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 6),
                            const Text('Notifikasi baru akan muncul di sini',
                                style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                          ]))
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              itemCount: list.length,
                              itemBuilder: (context, i) {
                                final item = list[i];
                                return Dismissible(
                                  key: Key('notif_${item.id}'),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => _delete(item),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius: BorderRadius.circular(18)),
                                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
                                      SizedBox(height: 2),
                                      Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ]),
                                  ),
                                  child: _NotifCard(
                                    item: item,
                                    icon: _icon(item.tipe),
                                    color: _color(item.tipe),
                                    onTap: () => _markRead(item),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotifItem item;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _NotifCard({required this.item, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(18),
          border: item.isRead
              ? Border.all(color: AppColors.divider)
              : Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.2),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(item.isRead ? 0.03 : 0.06),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(item.judul,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ),
                  if (!item.isRead)
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                    ),
                ]),
                const SizedBox(height: 4),
                Text(item.pesan,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 6),
                Text(item.createdAt,
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final int? badge;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isActive, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary)),
          if (badge != null && badge! > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$badge',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.primary : Colors.white)),
            ),
          ],
        ]),
      ),
    );
  }
}