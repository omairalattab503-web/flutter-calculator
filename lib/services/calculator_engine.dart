import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

enum AngleMode { degree, radian }

class CalculatorEngine {
  static final ShuntingYardParser _parser = ShuntingYardParser();
  static final RealEvaluator _evaluator = RealEvaluator();

  /// Evaluates the expression string. Returns formatted result or throws an error.
  static String evaluate(String rawExpression, {AngleMode angleMode = AngleMode.degree}) {
    if (rawExpression.trim().isEmpty) return '0';

    final sanitized = _prepareExpression(rawExpression, angleMode: angleMode);
    if (sanitized.isEmpty) return '0';

    try {
      final exp = _parser.parse(sanitized);
      final double result = _evaluator.evaluate(exp).toDouble();

      if (result.isNaN) {
        return 'غير محدد';
      }
      if (result.isInfinite) {
        return 'لا يمكن القسمة على صفر';
      }

      return formatNumber(result);
    } catch (e) {
      throw Exception('خطأ في التعبير');
    }
  }

  /// Evaluates live preview without throwing. Returns null if invalid or incomplete.
  static String? evaluatePreview(String rawExpression, {AngleMode angleMode = AngleMode.degree}) {
    if (rawExpression.trim().isEmpty) return null;

    final trimmed = rawExpression.trim();
    final lastChar = trimmed[trimmed.length - 1];
    // If ends in an operator or opening bracket, do not preview
    if ('+-×÷/*^('.contains(lastChar)) {
      return null;
    }

    try {
      final sanitized = _prepareExpression(trimmed, angleMode: angleMode);
      final exp = _parser.parse(sanitized);
      final double result = _evaluator.evaluate(exp).toDouble();

      if (result.isNaN || result.isInfinite) {
        return null;
      }
      return formatNumber(result);
    } catch (_) {
      return null;
    }
  }

  /// Sanitizes and converts visual display characters into parseable math strings
  static String _prepareExpression(String expr, {required AngleMode angleMode}) {
    String s = expr;

    // Normalize multiplication and division symbols
    s = s.replaceAll('×', '*');
    s = s.replaceAll('÷', '/');
    s = s.replaceAll('−', '-');

    // Square root symbol √
    // Handle √(x) or √x -> sqrt(x)
    s = s.replaceAllMapped(RegExp(r'√(\d+(\.\d+)?)'), (m) => 'sqrt(${m[1]})');
    s = s.replaceAll('√', 'sqrt');

    // Constants
    s = s.replaceAll('π', '(${math.pi})');
    s = s.replaceAll('e', '(${math.e})');

    // Factorials: e.g., 5! -> factorial value
    s = _processFactorials(s);

    // Percentage: replace n% with (n * 0.01)
    s = s.replaceAllMapped(RegExp(r'(\d+(\.\d+)?)%'), (m) => '(${m[1]}*0.01)');

    // Logarithms
    // ln(x) -> ln(x) which math_expressions supports as ln
    // log(x) -> (ln(x)/ln(10)) base 10 log
    s = s.replaceAllMapped(RegExp(r'log\(([^)]+)\)'), (m) => '(ln(${m[1]})/ln(10))');

    // Trigonometric functions DEG mode conversion
    if (angleMode == AngleMode.degree) {
      const degToRad = '(${math.pi}/180)';
      const radToDeg = '(180/${math.pi})';

      // Inverse trig: asin, acos, atan output radians, convert to degrees
      s = s.replaceAllMapped(RegExp(r'asin\(([^)]+)\)'), (m) => '(asin(${m[1]})*$radToDeg)');
      s = s.replaceAllMapped(RegExp(r'acos\(([^)]+)\)'), (m) => '(acos(${m[1]})*$radToDeg)');
      s = s.replaceAllMapped(RegExp(r'atan\(([^)]+)\)'), (m) => '(atan(${m[1]})*$radToDeg)');

      // Direct trig: sin, cos, tan input degrees, convert to radians
      s = s.replaceAllMapped(RegExp(r'(?<!a)sin\(([^)]+)\)'), (m) => 'sin((${m[1]})*$degToRad)');
      s = s.replaceAllMapped(RegExp(r'(?<!a)cos\(([^)]+)\)'), (m) => 'cos((${m[1]})*$degToRad)');
      s = s.replaceAllMapped(RegExp(r'(?<!a)tan\(([^)]+)\)'), (m) => 'tan((${m[1]})*$degToRad)');
    }

    // Auto-close missing parentheses
    int openCount = 0;
    int closeCount = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') openCount++;
      if (s[i] == ')') closeCount++;
    }
    while (openCount > closeCount) {
      s += ')';
      closeCount++;
    }

    return s;
  }

  /// Factorial calculation
  static String _processFactorials(String expr) {
    return expr.replaceAllMapped(RegExp(r'(\d+)!'), (m) {
      final n = int.tryParse(m[1] ?? '');
      if (n == null || n < 0 || n > 20) return m[0]!;
      double fact = 1;
      for (int i = 2; i <= n; i++) {
        fact *= i;
      }
      return fact.toStringAsFixed(0);
    });
  }

  /// Cleanly formats a double value with thousands separators or scientific notation
  static String formatNumber(double value) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value.isNegative ? '-∞' : '∞';

    // Round small floating point inaccuracies (e.g. 0.00000000000000004 -> 0)
    if (value.abs() < 1e-12) {
      value = 0.0;
    }

    // Very large or very tiny non-zero numbers -> scientific notation
    if (value != 0 && (value.abs() >= 1e12 || value.abs() < 1e-6)) {
      return value.toStringAsExponential(6).replaceAll(RegExp(r'0+e'), 'e');
    }

    // Round to 10 decimal digits to eliminate floating noise
    double rounded = double.parse(value.toStringAsPrecision(12));
    if (rounded == rounded.roundToDouble()) {
      final formatter = NumberFormat('#,###', 'en_US');
      return formatter.format(rounded.toInt());
    } else {
      String s = rounded.toString();
      if (s.contains('.')) {
        s = s.replaceAll(RegExp(r'0+$'), '');
        s = s.replaceAll(RegExp(r'\.$'), '');
      }
      final parts = s.split('.');
      final intPart = int.tryParse(parts[0]);
      final formattedInt = intPart != null ? NumberFormat('#,###', 'en_US').format(intPart) : parts[0];
      return parts.length > 1 ? '$formattedInt.${parts[1]}' : formattedInt;
    }
  }
}
