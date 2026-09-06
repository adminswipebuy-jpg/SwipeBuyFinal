import 'package:flutter/material.dart';

/// V13.12 foundation. Persist and enforce these preferences on trusted backend
/// services when they affect payments, pricing, legal text or regional policy.
class LocalizationPreferences {
  final Locale locale;
  final String countryCode;
  final String currencyCode;
  final bool use24HourTime;
  final bool metricUnits;

  const LocalizationPreferences({
    required this.locale,
    required this.countryCode,
    required this.currencyCode,
    this.use24HourTime = false,
    this.metricUnits = true,
  });

  LocalizationPreferences copyWith({
    Locale? locale,
    String? countryCode,
    String? currencyCode,
    bool? use24HourTime,
    bool? metricUnits,
  }) => LocalizationPreferences(
        locale: locale ?? this.locale,
        countryCode: countryCode ?? this.countryCode,
        currencyCode: currencyCode ?? this.currencyCode,
        use24HourTime: use24HourTime ?? this.use24HourTime,
        metricUnits: metricUnits ?? this.metricUnits,
      );
}

class LocalizationService extends ChangeNotifier {
  LocalizationPreferences _preferences = const LocalizationPreferences(
    locale: Locale('en'),
    countryCode: 'GH',
    currencyCode: 'GHS',
  );

  LocalizationPreferences get preferences => _preferences;

  Future<void> updatePreferences(LocalizationPreferences next) async {
    // TODO: sync authenticated user preferences with backend.
    // Do not infer legal eligibility or FX conversion solely on-device.
    _preferences = next;
    notifyListeners();
  }

  String formatCurrency(num value) {
    final symbols = {'GHS': 'GH₵', 'USD': r'$', 'EUR': '€', 'GBP': '£'};
    final symbol = symbols[_preferences.currencyCode] ?? '${_preferences.currencyCode} ';
    return '$symbol${value.toStringAsFixed(2)}';
  }
}
