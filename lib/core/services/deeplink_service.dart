import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

class DeeplinkPaymentData {
  final String merchantId;
  final String merchantName;
  final double amount;
  final String description;
  final String? reference;
  final String? callbackUrl;

  const DeeplinkPaymentData({
    required this.merchantId,
    required this.merchantName,
    required this.amount,
    required this.description,
    this.reference,
    this.callbackUrl,
  });

  factory DeeplinkPaymentData.fromUri(Uri uri) {
    final params = uri.queryParameters;
    final merchantId = _param(params, 'merchantId', 'merchant_id');
    final merchantName = _param(params, 'merchantName', 'merchant_name');
    final amountText = _param(params, 'amount');

    if (merchantId == null || merchantId.trim().isEmpty) {
      throw const FormatException('ID merchant wajib diisi.');
    }
    if (merchantName == null || merchantName.trim().isEmpty) {
      throw const FormatException('Nama merchant wajib diisi.');
    }
    if (amountText == null || amountText.trim().isEmpty) {
      throw const FormatException('Nominal pembayaran wajib diisi.');
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      throw const FormatException('Nominal pembayaran tidak valid.');
    }
    if (amount <= 0) {
      throw const FormatException('Nominal pembayaran harus lebih dari 0.');
    }

    final description = _param(params, 'description');
    final normalizedMerchantName = merchantName.trim();

    return DeeplinkPaymentData(
      merchantId: merchantId.trim(),
      merchantName: normalizedMerchantName,
      amount: amount,
      description: description == null || description.trim().isEmpty
          ? 'Pembayaran ke $normalizedMerchantName'
          : description.trim(),
      reference: _emptyToNull(_param(params, 'reference')),
      callbackUrl: _emptyToNull(_param(params, 'callbackUrl', 'callback_url')),
    );
  }

  static String? _param(Map<String, String> params, String key,
      [String? fallbackKey]) {
    return params[key] ?? (fallbackKey == null ? null : params[fallbackKey]);
  }

  static String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

class DeeplinkService {
  final GoRouter _router;
  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  DeeplinkService(this._router) : _appLinks = AppLinks();

  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);

    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    if (!_isPaymentLink(uri)) return;

    try {
      final data = DeeplinkPaymentData.fromUri(uri);
      _router.go('/pay', extra: data);
    } on FormatException catch (e) {
      _router.go('/pay', extra: e.message);
    }
  }

  bool _isPaymentLink(Uri uri) {
    return (uri.scheme == 'dompetkampus' && uri.host == 'pay') ||
        (uri.scheme == 'https' &&
            uri.host == 'dompetkampus.app' &&
            uri.path.startsWith('/pay'));
  }

  void dispose() => _subscription?.cancel();
}
