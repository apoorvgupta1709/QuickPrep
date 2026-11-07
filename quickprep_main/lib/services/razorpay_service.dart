import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_gamification_provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final UserGamificationProvider _gamificationProvider;
  final BuildContext _context;

  RazorpayService(this._context, this._gamificationProvider) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required int amountInr,
    required String razorpayKeyId,
    String? prefillEmail,
    String? prefillPhone,
  }) {
    // If running in development / testing on desktop/web or emulator without Razorpay native support:
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _showDevCheckoutDialog(amountInr);
      return;
    }

    final options = {
      'key': razorpayKeyId.isNotEmpty && razorpayKeyId != 'rzp_test_placeholder'
          ? razorpayKeyId
          : 'rzp_test_5678abcdef',
      'amount': amountInr * 100, // in paise
      'name': AppConstants.appName,
      'description': 'Pro Lifetime License (100% Ad-Free & Unlimited PDFs)',
      'prefill': {
        'contact': prefillPhone ?? '9876543210',
        'email': prefillEmail ?? 'student@quickprep.app',
      },
      'theme': {
        'color': '#6366F1',
      },
      'external': {
        'wallets': ['paytm', 'phonepe', 'gpay'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay checkout open notice: $e');
      _showDevCheckoutDialog(amountInr);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId ?? 'pay_${DateTime.now().millisecondsSinceEpoch}';
    await _recordProEntitlement(paymentId);

    if (_context.mounted) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(
          content: Text('🎉 Payment Successful! Welcome to QuickPrep Pro (Ref: $paymentId)'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_context.mounted) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(
          content: Text('Payment cancelled or failed: ${response.message ?? "Code ${response.code}"}'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_context.mounted) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(
          content: Text('External wallet chosen: ${response.walletName}'),
        ),
      );
    }
  }

  Future<void> _recordProEntitlement(String paymentId) async {
    _gamificationProvider.setProStatus(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quickprep_pro_payment_id', paymentId);
    await prefs.setString('quickprep_pro_purchased_at', DateTime.now().toIso8601String());
  }

  static Future<bool> restorePurchases(UserGamificationProvider gamification) async {
    final prefs = await SharedPreferences.getInstance();
    final paymentId = prefs.getString('quickprep_pro_payment_id');
    if (paymentId != null && paymentId.isNotEmpty) {
      gamification.setProStatus(true);
      return true;
    }
    return false;
  }

  void _showDevCheckoutDialog(int amount) {
    showDialog(
      context: _context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('QuickPrep Pro Checkout'),
          ],
        ),
        content: Text(
          'Simulate Razorpay checkout of ₹$amount for QuickPrep Pro Lifetime License.\n\nAll ads will be permanently suppressed, and unlimited cheat sheets unlocked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handlePaymentSuccess(
                PaymentSuccessResponse(
                  'pay_simulated_${DateTime.now().millisecondsSinceEpoch}',
                  'order_simulated_1',
                  'sig_simulated_1',
                  null,
                ),
              );
            },
            child: Text('Confirm Pay ₹$amount'),
          ),
        ],
      ),
    );
  }

  void dispose() {
    _razorpay.clear();
  }
}
