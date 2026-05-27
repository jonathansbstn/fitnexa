import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/snack_helper.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isRegister = false;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _error = '';
  bool _loading = false;
  bool _obscure = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email & password wajib diisi');
      return;
    }
    if (_isRegister && name.isEmpty) {
      setState(() => _error = 'Nama wajib diisi');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Format email tidak valid');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    final displayName = _isRegister ? name : 'Jonathan Sebastian';
    await context.read<AppProvider>().login(displayName, email);
    if (!mounted) return;
    showSnack(context, 'Selamat datang, $displayName! 👋');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
      _error = '';
    });
    _fadeCtrl.reset();
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.38),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('⚡', style: TextStyle(fontSize: 38)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FITNEXA',
                    style: TextStyle(
                      color: context.appTextPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI-Powered Home Workout Tracker',
                    style: TextStyle(
                      color: context.appTextMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.appCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: context.appDivider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isRegister ? 'Daftar Akun' : 'Selamat Datang',
                          style: TextStyle(
                            color: context.appTextPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRegister
                              ? 'Buat akun baru untuk mulai workout'
                              : 'Masuk ke akun FITNEXA kamu',
                          style: TextStyle(
                            color: context.appTextMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Name (register only)
                        if (_isRegister) ...[
                          TextField(
                            controller: _nameCtrl,
                            style: TextStyle(color: context.appTextPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Nama Lengkap',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Email
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: context.appTextPrimary),
                          decoration:
                              const InputDecoration(hintText: 'Email'),
                        ),
                        const SizedBox(height: 12),

                        // Password
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          style: TextStyle(color: context.appTextPrimary),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            suffixIcon: GestureDetector(
                              onTap: () =>
                                  setState(() => _obscure = !_obscure),
                              child: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: context.appTextMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // Error
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            '⚠ $_error',
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Submit Button
                        _loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : GradientButton(
                                label: _isRegister
                                    ? 'Daftar Sekarang'
                                    : 'Masuk',
                                onPressed: _submit,
                              ),
                        const SizedBox(height: 16),

                        // Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRegister
                                  ? 'Sudah punya akun? '
                                  : 'Belum punya akun? ',
                              style: TextStyle(
                                color: context.appTextMuted,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleMode,
                              child: const Text(
                                '',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleMode,
                              child: Text(
                                _isRegister ? 'Masuk' : 'Daftar',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!_isRegister) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Demo: isi email & password bebas',
                              style: TextStyle(
                                color: context.appTextMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
