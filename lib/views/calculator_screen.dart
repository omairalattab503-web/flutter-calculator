import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';
import '../services/calculator_engine.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/calc_button.dart';
import '../widgets/display_screen.dart';
import '../widgets/history_drawer.dart';
import '../widgets/scientific_keypad.dart';
import '../widgets/unit_converter_view.dart';
import 'about_screen.dart';

enum CalculatorMode { standard, scientific, converter }

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String? _previewResult;
  AngleMode _angleMode = AngleMode.degree;
  AppThemeMode _currentTheme = AppThemeMode.cyberDark;
  CalculatorMode _currentMode = CalculatorMode.standard;
  final ScrollController _scrollController = ScrollController();
  bool _justCalculated = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('app_theme_mode');
      final angleIndex = prefs.getInt('angle_mode');
      if (themeIndex != null && themeIndex < AppThemeMode.values.length) {
        setState(() => _currentTheme = AppThemeMode.values[themeIndex]);
      }
      if (angleIndex != null && angleIndex < AngleMode.values.length) {
        setState(() => _angleMode = AngleMode.values[angleIndex]);
      }
    } catch (_) {}
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('app_theme_mode', _currentTheme.index);
      await prefs.setInt('angle_mode', _angleMode.index);
    } catch (_) {}
  }

  void _updatePreview() {
    if (_expression.isEmpty) {
      _previewResult = null;
    } else {
      _previewResult = CalculatorEngine.evaluatePreview(_expression, angleMode: _angleMode);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _appendNumber(String num) {
    setState(() {
      if (_justCalculated) {
        _expression = num;
        _justCalculated = false;
      } else {
        if (_expression == '0') {
          _expression = num;
        } else {
          _expression += num;
        }
      }
      _updatePreview();
    });
    _scrollToEnd();
  }

  void _appendOperator(String op) {
    setState(() {
      _justCalculated = false;
      if (_expression.isEmpty) {
        if (op == '-') {
          _expression = '-';
        }
        return;
      }

      final lastChar = _expression[_expression.length - 1];
      if ('+-×÷/*^'.contains(lastChar)) {
        _expression = _expression.substring(0, _expression.length - 1) + op;
      } else {
        _expression += op;
      }
      _updatePreview();
    });
    _scrollToEnd();
  }

  void _appendDot() {
    setState(() {
      if (_justCalculated) {
        _expression = '0.';
        _justCalculated = false;
        _updatePreview();
        return;
      }
      if (_expression.isEmpty) {
        _expression = '0.';
        _updatePreview();
        return;
      }

      // Check if current number already has a dot
      final lastOpIdx = _expression.lastIndexOf(RegExp(r'[\+\-×÷\/\*\^\(\)]'));
      final currentNum = lastOpIdx == -1 ? _expression : _expression.substring(lastOpIdx + 1);

      if (!currentNum.contains('.')) {
        _expression += '.';
      }
      _updatePreview();
    });
    _scrollToEnd();
  }

  void _appendFunction(String func) {
    setState(() {
      if (_justCalculated) {
        _expression = func;
        _justCalculated = false;
      } else {
        _expression += func;
      }
      _updatePreview();
    });
    _scrollToEnd();
  }

  void _toggleSign() {
    if (_expression.isEmpty) return;
    setState(() {
      final lastOpIdx = _expression.lastIndexOf(RegExp(r'[\+\-×÷\/\*\^]'));
      if (lastOpIdx == -1) {
        if (_expression.startsWith('-')) {
          _expression = _expression.substring(1);
        } else {
          _expression = '-$_expression';
        }
      } else {
        // Toggle sign on trailing token
        final before = _expression.substring(0, lastOpIdx + 1);
        final after = _expression.substring(lastOpIdx + 1);
        if (after.startsWith('-')) {
          _expression = before + after.substring(1);
        } else {
          _expression = '$before(-$after)';
        }
      }
      _updatePreview();
    });
    _scrollToEnd();
  }

  void _appendPercent() {
    if (_expression.isEmpty) return;
    final last = _expression[_expression.length - 1];
    if ('0123456789)'.contains(last)) {
      setState(() {
        _expression += '%';
        _updatePreview();
      });
      _scrollToEnd();
    }
  }

  void _backspace() {
    setState(() {
      _justCalculated = false;
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      _updatePreview();
    });
  }

  void _clearAll() {
    setState(() {
      _expression = '';
      _previewResult = null;
      _justCalculated = false;
    });
  }

  Future<void> _calculate() async {
    if (_expression.isEmpty) return;

    try {
      final result = CalculatorEngine.evaluate(_expression, angleMode: _angleMode);

      // Save to history if it's a real calculation
      if (result != 'خطأ في التعبير') {
        final item = HistoryItem(
          expression: _expression,
          result: result,
          timestamp: DateTime.now(),
        );
        await HistoryService.addHistory(item);
      }

      if (!mounted) return;
      setState(() {
        _expression = result;
        _previewResult = null;
        _justCalculated = true;
      });
      HapticFeedback.mediumImpact();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('صيغة المعادلة غير صحيحة'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _toggleAngleMode() {
    setState(() {
      _angleMode = _angleMode == AngleMode.degree ? AngleMode.radian : AngleMode.degree;
      _updatePreview();
    });
    _savePreferences();
  }

  void _toggleTheme() {
    setState(() {
      int next = (_currentTheme.index + 1) % AppThemeMode.values.length;
      _currentTheme = AppThemeMode.values[next];
    });
    _savePreferences();
  }

  void _openHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HistoryDrawer(
        currentTheme: _currentTheme,
        onSelectHistoryItem: (expr, res) {
          setState(() {
            _expression = res;
            _justCalculated = true;
            _updatePreview();
          });
        },
      ),
    );
  }

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AboutScreen(currentTheme: _currentTheme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(_currentTheme);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Mode selector bar
            _buildModeBar(colors),

            // If Unit Converter Mode is selected
            if (_currentMode == CalculatorMode.converter)
              Expanded(
                child: UnitConverterView(currentTheme: _currentTheme),
              )
            else ...[
              // Calculator Display (Flexible height)
              Expanded(
                flex: 4,
                child: DisplayScreen(
                  expression: _expression,
                  previewResult: _previewResult,
                  angleMode: _angleMode,
                  onToggleAngleMode: _toggleAngleMode,
                  onOpenHistory: _openHistory,
                  onToggleTheme: _toggleTheme,
                  onOpenAbout: _openAbout,
                  currentTheme: _currentTheme,
                  scrollController: _scrollController,
                ),
              ),

              // Scientific Keypad (if Scientific Mode or Wide Screen)
              if (_currentMode == CalculatorMode.scientific || isWide)
                ScientificKeypad(
                  currentTheme: _currentTheme,
                  onInsertFunction: _appendFunction,
                  onFactorial: () => _appendFunction('!'),
                  onSquare: () => _appendFunction('^2'),
                  onPower: () => _appendFunction('^'),
                  onSqrt: () => _appendFunction('√('),
                ),

              // Standard Keypad (Flexible height)
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Column(
                    children: [
                      // Row 1: AC, +/-, %, ÷
                      Expanded(
                        child: Row(
                          children: [
                            CalcButton(
                              label: 'AC',
                              onTap: _clearAll,
                              backgroundColor: colors.actionBtnBg,
                              textColor: colors.actionBtnText,
                            ),
                            CalcButton(
                              label: '+/−',
                              onTap: _toggleSign,
                              backgroundColor: colors.surface,
                              textColor: colors.textPrimary,
                            ),
                            CalcButton(
                              label: '%',
                              onTap: _appendPercent,
                              backgroundColor: colors.surface,
                              textColor: colors.textPrimary,
                            ),
                            CalcButton(
                              label: '÷',
                              onTap: () => _appendOperator('÷'),
                              backgroundColor: colors.opBtnBg,
                              textColor: colors.opBtnText,
                              fontSize: 28,
                            ),
                          ],
                        ),
                      ),

                      // Row 2: 7, 8, 9, ×
                      Expanded(
                        child: Row(
                          children: [
                            CalcButton(
                              label: '7',
                              onTap: () => _appendNumber('7'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '8',
                              onTap: () => _appendNumber('8'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '9',
                              onTap: () => _appendNumber('9'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '×',
                              onTap: () => _appendOperator('×'),
                              backgroundColor: colors.opBtnBg,
                              textColor: colors.opBtnText,
                              fontSize: 28,
                            ),
                          ],
                        ),
                      ),

                      // Row 3: 4, 5, 6, -
                      Expanded(
                        child: Row(
                          children: [
                            CalcButton(
                              label: '4',
                              onTap: () => _appendNumber('4'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '5',
                              onTap: () => _appendNumber('5'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '6',
                              onTap: () => _appendNumber('6'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '−',
                              onTap: () => _appendOperator('-'),
                              backgroundColor: colors.opBtnBg,
                              textColor: colors.opBtnText,
                              fontSize: 28,
                            ),
                          ],
                        ),
                      ),

                      // Row 4: 1, 2, 3, +
                      Expanded(
                        child: Row(
                          children: [
                            CalcButton(
                              label: '1',
                              onTap: () => _appendNumber('1'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '2',
                              onTap: () => _appendNumber('2'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '3',
                              onTap: () => _appendNumber('3'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '+',
                              onTap: () => _appendOperator('+'),
                              backgroundColor: colors.opBtnBg,
                              textColor: colors.opBtnText,
                              fontSize: 28,
                            ),
                          ],
                        ),
                      ),

                      // Row 5: 0, ., Del, =
                      Expanded(
                        child: Row(
                          children: [
                            CalcButton(
                              label: '0',
                              onTap: () => _appendNumber('0'),
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '.',
                              onTap: _appendDot,
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              icon: Icon(
                                Icons.backspace_outlined,
                                color: colors.numBtnText,
                                size: 22,
                              ),
                              onTap: _backspace,
                              onLongPress: _clearAll,
                              backgroundColor: colors.numBtnBg,
                              textColor: colors.numBtnText,
                            ),
                            CalcButton(
                              label: '=',
                              onTap: _calculate,
                              backgroundColor: colors.equalsBtnBg,
                              textColor: colors.equalsBtnText,
                              fontSize: 30,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeBar(AppColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          _buildModeTab('حاسبة أساسية', CalculatorMode.standard, colors),
          _buildModeTab('علمية متقدمة', CalculatorMode.scientific, colors),
          _buildModeTab('محول وحدات', CalculatorMode.converter, colors),
        ],
      ),
    );
  }

  Widget _buildModeTab(String title, CalculatorMode mode, AppColors colors) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _currentMode = mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
