import 'package:flutter_test/flutter_test.dart';
import 'package:pro_calculator/main.dart';

void main() {
  testWidgets('Calculator app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProCalculatorApp());
    expect(find.text('AC'), findsOneWidget);
    expect(find.text('='), findsOneWidget);
  });
}
