import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const String _key = 'calc_history_v1';
  static const int _maxItems = 100;

  static Future<List<HistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      return list.map((item) => HistoryItem.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addHistory(HistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      list.insert(0, item.toJson());
      if (list.length > _maxItems) {
        list.removeLast();
      }
      await prefs.setStringList(_key, list);
    } catch (_) {}
  }

  static Future<void> deleteItem(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
        await prefs.setStringList(_key, list);
      }
    } catch (_) {}
  }

  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
