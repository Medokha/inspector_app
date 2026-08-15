import 'dart:async';

import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/localization/app_localizations.dart';
import 'package:inspector_app/core/routing/page_transitions.dart';
import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/core/ui/responsive.dart';
import 'package:inspector_app/features/auth/presentation/pages/login_page.dart';
import 'package:inspector_app/features/main/presentation/pages/main_shell_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55, curve: Curves.easeOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack)),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.45, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2400), () async {
      if (!mounted) return;
      final authenticated = currentAuthSession().isAuthenticated;
      if (authenticated) {
        unawaited(startInspectorRealtime());
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        FadePageRoute(child: authenticated ? const MainShellPage() : const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final logoSize = Responsive.logoSize(context, max: 200, min: 110);
    final short = Responsive.isShort(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF161F30),
              AppTheme.primaryNavy,
              Color(0xFF0E1420),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: short ? 24 : 48),
                            const Spacer(flex: 2),
                            Opacity(
                              opacity: _fadeAnimation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Hero(
                                  tag: 'app_logo',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: logoSize,
                                      padding: EdgeInsets.all(logoSize * 0.08),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.28),
                                            blurRadius: 28,
                                            offset: const Offset(0, 14),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.verified,
                                            size: logoSize * 0.42,
                                            color: theme.colorScheme.primary,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: short ? 20 : 36),
                            Opacity(
                              opacity: _textAnimation.value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: <Widget>[
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'المفتش',
                                        style: theme.textTheme.displaySmall?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.accentGold,
                                          letterSpacing: 1.2,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'ديوان الوقف السني',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.88),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      strings.splashLoading,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(flex: 2),
                            Opacity(
                              opacity: _textAnimation.value,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: short ? 20 : 36, top: 16),
                                child: SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
