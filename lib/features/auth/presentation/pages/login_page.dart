import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/localization/app_localizations.dart';
import 'package:inspector_app/features/auth/presentation/controller/login_controller.dart';
import 'package:inspector_app/core/routing/page_transitions.dart';
import 'package:inspector_app/features/main/presentation/pages/main_shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late final LoginController _controller;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _controller = createLoginController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.loginFillAllFields),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await _controller.login(email: email, password: password);
    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pushReplacement(FadePageRoute(child: const MainShellPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? strings.loginFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Decor
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.05),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: FadeTransition(
                    opacity: _formAnimation,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Hero(
                              tag: 'app_logo',
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 100,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.verified, size: 80, color: theme.colorScheme.primary);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'ديوان الوقف السني',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.loginButton, // Or a generic "Welcome back"
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            
                            Card(
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: strings.email,
                                        prefixIcon: const Icon(Icons.person_outline),
                                        hintText: 'user@example.com',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      onSubmitted: (_) => _submit(),
                                      decoration: InputDecoration(
                                        labelText: strings.password,
                                        prefixIcon: const Icon(Icons.lock_open_outlined),
                                        hintText: '••••••••',
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: _controller.isLoading ? null : _submit,
                                        child: _controller.isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(strings.loginButton),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () {}, // Forgot password placeholder
                              child: Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color: theme.colorScheme.primary.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
