import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../views/about_screen.dart';

class HistoryDrawer extends StatefulWidget {
  final AppThemeMode currentTheme;
  final Function(String expression, String result) onSelectHistoryItem;

  const HistoryDrawer({
    super.key,
    required this.currentTheme,
    required this.onSelectHistoryItem,
  });

  @override
  State<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends State<HistoryDrawer> {
  List<HistoryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAll() async {
    final colors = AppColors.of(widget.currentTheme);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'مسح السجل',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في مسح جميع العمليات الحسابية السابقة؟',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.actionBtnBg),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('مسح الكل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.clearHistory();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(widget.currentTheme);
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history_rounded, color: colors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'سجل العمليات',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_items.isNotEmpty)
                  TextButton.icon(
                    icon: Icon(Icons.delete_sweep_rounded, color: colors.actionBtnBg, size: 20),
                    label: Text(
                      'مسح',
                      style: TextStyle(color: colors.actionBtnBg, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _clearAll,
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: colors.accent))
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 64,
                              color: colors.textSecondary.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد عمليات سابقة',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        itemCount: _items.length,
                        separatorBuilder: (ctx, i) => Divider(
                          color: colors.background.withValues(alpha: 0.5),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Dismissible(
                            key: ValueKey(item.timestamp.toIso8601String() + index.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              color: Colors.redAccent,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) async {
                              await HistoryService.deleteItem(index);
                              setState(() {
                                _items.removeAt(index);
                              });
                            },
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                widget.onSelectHistoryItem(item.expression, item.result);
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${dateFormat.format(item.timestamp)} • ${timeFormat.format(item.timestamp)}',
                                          style: TextStyle(
                                            color: colors.textSecondary.withValues(alpha: 0.7),
                                            fontSize: 11,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.copy_rounded,
                                            size: 16,
                                            color: colors.textSecondary,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: item.result));
                                            HapticFeedback.lightImpact();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('تم نسخ: ${item.result}'),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                      item.expression,
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '= ${item.result}',
                                      style: TextStyle(
                                        color: colors.accent,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // About App option in history menu
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 4),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => AboutScreen(currentTheme: widget.currentTheme),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: colors.opBtnBg),
                      const SizedBox(width: 8),
                      Text(
                        'حول التطبيق',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
