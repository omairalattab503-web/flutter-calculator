import 'package:flutter_test/flutter_test.dart';
import 'package:pro_calculator/services/currency_service.dart';

void main() {
  group('CurrencyService - Identity Conversions', () {
    test('Identity conversion for USD returns exact amount and 1.0 rate', () {
      final result = CurrencyService.convert(
        rawAmount: '100',
        fromCode: 'USD',
        toCode: 'USD',
      );
      expect(result.isSuccess, isTrue);
      expect(result.amount, 100.0);
      expect(result.convertedAmount, 100.0);
      expect(result.exchangeRate, 1.0);
      expect(result.formattedResult, '100');
    });

    test('Identity conversion for SAR returns exact amount and 1.0 rate', () {
      final result = CurrencyService.convert(
        rawAmount: '375.50',
        fromCode: 'SAR',
        toCode: 'SAR',
      );
      expect(result.isSuccess, isTrue);
      expect(result.amount, 375.50);
      expect(result.convertedAmount, 375.50);
      expect(result.exchangeRate, 1.0);
    });

    test('Identity conversion for EUR returns exact amount and 1.0 rate', () {
      final result = CurrencyService.convert(
        rawAmount: '50',
        fromCode: 'EUR',
        toCode: 'EUR',
      );
      expect(result.isSuccess, isTrue);
      expect(result.amount, 50.0);
      expect(result.convertedAmount, 50.0);
      expect(result.exchangeRate, 1.0);
    });

    test('Identity conversion for YER returns exact amount and 1.0 rate', () {
      final result = CurrencyService.convert(
        rawAmount: '10000',
        fromCode: 'YER',
        toCode: 'YER',
      );
      expect(result.isSuccess, isTrue);
      expect(result.amount, 10000.0);
      expect(result.convertedAmount, 10000.0);
      expect(result.exchangeRate, 1.0);
    });
  });

  group('CurrencyService - Conversion Calculations', () {
    test('Converts USD to SAR correctly (1 USD = 3.75 SAR)', () {
      final result = CurrencyService.convert(
        rawAmount: '100',
        fromCode: 'USD',
        toCode: 'SAR',
      );
      expect(result.isSuccess, isTrue);
      expect(result.convertedAmount, 375.0);
      expect(result.exchangeRate, 3.75);
      expect(result.formattedResult, '375');
    });

    test('Converts SAR to USD correctly (3.75 SAR = 1 USD)', () {
      final result = CurrencyService.convert(
        rawAmount: '375',
        fromCode: 'SAR',
        toCode: 'USD',
      );
      expect(result.isSuccess, isTrue);
      expect(result.convertedAmount, closeTo(100.0, 0.001));
    });

    test('Converts USD to EUR correctly (1 USD = 0.92 EUR)', () {
      final result = CurrencyService.convert(
        rawAmount: '100',
        fromCode: 'USD',
        toCode: 'EUR',
      );
      expect(result.isSuccess, isTrue);
      expect(result.convertedAmount, 92.0);
      expect(result.exchangeRate, 0.92);
    });

    test('Converts USD to YER correctly (1 USD = 535.0 YER)', () {
      final result = CurrencyService.convert(
        rawAmount: '10',
        fromCode: 'USD',
        toCode: 'YER',
      );
      expect(result.isSuccess, isTrue);
      expect(result.convertedAmount, 5350.0);
      expect(result.exchangeRate, 535.0);
      expect(result.formattedResult, '5,350');
    });

    test('Cross conversion EUR to SAR correctly', () {
      // 100 EUR = (100 / 0.92) * 3.75 SAR = 407.60869...
      final result = CurrencyService.convert(
        rawAmount: '100',
        fromCode: 'EUR',
        toCode: 'SAR',
      );
      expect(result.isSuccess, isTrue);
      expect(result.convertedAmount, closeTo(407.61, 0.01));
    });

    test('Cross conversion SAR to YER correctly', () {
      // 100 SAR = (100 / 3.75) * 535 YER = 14266.666...
      final result = CurrencyService.convert(
        rawAmount: '100',
        fromCode: 'SAR',
        toCode: 'YER',
      );
      expect(result.isSuccess, isTrue);
      expect(result.convertedAmount, closeTo(14266.67, 0.01));
    });
  });

  group('CurrencyService - Input Validation', () {
    test('Fails on null input', () {
      final result = CurrencyService.validateAmount(null);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('يرجى إدخال المبلغ'));
    });

    test('Fails on empty input', () {
      final result = CurrencyService.validateAmount('');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('يرجى إدخال المبلغ'));
    });

    test('Fails on whitespace only input', () {
      final result = CurrencyService.validateAmount('   ');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('يرجى إدخال المبلغ'));
    });

    test('Fails on non-numeric input', () {
      final result = CurrencyService.validateAmount('abc');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('صيغة المبلغ غير صالحة'));
    });

    test('Fails on multiple decimal points', () {
      final result = CurrencyService.validateAmount('12.34.56');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('صيغة المبلغ غير صالحة'));
    });

    test('Fails on negative input', () {
      final result = CurrencyService.validateAmount('-50');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('سالبة'));
    });

    test('Fails on negative float input', () {
      final result = CurrencyService.validateAmount('-0.01');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('سالبة'));
    });

    test('convert method rejects negative amount and returns failure', () {
      final result = CurrencyService.convert(
        rawAmount: '-100',
        fromCode: 'USD',
        toCode: 'SAR',
      );
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('سالبة'));
      expect(result.convertedAmount, isNull);
    });

    test('convertDouble rejects NaN and Infinity', () {
      final nanResult = CurrencyService.convertDouble(
        amount: double.nan,
        fromCode: 'USD',
        toCode: 'SAR',
      );
      expect(nanResult.isSuccess, isFalse);
      expect(nanResult.errorMessage, contains('غير معرفة'));

      final infResult = CurrencyService.convertDouble(
        amount: double.infinity,
        fromCode: 'USD',
        toCode: 'SAR',
      );
      expect(infResult.isSuccess, isFalse);
    });

    test('Rejects unsupported currency code', () {
      final result = CurrencyService.convert(
        rawAmount: '100',
        fromCode: 'XYZ',
        toCode: 'USD',
      );
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('غير مدعومة'));
    });
  });

  group('CurrencyService - Demonstration Disclaimer & Metadata', () {
    test('Contains prominent demonstration disclaimer', () {
      expect(CurrencyService.rateDisclaimer, contains('تجريبية وتوضيحية'));
      expect(CurrencyService.rateDisclaimer, contains('Demonstration Rates'));
    });

    test('Supports all required currencies: USD, SAR, EUR, YER', () {
      final codes = CurrencyService.supportedCurrencies.map((c) => c.code).toList();
      expect(codes, containsAll(['USD', 'SAR', 'EUR', 'YER']));
      expect(codes.length, 4);
    });

    test('Formats zero properly', () {
      expect(CurrencyService.formatAmount(0.0), '0');
    });

    test('Formats thousands with commas', () {
      expect(CurrencyService.formatAmount(1500000.0), '1,500,000');
    });
  });
}
