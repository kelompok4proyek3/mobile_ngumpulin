// lib/core/widgets/rating_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/detail/services/rating_api_service.dart';
import '../constants/app_colors.dart';

const _kMaxPhotos    = 3;
const _kMaxSizeMB    = 1;
const _kMaxSizeBytes = _kMaxSizeMB * 1024 * 1024;

// ── Helper function ────────────────────────────────────────────────────────
Future<bool> showRatingDialog(BuildContext context, int spotId) async {
  final service = RatingApiService();

  final myRatingData  = await service.getMyRating(spotId);
  final hasRated      = myRatingData['has_rated'] == true;
  final existingScore = hasRated ? (myRatingData['data']['score'] as int) : 0;
  final existingNote  = hasRated
      ? ((myRatingData['data']['review_text'] as String?) ?? '')
      : '';

  // Ambil semua foto lama sebagai List<String>
  final existingFotoUrls = hasRated
      ? ((myRatingData['data']['foto_urls'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [])
      : <String>[];

  if (!context.mounted) return false;

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RatingSheet(
      spotId: spotId,
      existingScore: existingScore,
      existingNote: existingNote,
      existingFotoUrls: existingFotoUrls,
      service: service,
    ),
  );

  return result == true;
}

// ── Bottom Sheet ────────────────────────────────────────────────────────────
class _RatingSheet extends StatefulWidget {
  final int spotId;
  final int existingScore;
  final String existingNote;
  final List<String> existingFotoUrls;
  final RatingApiService service;

  const _RatingSheet({
    required this.spotId,
    required this.existingScore,
    required this.existingNote,
    required this.existingFotoUrls,
    required this.service,
  });

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  late int _selectedScore;
  late TextEditingController _noteCtrl;
  List<File> _photos = [];
  bool _isLoading = false;
  final _picker = ImagePicker();

  final _labels = {
    0: 'Pilih bintang dulu',
    1: 'Sangat Buruk 😞',
    2: 'Kurang Memuaskan 😕',
    3: 'Cukup 😐',
    4: 'Bagus! 😊',
    5: 'Luar Biasa! 🤩',
  };

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.existingScore;
    _noteCtrl = TextEditingController(text: widget.existingNote);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final remaining = _kMaxPhotos - _photos.length;
    if (remaining <= 0) return;

    final picked = await _picker.pickMultiImage(imageQuality: 75);
    if (picked.isEmpty) return;

    final List<File> valid    = [];
    final List<String> errors = [];

    for (final xfile in picked.take(remaining)) {
      final file = File(xfile.path);
      final size = await file.length();
      if (size > _kMaxSizeBytes) {
        errors.add('${xfile.name} melebihi ${_kMaxSizeMB}MB');
      } else {
        valid.add(file);
      }
    }

    if (valid.isNotEmpty) setState(() => _photos = [..._photos, ...valid]);

    if (errors.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Foto ditolak (>${_kMaxSizeMB}MB):\n${errors.join('\n')}'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  Future<void> _submit() async {
    if (_selectedScore == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih bintang terlebih dahulu'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);

    final result = await widget.service.submitRating(
      widget.spotId,
      _selectedScore,
      reviewText: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      fotos: _photos.isEmpty ? null : _photos,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(result['message'] ?? 'Rating berhasil dikirim'),
        ]),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Gagal mengirim rating'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate  = widget.existingScore > 0;
    final usedSlots = _photos.isNotEmpty
        ? _photos.length
        : widget.existingFotoUrls.length;
    final canAddMore = _photos.length < _kMaxPhotos;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Center(
              child: Text(
                isUpdate ? 'Perbarui Ulasan' : 'Tulis Ulasan',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                isUpdate
                    ? 'Rating sebelumnya: ${widget.existingScore} bintang'
                    : 'Bagaimana pengalamanmu di sini?',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            // Bintang
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final starNum = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedScore = starNum),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starNum <= _selectedScore
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: starNum <= _selectedScore ? 48 : 40,
                        color: starNum <= _selectedScore
                            ? AppColors.star
                            : AppColors.divider,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _labels[_selectedScore] ?? '',
                  key: ValueKey(_selectedScore),
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: _selectedScore > 0 ? AppColors.primary : AppColors.textHint,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Catatan
            const Text('Catatan (opsional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0EB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 300,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ceritakan pengalamanmu di sini...',
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  counterStyle: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Foto ─────────────────────────────────────────────────────
            Row(
              children: [
                const Text('Foto (opsional)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const Spacer(),
                Text(
                  '$usedSlots/$_kMaxPhotos • maks ${_kMaxSizeMB}MB/foto',
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Foto baru yang dipilih
                  ..._photos.asMap().entries.map((e) {
                    final idx  = e.key;
                    final file = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(file,
                                width: 90, height: 90, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4, right: 4,
                            child: GestureDetector(
                              onTap: () => _removePhoto(idx),
                              child: Container(
                                width: 22, height: 22,
                                decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close_rounded,
                                    size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Foto lama (tampil kalau belum ada foto baru dipilih)
                  if (_photos.isEmpty)
                    ...widget.existingFotoUrls.map((url) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              url,
                              width: 90, height: 90, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 90, height: 90,
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.broken_image_outlined,
                                    color: AppColors.textHint),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4, right: 4,
                            child: GestureDetector(
                              onTap: _pickPhotos,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_rounded,
                                        size: 10, color: Colors.white),
                                    SizedBox(width: 3),
                                    Text('Ganti',
                                        style: TextStyle(fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                  // Tombol tambah foto
                  if (canAddMore)
                    GestureDetector(
                      onTap: _pickPhotos,
                      child: Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.4),
                              width: 1.5),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 26, color: AppColors.primary),
                            SizedBox(height: 4),
                            Text('Tambah',
                                style: TextStyle(fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading || _selectedScore == 0 ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.divider,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text(
                        isUpdate ? 'Perbarui Ulasan' : 'Kirim Ulasan',
                        style: const TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700, color: Colors.white),
                      ),
              ),
            ),

            // Hapus rating
            if (isUpdate) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          final result = await widget.service
                              .deleteMyRating(widget.spotId);
                          setState(() => _isLoading = false);
                          if (!mounted) return;
                          Navigator.pop(context, true);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result['message'] ?? 'Rating dihapus'),
                            behavior: SnackBarBehavior.floating,
                          ));
                        },
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: AppColors.error),
                  label: const Text('Hapus Ulasan',
                      style: TextStyle(color: AppColors.error,
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}