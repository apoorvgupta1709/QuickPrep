import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_monetization_provider.dart';
import '../core/theme.dart';

class RazorpayManagerScreen extends StatefulWidget {
  const RazorpayManagerScreen({super.key});

  @override
  State<RazorpayManagerScreen> createState() => _RazorpayManagerScreenState();
}

class _RazorpayManagerScreenState extends State<RazorpayManagerScreen> {
  late TextEditingController _priceCtrl;
  late TextEditingController _keyCtrl;
  late TextEditingController _promoCtrl;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final config =
          Provider.of<AdminMonetizationProvider>(context, listen: false).config;
      _priceCtrl =
          TextEditingController(text: config.razorpayProPriceInr.toString());
      _keyCtrl = TextEditingController(text: config.razorpayKeyId);
      _promoCtrl = TextEditingController(text: config.promoBannerText);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _keyCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  void _save(AdminMonetizationProvider provider) async {
    final price = int.tryParse(_priceCtrl.text.trim()) ?? 199;
    await provider.updateRazorpayConfig(
      priceInr: price,
      keyId: _keyCtrl.text.trim(),
      promoText: _promoCtrl.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Razorpay Pro pricing & promo banner saved!'),
          backgroundColor: AdminTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monetization = Provider.of<AdminMonetizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Razorpay & Pro Pricing Manager'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Client Preview Card
              Text(
                'Live Client Paywall Preview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF9333EA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium,
                            color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'QuickPrep Pro (Lifetime)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '₹${_priceCtrl.text.isEmpty ? "199" : _priceCtrl.text}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _promoCtrl.text.isEmpty
                          ? '🚀 Special Launch Deal: Lifetime Pro at ₹199!'
                          : _promoCtrl.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• 100% Ad-Free forever\n• Unlimited PDF cheat sheet downloads\n• Unlimited Audio Commute Mode\n• Full access to all Company-Specific Question Packs',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Pricing & Promotion Parameters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Lifetime Pro Price in INR (₹)',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _promoCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Promotional Banner Copy',
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'e.g. Diwali Flash Sale: ₹149 Only!',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _keyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Razorpay Key ID',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _save(monetization),
                  icon: const Icon(Icons.check),
                  label: const Text('Update Pricing in Firestore'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
