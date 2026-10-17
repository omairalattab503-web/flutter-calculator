import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'calc_button.dart';

class ScientificKeypad extends StatefulWidget {
  final AppThemeMode currentTheme;
  final Function(String) onInsertFunction;
  final VoidCallback onFactorial;
  final VoidCallback onSquare;
  final VoidCallback onPower;
  final VoidCallback onSqrt;

  const ScientificKeypad({
    super.key,
    required this.currentTheme,
    required this.onInsertFunction,
    required this.onFactorial,
    required this.onSquare,
    required this.onPower,
    required this.onSqrt,
  });

  @override
  State<ScientificKeypad> createState() => _ScientificKeypadState();
}

class _ScientificKeypadState extends State<ScientificKeypad> {
  bool _isSecondMode = false;

  void _toggleSecondMode() {
    setState(() {
      _isSecondMode = !_isSecondMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(widget.currentTheme);
    const double btnHeight = 44;
    const double fontSize = 15;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: 2nd, sin/asin, cos/acos, tan/atan, π
          Row(
            children: [
              CalcButton(
                label: '2nd',
                onTap: _toggleSecondMode,
                backgroundColor: _isSecondMode ? colors.accent : colors.sciBtnBg,
                textColor: _isSecondMode ? Colors.white : colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: _isSecondMode ? 'asin' : 'sin',
                onTap: () => widget.onInsertFunction(_isSecondMode ? 'asin(' : 'sin('),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: _isSecondMode ? 'acos' : 'cos',
                onTap: () => widget.onInsertFunction(_isSecondMode ? 'acos(' : 'cos('),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: _isSecondMode ? 'atan' : 'tan',
                onTap: () => widget.onInsertFunction(_isSecondMode ? 'atan(' : 'tan('),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: 'π',
                onTap: () => widget.onInsertFunction('π'),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
            ],
          ),

          // Row 2: ln / e^x, log / 10^x, x^y, √ / x², e
          Row(
            children: [
              CalcButton(
                label: _isSecondMode ? 'eˣ' : 'ln',
                onTap: () => widget.onInsertFunction(_isSecondMode ? 'e^(' : 'ln('),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: _isSecondMode ? '10ˣ' : 'log',
                onTap: () => widget.onInsertFunction(_isSecondMode ? '10^(' : 'log('),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: 'xʸ',
                onTap: widget.onPower,
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: _isSecondMode ? 'x²' : '√',
                onTap: _isSecondMode ? widget.onSquare : widget.onSqrt,
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: 'e',
                onTap: () => widget.onInsertFunction('e'),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
            ],
          ),

          // Row 3: x!, (, ), 1/x, |x|
          Row(
            children: [
              CalcButton(
                label: 'x!',
                onTap: widget.onFactorial,
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: '(',
                onTap: () => widget.onInsertFunction('('),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: ')',
                onTap: () => widget.onInsertFunction(')'),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: '1/x',
                onTap: () => widget.onInsertFunction('1/('),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
              CalcButton(
                label: '|x|',
                onTap: () => widget.onInsertFunction('abs('),
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                height: btnHeight,
                fontSize: fontSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
