import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/auth_api_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final _service = AuthApiService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await _service.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      passwordConfirmation: _confirmCtrl.text,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => OtpScreen(email: _emailCtrl.text.trim())));
    } else {
      String message = result['message'] ?? 'Gagal mendaftar';
      if (result['errors'] != null) {
        final errors = result['errors'] as Map<String, dynamic>;
        message = errors.values.first[0];
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ngumpul.in',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('Buat Akun',
                    style: TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, letterSpacing: -0.5,
                    )),
                const SizedBox(height: 8),
                const Text('Daftar untuk mulai menggunakan Ngumpul.in',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 32),

                _buildField(_nameCtrl, 'Nama Lengkap', Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null),
                const SizedBox(height: 16),

                _buildField(_emailCtrl, 'Email', Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                      if (!v.contains('@')) return 'Format email tidak valid';
                      return null;
                    }),
                const SizedBox(height: 16),

                _buildField(_passCtrl, 'Password', Icons.lock_outline,
                    obscure: _obscurePass,
                    toggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                      if (v.length < 8) return 'Password minimal 8 karakter';
                      return null;
                    }),
                const SizedBox(height: 16),

                _buildField(_confirmCtrl, 'Konfirmasi Password', Icons.lock_reset_outlined,
                    obscure: _obscureConfirm,
                    toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                      if (v != _passCtrl.text) return 'Password tidak cocok';
                      return null;
                    }),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Daftar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Masuk',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool? obscure,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: obscure ?? false,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                  (obscure ?? false) ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textHint, size: 20,
                ),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}