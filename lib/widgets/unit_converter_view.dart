import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'calc_button.dart';

class UnitDefinition {
  final String id;
  final String nameAr;
  final String symbol;
  final double toBase; // Multiplier to convert 1 unit to base unit

  const UnitDefinition({
    required this.id,
    required this.nameAr,
    required this.symbol,
    required this.toBase,
  });
}

class UnitCategory {
  final String id;
  final String nameAr;
  final IconData icon;
  final List<UnitDefinition> units;

  const UnitCategory({
    required this.id,
    required this.nameAr,
    required this.icon,
    required this.units,
  });
}

class UnitConverterView extends StatefulWidget {
  final AppThemeMode currentTheme;

  const UnitConverterView({
    super.key,
    required this.currentTheme,
  });

  @override
  State<UnitConverterView> createState() => _UnitConverterViewState();
}

class _UnitConverterViewState extends State<UnitConverterView> {
  static const List<UnitCategory> _categories = [
    UnitCategory(
      id: 'length',
      nameAr: 'الطول',
      icon: Icons.straighten_rounded,
      units: [
        UnitDefinition(id: 'm', nameAr: 'متر', symbol: 'm', toBase: 1.0),
        UnitDefinition(id: 'km', nameAr: 'كيلومتر', symbol: 'km', toBase: 1000.0),
        UnitDefinition(id: 'cm', nameAr: 'سنتيمتر', symbol: 'cm', toBase: 0.01),
        UnitDefinition(id: 'mm', nameAr: 'ميليمتر', symbol: 'mm', toBase: 0.001),
        UnitDefinition(id: 'mi', nameAr: 'ميل', symbol: 'mi', toBase: 1609.344),
        UnitDefinition(id: 'yd', nameAr: 'ياردة', symbol: 'yd', toBase: 0.9144),
        UnitDefinition(id: 'ft', nameAr: 'قدم', symbol: 'ft', toBase: 0.3048),
        UnitDefinition(id: 'in', nameAr: 'بوصة', symbol: 'in', toBase: 0.0254),
      ],
    ),
    UnitCategory(
      id: 'mass',
      nameAr: 'الوزن والكتلة',
      icon: Icons.scale_rounded,
      units: [
        UnitDefinition(id: 'kg', nameAr: 'كيلوغرام', symbol: 'kg', toBase: 1.0),
        UnitDefinition(id: 'g', nameAr: 'غرام', symbol: 'g', toBase: 0.001),
        UnitDefinition(id: 'mg', nameAr: 'ميليغرام', symbol: 'mg', toBase: 0.000001),
        UnitDefinition(id: 'lb', nameAr: 'رطل (باوند)', symbol: 'lb', toBase: 0.45359237),
        UnitDefinition(id: 'oz', nameAr: 'أونصة', symbol: 'oz', toBase: 0.02834952),
        UnitDefinition(id: 't', nameAr: 'طن متري', symbol: 't', toBase: 1000.0),
      ],
    ),
    UnitCategory(
      id: 'temp',
      nameAr: 'الحرارة',
      icon: Icons.thermostat_rounded,
      units: [
        UnitDefinition(id: 'c', nameAr: 'سلسيوس', symbol: '°C', toBase: 1.0),
        UnitDefinition(id: 'f', nameAr: 'فهرنهايت', symbol: '°F', toBase: 1.0),
        UnitDefinition(id: 'k', nameAr: 'كلفن', symbol: 'K', toBase: 1.0),
      ],
    ),
    UnitCategory(
      id: 'area',
      nameAr: 'المساحة',
      icon: Icons.crop_square_rounded,
      units: [
        UnitDefinition(id: 'sqm', nameAr: 'متر مربع', symbol: 'm²', toBase: 1.0),
        UnitDefinition(id: 'sqkm', nameAr: 'كيلومتر مربع', symbol: 'km²', toBase: 1000000.0),
        UnitDefinition(id: 'ha', nameAr: 'هكتار', symbol: 'ha', toBase: 10000.0),
        UnitDefinition(id: 'acre', nameAr: 'فدان', symbol: 'ac', toBase: 4046.85642),
        UnitDefinition(id: 'sqft', nameAr: 'قدم مربع', symbol: 'ft²', toBase: 0.092903),
      ],
    ),
    UnitCategory(
      id: 'volume',
      nameAr: 'الحجم',
      icon: Icons.water_drop_rounded,
      units: [
        UnitDefinition(id: 'l', nameAr: 'لتر', symbol: 'L', toBase: 1.0),
        UnitDefinition(id: 'ml', nameAr: 'ميليلتر', symbol: 'mL', toBase: 0.001),
        UnitDefinition(id: 'cum', nameAr: 'متر مكعب', symbol: 'm³', toBase: 1000.0),
        UnitDefinition(id: 'gal', nameAr: 'غالون أمريكي', symbol: 'gal', toBase: 3.78541),
      ],
    ),
    UnitCategory(
      id: 'speed',
      nameAr: 'السرعة',
      icon: Icons.speed_rounded,
      units: [
        UnitDefinition(id: 'kmh', nameAr: 'كم/ساعة', symbol: 'km/h', toBase: 1.0),
        UnitDefinition(id: 'ms', nameAr: 'متر/ثانية', symbol: 'm/s', toBase: 3.6),
        UnitDefinition(id: 'mph', nameAr: 'ميل/ساعة', symbol: 'mph', toBase: 1.60934),
        UnitDefinition(id: 'knot', nameAr: 'عقدة بحرية', symbol: 'kn', toBase: 1.852),
      ],
    ),
    UnitCategory(
      id: 'data',
      nameAr: 'البيانات',
      icon: Icons.sd_storage_rounded,
      units: [
        UnitDefinition(id: 'b', nameAr: 'بايت', symbol: 'B', toBase: 1.0),
        UnitDefinition(id: 'kb', nameAr: 'كيلوبايت', symbol: 'KB', toBase: 1024.0),
        UnitDefinition(id: 'mb', nameAr: 'ميغابايت', symbol: 'MB', toBase: 1048576.0),
        UnitDefinition(id: 'gb', nameAr: 'غيغابايت', symbol: 'GB', toBase: 1073741824.0),
        UnitDefinition(id: 'tb', nameAr: 'تيرابايت', symbol: 'TB', toBase: 1099511627776.0),
      ],
    ),
  ];

  int _selectedCategoryIndex = 0;
  late UnitDefinition _fromUnit;
  late UnitDefinition _toUnit;
  String _inputVal = '1';

  @override
  void initState() {
    super.initState();
    _updateSelectedUnits();
  }

  void _updateSelectedUnits() {
    final cat = _categories[_selectedCategoryIndex];
    _fromUnit = cat.units[0];
    _toUnit = cat.units.length > 1 ? cat.units[1] : cat.units[0];
  }

  double _convertValue(double input) {
    final cat = _categories[_selectedCategoryIndex];
    if (cat.id == 'temp') {
      // Temperature conversion
      double cVal = input;
      if (_fromUnit.id == 'f') {
        cVal = (input - 32) * 5 / 9;
      } else if (_fromUnit.id == 'k') {
        cVal = input - 273.15;
      }

      if (_toUnit.id == 'c') return cVal;
      if (_toUnit.id == 'f') return (cVal * 9 / 5) + 32;
      if (_toUnit.id == 'k') return cVal + 273.15;
      return cVal;
    }

    // Standard linear conversion
    final inBase = input * _fromUnit.toBase;
    return inBase / _toUnit.toBase;
  }

  String _formatResult(double val) {
    if (val.isNaN) return '0';
    if (val.abs() < 1e-6 && val != 0) {
      return val.toStringAsExponential(4);
    }
    if (val >= 1e9) {
      return val.toStringAsExponential(4);
    }
    if (val == val.roundToDouble()) {
      return NumberFormat('#,###', 'en_US').format(val.toInt());
    }
    String s = val.toStringAsPrecision(8);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  void _appendChar(String c) {
    setState(() {
      if (_inputVal == '0' && c != '.') {
        _inputVal = c;
      } else if (c == '.') {
        if (!_inputVal.contains('.')) {
          _inputVal += '.';
        }
      } else if (_inputVal.length < 14) {
        _inputVal += c;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_inputVal.length <= 1) {
        _inputVal = '0';
      } else {
        _inputVal = _inputVal.substring(0, _inputVal.length - 1);
      }
    });
  }

  void _clear() {
    setState(() {
      _inputVal = '0';
    });
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(widget.currentTheme);
    final cat = _categories[_selectedCategoryIndex];
    final inDouble = double.tryParse(_inputVal) ?? 0.0;
    final converted = _convertValue(inDouble);
    final formattedResult = _formatResult(converted);

    return Column(
      children: [
        // Categories list
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, idx) {
              final c = _categories[idx];
              final isSel = idx == _selectedCategoryIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  avatar: Icon(
                    c.icon,
                    size: 18,
                    color: isSel ? Colors.white : colors.textSecondary,
                  ),
                  label: Text(
                    c.nameAr,
                    style: TextStyle(
                      color: isSel ? Colors.white : colors.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: colors.accent,
                  backgroundColor: colors.surface,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSel ? colors.accent : colors.surface,
                    ),
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedCategoryIndex = idx;
                        _updateSelectedUnits();
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Conversion display cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                // "From" card
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _inputVal,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DropdownButton<UnitDefinition>(
                      value: _fromUnit,
                      dropdownColor: colors.surface,
                      style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold),
                      underline: const SizedBox(),
                      items: cat.units.map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Text('${u.nameAr} (${u.symbol})'),
                        );
                      }).toList(),
                      onChanged: (u) {
                        if (u != null) {
                          setState(() => _fromUnit = u);
                        }
                      },
                    ),
                  ],
                ),

                // Swap divider button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.swap_vert_rounded),
                      onPressed: _swapUnits,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.displayBg,
                        foregroundColor: colors.accent,
                      ),
                    ),
                  ],
                ),

                // "To" card
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formattedResult,
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DropdownButton<UnitDefinition>(
                      value: _toUnit,
                      dropdownColor: colors.surface,
                      style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold),
                      underline: const SizedBox(),
                      items: cat.units.map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Text('${u.nameAr} (${u.symbol})'),
                        );
                      }).toList(),
                      onChanged: (u) {
                        if (u != null) {
                          setState(() => _toUnit = u);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Numeric Keypad for Unit Converter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  CalcButton(
                    label: '7',
                    onTap: () => _appendChar('7'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    label: '8',
                    onTap: () => _appendChar('8'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    label: '9',
                    onTap: () => _appendChar('9'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    label: 'AC',
                    onTap: _clear,
                    backgroundColor: colors.actionBtnBg,
                    textColor: colors.actionBtnText,
                    height: 56,
                  ),
                ],
              ),
              Row(
                children: [
                  CalcButton(
                    label: '4',
                    onTap: () => _appendChar('4'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    label: '5',
                    onTap: () => _appendChar('5'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    label: '6',
                    onTap: () => _appendChar('6'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    icon: Icon(Icons.backspace_outlined, color: colors.actionBtnText, size: 22),
                    onTap: _backspace,
                    backgroundColor: colors.actionBtnBg.withValues(alpha: 0.8),
                    textColor: colors.actionBtnText,
                    height: 56,
                  ),
                ],
              ),
              Row(
                children: [
                  CalcButton(
                    label: '1',
                    onTap: () => _appendChar('1'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    label: '2',
                    onTap: () => _appendChar('2'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    label: '3',
                    onTap: () => _appendChar('3'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 22),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: formattedResult));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم نسخ $formattedResult ${_toUnit.nameAr}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    backgroundColor: colors.equalsBtnBg,
                    textColor: colors.equalsBtnText,
                    height: 56,
                  ),
                ],
              ),
              Row(
                children: [
                  CalcButton(
                    label: '0',
                    flex: 2,
                    isPill: true,
                    onTap: () => _appendChar('0'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    label: '.',
                    onTap: () => _appendChar('.'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                  CalcButton(
                    label: '00',
                    onTap: () => _appendChar('00'),
                    backgroundColor: colors.numBtnBg,
                    textColor: colors.numBtnText,
                    height: 56,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
