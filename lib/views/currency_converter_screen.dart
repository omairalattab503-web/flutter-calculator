import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';
import '../widgets/calc_button.dart';

class CurrencyConverterScreen extends StatefulWidget {
  final AppThemeMode currentTheme;

  const CurrencyConverterScreen({
    super.key,
    required this.currentTheme,
  });

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  Currency _fromCurrency = CurrencyService.supportedCurrencies[0]; // USD
  Currency _toCurrency = CurrencyService.supportedCurrencies[1];   // SAR
  String _inputAmount = '100';

  void _appendChar(String char) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_inputAmount == '0' && char != '.') {
        _inputAmount = char;
      } else if (char == '.') {
        if (!_inputAmount.contains('.')) {
          _inputAmount += '.';
        }
      } else {
        if (_inputAmount.length < 12) {
          _inputAmount += char;
        }
      }
    });
  }

  void _backspace() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_inputAmount.length <= 1) {
        _inputAmount = '0';
      } else {
        _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
      }
    });
  }

  void _clear() {
    HapticFeedback.mediumImpact();
    setState(() {
      _inputAmount = '0';
    });
  }

  void _swapCurrencies() {
    HapticFeedback.mediumImpact();
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(widget.currentTheme);
    final conversion = CurrencyService.convert(
      rawAmount: _inputAmount,
      fromCode: _fromCurrency.code,
      toCode: _toCurrency.code,
    );
    final currentRate = CurrencyService.getExchangeRate(_fromCurrency.code, _toCurrency.code);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.currency_exchange_rounded, color: colors.opBtnBg, size: 22),
              const SizedBox(width: 8),
              Text(
                'محول العملات',
                style: GoogleFonts.cairo(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: colors.textSecondary),
              tooltip: 'إعادة تعيين (100)',
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _inputAmount = '100');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  // Prominent Demonstration Disclaimer Banner
                  _buildDisclaimerBanner(colors),

                  const SizedBox(height: 8),

                  // Conversion Display Cards (From & To)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildConversionCards(colors, conversion, currentRate),
                  ),

                  const SizedBox(height: 10),

                  // Quick Rate Summary Chip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildRateChip(colors, currentRate),
                  ),

                  const Spacer(),

                  // Numeric Keypad
                  _buildKeypad(colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerBanner(AppColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.opBtnBg.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.opBtnBg.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colors.opBtnBg,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أسعار صرف توضيحية (Demonstration Rates)',
                  style: GoogleFonts.cairo(
                    color: colors.opBtnBg,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyService.rateDisclaimer,
                  style: GoogleFonts.cairo(
                    color: colors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionCards(
    AppColors colors,
    CurrencyConversionResult conversion,
    double rate,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // "From" Currency Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبلغ المطلوب تحويله',
                      style: GoogleFonts.cairo(
                        color: colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _inputAmount.isEmpty ? '0' : _inputAmount,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildCurrencyDropdown(
                value: _fromCurrency,
                colors: colors,
                onChanged: (c) {
                  if (c != null) {
                    setState(() => _fromCurrency = c);
                  }
                },
              ),
            ],
          ),

          // Swap Divider Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: colors.textSecondary.withValues(alpha: 0.2),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.swap_vert_rounded),
                    tooltip: 'تبديل العملتين',
                    onPressed: _swapCurrencies,
                    style: IconButton.styleFrom(
                      backgroundColor: colors.displayBg,
                      foregroundColor: colors.opBtnBg,
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: colors.textSecondary.withValues(alpha: 0.2),
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),

          // "To" Currency Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النتيجة المحولة',
                      style: GoogleFonts.cairo(
                        color: colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (conversion.isSuccess)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          conversion.formattedResult ?? '0',
                          style: TextStyle(
                            color: colors.accent,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      Text(
                        conversion.errorMessage ?? 'قيمة غير صالحة',
                        style: GoogleFonts.cairo(
                          color: colors.actionBtnBg,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildCurrencyDropdown(
                value: _toCurrency,
                colors: colors,
                onChanged: (c) {
                  if (c != null) {
                    setState(() => _toCurrency = c);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required Currency value,
    required AppColors colors,
    required ValueChanged<Currency?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.displayBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.25),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          value: value,
          dropdownColor: colors.surface,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.accent),
          items: CurrencyService.supportedCurrencies.map((c) {
            return DropdownMenuItem<Currency>(
              value: c,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.flagEmoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    c.code,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${c.symbol})',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRateChip(AppColors colors, double rate) {
    final formattedRate = CurrencyService.formatAmount(rate);
    final inverseRate = rate != 0 ? CurrencyService.formatAmount(1.0 / rate) : '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 16, color: colors.opBtnBg),
              const SizedBox(width: 6),
              Text(
                '1 ${_fromCurrency.code} = $formattedRate ${_toCurrency.code}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '1 ${_toCurrency.code} = $inverseRate ${_fromCurrency.code}',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: [
          // Row 1: 7, 8, 9, C
          Row(
            children: [
              CalcButton(
                label: '7',
                onTap: () => _appendChar('7'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: '8',
                onTap: () => _appendChar('8'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: '9',
                onTap: () => _appendChar('9'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: 'C',
                onTap: _clear,
                backgroundColor: colors.actionBtnBg,
                textColor: colors.actionBtnText,
              ),
            ],
          ),

          // Row 2: 4, 5, 6, Del
          Row(
            children: [
              CalcButton(
                label: '4',
                onTap: () => _appendChar('4'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: '5',
                onTap: () => _appendChar('5'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: '6',
                onTap: () => _appendChar('6'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                icon: Icon(Icons.backspace_outlined, color: colors.textPrimary, size: 20),
                onTap: _backspace,
                backgroundColor: colors.surface,
                textColor: colors.textPrimary,
              ),
            ],
          ),

          // Row 3: 1, 2, 3, +100
          Row(
            children: [
              CalcButton(
                label: '1',
                onTap: () => _appendChar('1'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: '2',
                onTap: () => _appendChar('2'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: '3',
                onTap: () => _appendChar('3'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: '+100',
                onTap: () {
                  HapticFeedback.selectionClick();
                  final cur = double.tryParse(_inputAmount) ?? 0.0;
                  setState(() => _inputAmount = (cur + 100).toStringAsFixed(0));
                },
                backgroundColor: colors.sciBtnBg,
                textColor: colors.sciBtnText,
                fontSize: 16,
              ),
            ],
          ),

          // Row 4: 00, 0, ., Swap
          Row(
            children: [
              CalcButton(
                label: '00',
                onTap: () => _appendChar('00'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: '0',
                onTap: () => _appendChar('0'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                label: '.',
                onTap: () => _appendChar('.'),
                backgroundColor: colors.numBtnBg,
                textColor: colors.numBtnText,
              ),
              CalcButton(
                icon: Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 24),
                onTap: _swapCurrencies,
                backgroundColor: colors.opBtnBg,
                textColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
