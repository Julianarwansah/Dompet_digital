import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../injection/injection_container.dart';
import '../../blocs/auth/otp_bloc.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../widgets/code_input.dart';
import '../../widgets/pin_pad.dart';

enum _Step { pin, otp }

class PinPage extends StatefulWidget {
  final Map<String, dynamic> flowData;

  const PinPage({super.key, required this.flowData});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  _Step _step = _Step.pin;
  String _pin = '';
  String _otpCode = '';
  String _twoFaMethod = AppConstants.twoFaTotp;
  bool _busy = false;
  bool _hasError = false;
  int _timer = AppConstants.otpResendSeconds;
  Timer? _countdown;

  String get _kind => widget.flowData['kind'] as String? ?? '';

  String get _otpType {
    return switch (_twoFaMethod) {
      AppConstants.twoFaSmtp => AppConstants.otpTypeEmail,
      AppConstants.twoFaNotif => AppConstants.otpTypeFirebase,
      _ => AppConstants.otpTypeTotp,
    };
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _onPinComplete(String pin) {
    setState(() {
      _pin = pin;
      _busy = true;
      _hasError = false;
    });

    if (_kind == AppConstants.txnTopup) {
      context
          .read<PaymentBloc>()
          .add(PaymentTopupRequested(_amountFor(widget.flowData)));
      return;
    }

    _prepareOtpStep();
  }

  Future<void> _prepareOtpStep() async {
    final method = await sl<SecureStorageDatasource>().get2faMethod();
    if (!mounted) return;

    setState(() {
      _twoFaMethod = method ?? AppConstants.twoFaTotp;
      _busy = false;
      _step = _Step.otp;
      _otpCode = '';
      _hasError = false;
    });

    if (_twoFaMethod == AppConstants.twoFaSmtp) {
      context.read<OtpBloc>().add(OtpSendEmail());
      _startResendTimer();
    } else if (_twoFaMethod == AppConstants.twoFaNotif) {
      context.read<OtpBloc>().add(OtpSendFirebase());
      _startResendTimer();
    }
  }

  void _startResendTimer() {
    _countdown?.cancel();
    setState(() => _timer = AppConstants.otpResendSeconds);
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timer <= 0) {
        timer.cancel();
      } else {
        setState(() => _timer--);
      }
    });
  }

  void _resendOtp() {
    if (_twoFaMethod == AppConstants.twoFaSmtp) {
      context.read<OtpBloc>().add(OtpSendEmail());
    } else if (_twoFaMethod == AppConstants.twoFaNotif) {
      context.read<OtpBloc>().add(OtpSendFirebase());
    }
    _startResendTimer();
  }

  void _onOtpChanged(String value) {
    setState(() {
      _otpCode = value;
      _hasError = false;
    });
    if (value.length == AppConstants.otpLength) {
      _submitPayment(value);
    }
  }

  void _submitPayment(String code) {
    setState(() => _busy = true);
    context.read<PaymentBloc>().add(PaymentTransferRequested(
          amount: _amountFor(widget.flowData),
          description: _descriptionFor(widget.flowData),
          otpCode: code,
          otpType: _otpType,
        ));
  }

  void _handleClose() {
    if (_step == _Step.otp) {
      _countdown?.cancel();
      setState(() {
        _step = _Step.pin;
        _pin = '';
        _otpCode = '';
        _busy = false;
        _hasError = false;
      });
      return;
    }
    context.go('/home');
  }

  void _showInvalidOtp() {
    setState(() {
      _busy = false;
      _hasError = true;
      _otpCode = '';
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _hasError = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentBloc, PaymentState>(
          listener: _onPaymentState,
        ),
        BlocListener<OtpBloc, OtpState>(
          listener: _onOtpState,
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    _step == _Step.otp
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.close_rounded,
                    color: AppColors.ink,
                  ),
                  onPressed: _handleClose,
                ),
              ),
              if (_busy)
                const Expanded(child: _BusyView())
              else if (_step == _Step.pin)
                Expanded(
                  child: _PinStep(
                    pin: _pin,
                    hasError: _hasError,
                    onChanged: (value) => setState(() => _pin = value),
                    onComplete: _onPinComplete,
                  ),
                )
              else
                Expanded(
                  child: _OtpStep(
                    code: _otpCode,
                    method: _twoFaMethod,
                    timer: _timer,
                    hasError: _hasError,
                    onChanged: _onOtpChanged,
                    onResend: _timer <= 0 ? _resendOtp : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPaymentState(BuildContext context, PaymentState state) {
    if (state is PaymentTransferSuccess) {
      final result = state.result;
      context.go('/success', extra: {
        'title': _kind == AppConstants.txnTransfer
            ? 'Transfer berhasil'
            : 'Pembayaran berhasil',
        'subtitle': result.description,
        'amount': result.amount,
        'lines': [
          ['Jumlah', CurrencyFormatter.format(result.amount)],
          ['Saldo setelah', CurrencyFormatter.format(result.balanceAfter)],
          ['Ref', 'DKG${result.transactionId}'],
        ],
      });
    } else if (state is PaymentTopupSuccess) {
      context.go('/success', extra: {
        'title': 'Top up berhasil',
        'subtitle': 'Saldo kamu bertambah',
        'amount': state.amount,
        'lines': [
          ['Jumlah', CurrencyFormatter.format(state.amount)],
          ['Saldo sekarang', CurrencyFormatter.format(state.balance)],
        ],
      });
    } else if (state is PaymentInvalidOtp) {
      _showInvalidOtp();
    } else if (state is PaymentInsufficientBalance) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saldo tidak cukup. Saldo kamu saat ini ${CurrencyFormatter.format(state.balance)}.',
          ),
          backgroundColor: AppColors.red,
        ),
      );
    } else if (state is PaymentError) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
      );
    }
  }

  void _onOtpState(BuildContext context, OtpState state) {
    if (state is OtpError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
      );
    }
  }

  double _amountFor(Map<String, dynamic> flow) {
    return (flow['amount'] as num).toDouble();
  }

  String _descriptionFor(Map<String, dynamic> flow) {
    if (_kind == AppConstants.txnTransfer) {
      return flow['note'] as String? ?? 'Transfer';
    }
    return flow['description'] as String? ??
        flow['merchantName'] as String? ??
        'Pembayaran QRIS';
  }
}

class _BusyView extends StatelessWidget {
  const _BusyView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 18),
        Text(
          'Memproses transaksi...',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.slate600,
          ),
        ),
      ],
    );
  }
}

class _PinStep extends StatelessWidget {
  final String pin;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onComplete;

  const _PinStep({
    required this.pin,
    required this.hasError,
    required this.onChanged,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        children: [
          const _StepIcon(icon: Icons.lock_outline_rounded),
          const SizedBox(height: 16),
          const Text(
            'Masukkan PIN',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Masukkan 6 digit PIN keamanan kamu',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.slate500),
          ),
          const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            transform: hasError
                ? (Matrix4.identity()..translateByDouble(10.0, 0, 0, 1.0))
                : Matrix4.identity(),
            child: PinPad(
              value: pin,
              onChanged: onChanged,
              onComplete: onComplete,
            ),
          ),
          const SizedBox(height: 18),
          const Text.rich(
            TextSpan(
              text: 'Lupa PIN? ',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12.5,
                color: AppColors.slate400,
              ),
              children: [
                TextSpan(
                  text: 'Reset',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  final String code;
  final String method;
  final int timer;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback? onResend;

  const _OtpStep({
    required this.code,
    required this.method,
    required this.timer,
    required this.hasError,
    required this.onChanged,
    required this.onResend,
  });

  bool get _canResend {
    return method == AppConstants.twoFaSmtp ||
        method == AppConstants.twoFaNotif;
  }

  String get _title {
    return switch (method) {
      AppConstants.twoFaSmtp => 'Masukkan Email OTP',
      AppConstants.twoFaNotif => 'Masukkan OTP Notifikasi',
      _ => 'Masukkan Kode Authenticator',
    };
  }

  String get _subtitle {
    return switch (method) {
      AppConstants.twoFaSmtp => 'Kode 6 digit dikirim ke email kamu',
      AppConstants.twoFaNotif => 'Kode 6 digit dikirim lewat notifikasi',
      _ => 'Buka aplikasi authenticator dan masukkan kode 6 digit',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        children: [
          _StepIcon(
            icon: method == AppConstants.twoFaTotp
                ? Icons.security_rounded
                : Icons.mark_email_unread_outlined,
          ),
          const SizedBox(height: 16),
          Text(
            _title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.slate500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 30),
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            transform: hasError
                ? (Matrix4.identity()..translateByDouble(8.0, 0, 0, 1.0))
                : Matrix4.identity(),
            child: CodeInput(
              value: code,
              onChanged: onChanged,
              hasError: hasError,
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.redSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Kode OTP salah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _HintBanner(method: method),
          if (_canResend) ...[
            const SizedBox(height: 34),
            timer > 0
                ? Text(
                    'Kirim ulang dalam 00:${timer.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.slate400,
                    ),
                  )
                : TextButton.icon(
                    onPressed: onResend,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 17,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Kirim ulang kode',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  final String method;

  const _HintBanner({required this.method});

  @override
  Widget build(BuildContext context) {
    final text = switch (method) {
      AppConstants.twoFaSmtp => 'Cek email inbox atau spam kamu',
      AppConstants.twoFaNotif => 'Pastikan notifikasi perangkat aktif',
      _ => 'Kode authenticator berubah otomatis setiap beberapa detik',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.amberSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 17, color: Color(0xFFB5760B)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12.5,
                color: Color(0xFF8A5A06),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  final IconData icon;

  const _StepIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(icon, size: 26, color: AppColors.primary),
      ),
    );
  }
}
