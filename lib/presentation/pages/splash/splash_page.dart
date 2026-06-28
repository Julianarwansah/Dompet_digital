import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/feature_icon.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  const AppLogo(size: 80),
                  const SizedBox(height: 24),
                  // Welcome text
                  const Text(
                    'Selamat Datang',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Bayar, transfer, dan kelola uang kuliah dalam satu aplikasi yang aman.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Feature cards (sama seperti home grid)
                  _buildFeatureCard(),
                  const SizedBox(height: 24),
                  // Buttons
                  AppButton(
                    label: 'Buat Akun Baru',
                    variant: AppButtonVariant.primary,
                    icon: const Icon(Icons.person_add_outlined,
                        size: 20, color: Colors.white),
                    onPressed: () => context.push('/register'),
                  ),
                  const SizedBox(height: 11),
                  AppButton(
                    label: 'Masuk ke Akun',
                    variant: AppButtonVariant.outline,
                    icon: const Icon(Icons.login_rounded,
                        size: 20, color: AppColors.ink),
                    onPressed: () => context.push('/login'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard() {
    final features = [
      {'icon': Icons.qr_code_rounded, 'label': 'Bayar', 'tone': 'violet'},
      {'icon': Icons.send_rounded, 'label': 'Transfer', 'tone': 'green'},
      {'icon': Icons.north_rounded, 'label': 'Top Up', 'tone': 'blue'},
      {'icon': Icons.receipt_long_outlined, 'label': 'UKT', 'tone': 'amber'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: features.map((f) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FeatureIcon(
                icon: f['icon'] as IconData,
                tone: f['tone'] as String,
                size: 48,
                iconSize: 24,
              ),
              const SizedBox(height: 8),
              Text(
                f['label'] as String,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
