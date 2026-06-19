import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class PaymentDeeplinkPage extends StatelessWidget {
  final Object? data;

  const PaymentDeeplinkPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final payload = data;

    if (payload is String) {
      return _ErrorView(message: payload);
    }
    if (payload is! DeeplinkPaymentData) {
      return const _ErrorView(
        message: 'Link pembayaran tidak valid atau sudah tidak tersedia.',
      );
    }

    final amountText = CurrencyFormatter.format(payload.amount);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _Header(merchantName: payload.merchantName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                children: [
                  _TotalCard(amountText: amountText),
                  const SizedBox(height: 14),
                  _DetailCard(payload: payload),
                  const SizedBox(height: 14),
                  const _PaymentMethodCard(),
                  const SizedBox(height: 14),
                  const _SecurityBanner(),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: AppButton(
              label: 'Bayar $amountText',
              onPressed: () => context.go('/pin', extra: {
                'kind': 'deeplink',
                'amount': payload.amount,
                'description': payload.description,
                'merchantName': payload.merchantName,
                'merchantId': payload.merchantId,
                'reference': payload.reference,
                'callbackUrl': payload.callbackUrl,
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String merchantName;

  const _Header({required this.merchantName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        18,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => context.go('/home'),
          ),
          const Expanded(
            child: Text(
              'Konfirmasi Pembayaran',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                merchantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final String amountText;

  const _TotalCard({required this.amountText});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amountText,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final DeeplinkPaymentData payload;

  const _DetailCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _DetailRow(label: 'Merchant', value: payload.merchantName),
          const Divider(height: 1, color: AppColors.line2),
          _DetailRow(label: 'Keterangan', value: payload.description),
          if (payload.reference != null) ...[
            const Divider(height: 1, color: AppColors.line2),
            _DetailRow(label: 'Referensi', value: payload.reference!),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: const [
          AppLogo(size: 42),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dompet Kampus Global',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Saldo · pembayaran instan',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_rounded, size: 20, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pembayaran akan diverifikasi dengan PIN dan 2FA sebelum diproses.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.redSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link_off_rounded,
                    color: AppColors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Link Pembayaran Tidak Valid',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Kembali ke Beranda',
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.slate500,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowSoft,
      ),
      child: child,
    );
  }
}
