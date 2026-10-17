import 'dart:convert';

class HistoryItem {
  final String expression;
  final String result;
  final DateTime timestamp;

  const HistoryItem({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      expression: map['expression'] as String? ?? '',
      result: map['result'] as String? ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory HistoryItem.fromJson(String source) =>
      HistoryItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
