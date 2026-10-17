import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/calculator_engine.dart';
import '../theme/app_theme.dart';

class DisplayScreen extends StatelessWidget {
  final String expression;
  final String? previewResult;
  final AngleMode angleMode;
  final VoidCallback onToggleAngleMode;
  final VoidCallback onOpenHistory;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenCurrencyConverter;
  final VoidCallback onOpenAbout;
  final AppThemeMode currentTheme;
  final ScrollController scrollController;

  const DisplayScreen({
    super.key,
    required this.expression,
    this.previewResult,
    required this.angleMode,
    required this.onToggleAngleMode,
    required this.onOpenHistory,
    required this.onToggleTheme,
    required this.onOpenCurrencyConverter,
    required this.onOpenAbout,
    required this.currentTheme,
    required this.scrollController,
  });

  void _copyToClipboard(BuildContext context, String text) {
    if (text.isEmpty || text == '0') return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('تم نسخ "$text" إلى الحافظة'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(currentTheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colors.displayBg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Angle Mode Badge (DEG / RAD)
              InkWell(
                onTap: onToggleAngleMode,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.rotate_right_rounded,
                        size: 16,
                        color: colors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        angleMode == AngleMode.degree ? 'DEG' : 'RAD',
                        style: TextStyle(
                          color: colors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons (History, Theme)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.history_rounded, color: colors.textSecondary),
                    tooltip: 'سجل العمليات',
                    onPressed: onOpenHistory,
                  ),
                  IconButton(
                    icon: Icon(
                      currentTheme == AppThemeMode.modernLight
                          ? Icons.light_mode_rounded
                          : (currentTheme == AppThemeMode.oledBlack
                              ? Icons.contrast_rounded
                              : Icons.dark_mode_rounded),
                      color: colors.textSecondary,
                    ),
                    tooltip: 'تغيير المظهر',
                    onPressed: onToggleTheme,
                  ),
                  IconButton(
                    icon: Icon(Icons.currency_exchange_rounded, color: colors.opBtnBg),
                    tooltip: 'محول العملات',
                    onPressed: onOpenCurrencyConverter,
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline_rounded, color: colors.textSecondary),
                    tooltip: 'حول التطبيق',
                    onPressed: onOpenAbout,
                  ),
                ],
              ),
            ],
          ),

          // Middle & Bottom Display Area (safely expands and scales to any height)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxH = constraints.maxHeight;
                final double exprFontSize = (maxH * 0.42).clamp(18.0, 44.0);
                final double previewFontSize = (maxH * 0.26).clamp(14.0, 24.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        reverse: true, // auto scroll to end
                        child: GestureDetector(
                          onLongPress: () => _copyToClipboard(context, expression),
                          child: Text(
                            expression.isEmpty ? '0' : expression,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: exprFontSize,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (previewResult != null && maxH > 50) ...[
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context, previewResult!),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '= ',
                                style: TextStyle(
                                  color: colors.accent,
                                  fontSize: previewFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                previewResult!,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: previewFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
