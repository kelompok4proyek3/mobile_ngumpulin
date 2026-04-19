import 'package:flutter/material.dart';
import '../../home/screens/main_screen.dart';
import '../services/preference_api_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class PreferenceScreen extends StatefulWidget {
  /// Jika true, tombol Lanjutkan akan pop() bukan pushReplacement ke MainScreen
  /// Dipakai saat dibuka dari ProfileScreen
  final bool isEditing;

  const PreferenceScreen({super.key, this.isEditing = false});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  final _service = PreferenceApiService();

  List<Map<String, dynamic>> _allPreferences = [];
  final Set<int> _selectedIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Ambil semua preference & preference yang sudah dipilih user secara paralel
      final results = await Future.wait([
        _service.getAllPreferences(),
        _service.getUserPreferences(),
      ]);

      final allData = results[0];
      final userData = results[1];

      if (allData['success'] == true) {
        _allPreferences =
            List<Map<String, dynamic>>.from(allData['data']);
      }

      if (userData['success'] == true) {
        final userPrefs =
            List<Map<String, dynamic>>.from(userData['data']);
        _selectedIds
          ..clear()
          ..addAll(userPrefs.map<int>((p) => p['id'] as int));
      }
    } catch (_) {
      // handle error jika perlu
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (_selectedIds.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final result =
          await _service.syncUserPreferences(_selectedIds.toList());

      if (!mounted) return;

      if (result['success'] == true) {
        if (widget.isEditing) {
          // Dari ProfileScreen: kembalikan true supaya ProfileScreen reload
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(result['message'] ?? 'Gagal menyimpan preferensi')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, coba lagi.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // ── Header ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20, color: AppColors.textPrimary),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              AppStrings.appName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),

                  // ── Body ─────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            AppStrings.pilihPreferensimu,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            AppStrings.preferensiSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _allPreferences.map((pref) {
                              final id = pref['id'] as int;
                              final nama =
                                  pref['nama_preference'] as String;
                              final isSelected =
                                  _selectedIds.contains(id);

                              return GestureDetector(
                                onTap: () => setState(() {
                                  if (isSelected) {
                                    _selectedIds.remove(id);
                                  } else {
                                    _selectedIds.add(id);
                                  }
                                }),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.white,
                                    borderRadius:
                                        BorderRadius.circular(50),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.divider,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    nama,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // ── Footer ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: (_selectedIds.isEmpty || _isSaving)
                              ? null
                              : _handleSave,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(widget.isEditing
                                  ? AppStrings.simpan
                                  : AppStrings.lanjutkan),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          AppStrings.bisaUbahKapanSaja,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}