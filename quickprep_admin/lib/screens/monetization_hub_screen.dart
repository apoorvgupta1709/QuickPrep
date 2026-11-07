import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_monetization_provider.dart';
import '../core/theme.dart';

class MonetizationHubScreen extends StatefulWidget {
  const MonetizationHubScreen({super.key});

  @override
  State<MonetizationHubScreen> createState() => _MonetizationHubScreenState();
}

class _MonetizationHubScreenState extends State<MonetizationHubScreen> {
  late TextEditingController _bannerCtrl;
  late TextEditingController _interstitialCtrl;
  late TextEditingController _rewardedCtrl;
  double _frequency = 3;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final config =
          Provider.of<AdminMonetizationProvider>(context, listen: false).config;
      _bannerCtrl = TextEditingController(text: config.bannerAdUnitId);
      _interstitialCtrl =
          TextEditingController(text: config.interstitialAdUnitId);
      _rewardedCtrl = TextEditingController(text: config.rewardedAdUnitId);
      _frequency = config.interstitialFrequencyCount.toDouble();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    _interstitialCtrl.dispose();
    _rewardedCtrl.dispose();
    super.dispose();
  }

  void _save(AdminMonetizationProvider provider) async {
    await provider.updateAdUnits(
      bannerId: _bannerCtrl.text.trim(),
      interstitialId: _interstitialCtrl.text.trim(),
      rewardedId: _rewardedCtrl.text.trim(),
      frequency: _frequency.toInt(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Monetization config updated and synced to Firestore!'),
          backgroundColor: AdminTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monetization = Provider.of<AdminMonetizationProvider>(context);
    final config = monetization.config;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Monetization Control (AdMob)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Master Kill-Switch Card
              Card(
                color: config.adsEnabled
                    ? AdminTheme.darkSurface
                    : AdminTheme.error.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: config.adsEnabled
                            ? AdminTheme.success.withAlpha(40)
                            : AdminTheme.error.withAlpha(40),
                        child: Icon(
                          config.adsEnabled
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_rounded,
                          color: config.adsEnabled
                              ? AdminTheme.success
                              : AdminTheme.error,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              config.adsEnabled
                                  ? 'AdMob Engine Active'
                                  : 'KILL-SWITCH ENGAGED (Ads Paused)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: config.adsEnabled
                                    ? Colors.white
                                    : AdminTheme.error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              config.adsEnabled
                                  ? 'Ads are serving normally in client apps based on frequency rules.'
                                  : 'All banner, interstitial, and rewarded ad calls are suppressed app-wide.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AdminTheme.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: config.adsEnabled,
                        activeThumbColor: AdminTheme.success,
                        onChanged: (val) => monetization.toggleAds(val),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Dynamic Ad Unit IDs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Update ad unit IDs on the fly without republishing an update to the app store.',
                style: TextStyle(fontSize: 12.5, color: AdminTheme.darkTextSecondary),
              ),
              const SizedBox(height: 14),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _bannerCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Banner Ad Unit ID',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.view_stream),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _interstitialCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Interstitial Ad Unit ID',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.fullscreen),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _rewardedCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Rewarded Video Ad Unit ID',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.card_giftcard),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Interstitial Frequency Capping',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Show Interstitial Ad After Every:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_frequency.toInt()} Actions / Quizzes',
                            style: const TextStyle(
                              color: AdminTheme.primaryLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _frequency,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '${_frequency.toInt()}',
                        onChanged: (val) => setState(() => _frequency = val),
                      ),
                      Text(
                        'A higher frequency (e.g. 5) prevents user fatigue while maintaining strong eCPM yield.',
                        style: TextStyle(fontSize: 12, color: AdminTheme.darkTextSecondary),
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
                  icon: const Icon(Icons.save),
                  label: const Text('Save & Broadcast Monetization Config'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
