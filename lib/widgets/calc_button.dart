import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalcButton extends StatefulWidget {
  final String? label;
  final Widget? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final int flex;
  final double? height;
  final bool isPill;

  const CalcButton({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    this.onLongPress,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w600,
    this.flex = 1,
    this.height,
    this.isPill = false,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _animController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    _animController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.isPill ? 36 : 22);

    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: widget.onLongPress != null
                ? () {
                    HapticFeedback.mediumImpact();
                    widget.onLongPress!();
                  }
                : null,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: widget.icon ??
                    Text(
                      widget.label ?? '',
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: widget.fontSize,
                        fontWeight: widget.fontWeight,
                        letterSpacing: 0.5,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
