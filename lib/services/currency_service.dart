import 'package:intl/intl.dart';

/// Data class representing a supported Currency
class Currency {
  final String code;
  final String nameAr;
  final String nameEn;
  final String symbol;
  final String flagEmoji;
  final double rateToUsd; // Demonstration rate relative to USD

  const Currency({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.symbol,
    required this.flagEmoji,
    required this.rateToUsd,
  });
}

/// Validation result for currency input amounts
class CurrencyValidationResult {
  final bool isValid;
  final double? parsedAmount;
  final String? errorMessage;

  const CurrencyValidationResult.valid(this.parsedAmount)
      : isValid = true,
        errorMessage = null;

  const CurrencyValidationResult.invalid(this.errorMessage)
      : isValid = false,
        parsedAmount = null;
}

/// Result returned from a currency conversion operation
class CurrencyConversionResult {
  final bool isSuccess;
  final double? amount;
  final double? convertedAmount;
  final String? formattedResult;
  final double? exchangeRate;
  final String? errorMessage;
  final String disclaimer;

  const CurrencyConversionResult.success({
    required this.amount,
    required this.convertedAmount,
    required this.formattedResult,
    required this.exchangeRate,
    this.disclaimer = CurrencyService.rateDisclaimer,
  })  : isSuccess = true,
        errorMessage = null;

  const CurrencyConversionResult.failure(
    this.errorMessage, {
    this.disclaimer = CurrencyService.rateDisclaimer,
  })  : isSuccess = false,
        amount = null,
        convertedAmount = null,
        formattedResult = null,
        exchangeRate = null;
}

/// Dedicated business logic service for currency conversion
class CurrencyService {
  /// Prominent disclaimer clearly stating that all rates are for demonstration only
  static const String rateDisclaimer =
      'أسعار الصرف المعروضة هي أسعار تجريبية وتوضيحية (Demonstration Rates) وليست أسعاراً حية أو فورية في السوق.';

  static const String rateDisclaimerEn =
      'Rates shown are for demonstration purposes only and do not represent live market rates.';

  /// Supported currencies: USD, SAR, EUR, YER
  /// Demonstration exchange rates relative to 1 USD base
  static const List<Currency> supportedCurrencies = [
    Currency(
      code: 'USD',
      nameAr: 'دولار أمريكي',
      nameEn: 'US Dollar',
      symbol: '\$',
      flagEmoji: '🇺🇸',
      rateToUsd: 1.0,
    ),
    Currency(
      code: 'SAR',
      nameAr: 'ريال سعودي',
      nameEn: 'Saudi Riyal',
      symbol: 'ر.س',
      flagEmoji: '🇸🇦',
      rateToUsd: 3.75,
    ),
    Currency(
      code: 'EUR',
      nameAr: 'يورو',
      nameEn: 'Euro',
      symbol: '€',
      flagEmoji: '🇪🇺',
      rateToUsd: 0.92,
    ),
    Currency(
      code: 'YER',
      nameAr: 'ريال يمني',
      nameEn: 'Yemeni Rial',
      symbol: 'ر.ي',
      flagEmoji: '🇾🇪',
      rateToUsd: 535.0,
    ),
  ];

  /// Finds a supported currency by its 3-letter code (case-insensitive)
  static Currency? findCurrency(String code) {
    final upper = code.trim().toUpperCase();
    try {
      return supportedCurrencies.firstWhere((c) => c.code == upper);
    } catch (_) {
      return null;
    }
  }

  /// Calculates the demonstration exchange rate from [fromCode] to [toCode].
  /// Throws ArgumentError if an unsupported currency code is supplied.
  static double getExchangeRate(String fromCode, String toCode) {
    final fromCurrency = findCurrency(fromCode);
    final toCurrency = findCurrency(toCode);

    if (fromCurrency == null) {
      throw ArgumentError('العملة المصدر ($fromCode) غير مدعومة');
    }
    if (toCurrency == null) {
      throw ArgumentError('العملة الهدف ($toCode) غير مدعومة');
    }

    // Identity conversion
    if (fromCurrency.code == toCurrency.code) {
      return 1.0;
    }

    // Rate: (toRate / fromRate)
    return toCurrency.rateToUsd / fromCurrency.rateToUsd;
  }

  /// Validates the raw user input amount string.
  /// Handles empty, non-numeric, negative, and non-finite numbers.
  static CurrencyValidationResult validateAmount(String? rawAmount) {
    if (rawAmount == null) {
      return const CurrencyValidationResult.invalid('يرجى إدخال المبلغ');
    }

    final trimmed = rawAmount.trim();
    if (trimmed.isEmpty) {
      return const CurrencyValidationResult.invalid('يرجى إدخال المبلغ');
    }

    // Remove grouping commas if present
    final sanitized = trimmed.replaceAll(',', '');

    // Check for negative signs
    if (sanitized.startsWith('-') || sanitized.contains('-')) {
      return const CurrencyValidationResult.invalid('لا يمكن إدخال مبالغ سالبة');
    }

    final parsed = double.tryParse(sanitized);
    if (parsed == null) {
      return const CurrencyValidationResult.invalid('صيغة المبلغ غير صالحة');
    }

    if (parsed.isNaN || parsed.isInfinite) {
      return const CurrencyValidationResult.invalid('قيمة المبلغ غير معرفة');
    }

    if (parsed < 0) {
      return const CurrencyValidationResult.invalid('لا يمكن إدخال مبالغ سالبة');
    }

    return CurrencyValidationResult.valid(parsed);
  }

  /// Converts a numeric amount between two currencies.
  static CurrencyConversionResult convertDouble({
    required double amount,
    required String fromCode,
    required String toCode,
  }) {
    if (amount.isNaN || amount.isInfinite) {
      return const CurrencyConversionResult.failure('قيمة المبلغ غير معرفة');
    }
    if (amount < 0) {
      return const CurrencyConversionResult.failure('لا يمكن إدخال مبالغ سالبة');
    }

    final fromCurrency = findCurrency(fromCode);
    final toCurrency = findCurrency(toCode);

    if (fromCurrency == null) {
      return CurrencyConversionResult.failure('العملة المصدر ($fromCode) غير مدعومة');
    }
    if (toCurrency == null) {
      return CurrencyConversionResult.failure('العملة الهدف ($toCode) غير مدعومة');
    }

    // Identity conversion
    if (fromCurrency.code == toCurrency.code) {
      return CurrencyConversionResult.success(
        amount: amount,
        convertedAmount: amount,
        formattedResult: formatAmount(amount),
        exchangeRate: 1.0,
      );
    }

    final rate = toCurrency.rateToUsd / fromCurrency.rateToUsd;
    final converted = amount * rate;

    return CurrencyConversionResult.success(
      amount: amount,
      convertedAmount: converted,
      formattedResult: formatAmount(converted),
      exchangeRate: rate,
    );
  }

  /// Converts an amount string with full validation and formatted response.
  static CurrencyConversionResult convert({
    required String rawAmount,
    required String fromCode,
    required String toCode,
  }) {
    final validation = validateAmount(rawAmount);
    if (!validation.isValid) {
      return CurrencyConversionResult.failure(validation.errorMessage);
    }

    return convertDouble(
      amount: validation.parsedAmount!,
      fromCode: fromCode,
      toCode: toCode,
    );
  }

  /// Formats currency amounts with commas and clean decimal precision.
  static String formatAmount(double value) {
    if (value.isNaN || value.isInfinite) return '0';

    // Integer-like values or very large values
    final absVal = value.abs();
    final formatter = NumberFormat('#,##0.00', 'en_US');

    if (absVal >= 1000) {
      // 2 decimal places with commas
      final formatted = formatter.format(value);
      // Clean trailing .00 if clean integer
      if (formatted.endsWith('.00')) {
        return formatted.substring(0, formatted.length - 3);
      }
      return formatted;
    }

    if (absVal == 0) return '0';

    if (absVal < 0.01) {
      // For very small fractions, show up to 4 decimal places
      return NumberFormat('#,##0.0000', 'en_US').format(value);
    }

    final formatted = formatter.format(value);
    if (formatted.endsWith('.00')) {
      return formatted.substring(0, formatted.length - 3);
    }
    return formatted;
  }
}
