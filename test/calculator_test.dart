import 'package:flutter_test/flutter_test.dart';
import 'package:pro_calculator/services/calculator_engine.dart';

void main() {
  group('CalculatorEngine Tests', () {
    test('Basic arithmetic precedence', () {
      expect(CalculatorEngine.evaluate('2 + 3 × 4'), '14');
      expect(CalculatorEngine.evaluate('(2 + 3) × 4'), '20');
      expect(CalculatorEngine.evaluate('100 ÷ 4'), '25');
    });

    test('Factorial and square root', () {
      expect(CalculatorEngine.evaluate('5!'), '120');
      expect(CalculatorEngine.evaluate('√16'), '4');
      expect(CalculatorEngine.evaluate('√25 + 5!'), '125');
    });

    test('Trigonometry in DEG mode', () {
      expect(CalculatorEngine.evaluate('sin(30)'), '0.5');
      expect(CalculatorEngine.evaluate('cos(60)'), '0.5');
      expect(CalculatorEngine.evaluate('tan(45)'), '1');
    });

    test('Percentage', () {
      expect(CalculatorEngine.evaluate('200 × 15%'), '30');
    });

    test('Division by zero', () {
      expect(CalculatorEngine.evaluate('5 ÷ 0'), 'لا يمكن القسمة على صفر');
    });

    test('Number formatting with commas', () {
      expect(CalculatorEngine.evaluate('1000 × 1000'), '1,000,000');
    });

    test('Preview evaluation', () {
      expect(CalculatorEngine.evaluatePreview('50 + 25'), '75');
      expect(CalculatorEngine.evaluatePreview('50 +'), isNull);
    });
  });
}
