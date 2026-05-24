import 'package:flutter/material.dart';
import '../../home/screens/main_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../services/auth_api_service.dart';
import 'register_screen.dart';
import '../services/google_auth_service.dart';
import '../../../core/services/fcm_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthApiService _authApiService = AuthApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showSnack('Email dan password wajib diisi');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await _authApiService.login(email, password);
      if (!mounted) return;
      if (result['success'] == true) {
        await FcmService.initFCM(context);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        _showSnack(result['message'] ?? 'Login gagal', isError: true);
      }
    } catch (_) {
      if (mounted) _showSnack('Tidak dapat terhubung ke server.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final result = await GoogleAuthService().signInWithGoogle();
      if (!mounted) return;
      if (result['success'] == true) {
        await FcmService.initFCM(context);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        _showSnack(result['message'] ?? 'Login Google gagal', isError: true);
      }
    } catch (_) {
      if (mounted) _showSnack('Tidak dapat terhubung ke server.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Text(
                      AppStrings.appName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline_rounded, size: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silakan masuk ke akun Anda atau daftar baru untuk mulai berkumpul dengan komunitas favoritmu.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 28),

                    // Google Button
                    _buildGoogleButton(),
                    const SizedBox(height: 20),

                    // Divider
                    Row(children: [
                      const Expanded(child: Divider(color: AppColors.divider)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('atau gunakan email',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                      const Expanded(child: Divider(color: AppColors.divider)),
                    ]),
                    const SizedBox(height: 20),

                    // Email
                    const Text('Email',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'nama@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kata Sandi',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('Lupa sandi?',
                              style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(),
                    const SizedBox(height: 28),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Masuk Sekarang',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun?',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: const Text('Daftar Gratis',
                              style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Trust badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 13, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        const Text('Aman & Terenkripsi',
                            style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                        const SizedBox(width: 16),
                        const Icon(Icons.public_outlined, size: 13, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        const Text('Komunitas Indonesia',
                            style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleLogin,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.divider),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('G', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 18)),
            SizedBox(width: 10),
            Text('Masuk dengan Google',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Masukkan kata sandi',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textHint,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ],
      ),
    );
  }
}