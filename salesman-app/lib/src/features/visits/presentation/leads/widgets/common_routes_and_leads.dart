// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:track/src/core/ui/widgets/gap.dart';

// Configuration constants
const Color _kDefaultAccentColor = Colors.purple;

// Status Chip Widget
class StatusChip extends StatelessWidget {
  final String status;
  final Color? accentColor;
  final double? fontSize;
  final double? dotSize;
  final EdgeInsets? padding;

  const StatusChip({
    super.key,
    required this.status,
    this.accentColor,
    this.fontSize = 10,
    this.dotSize = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? _kDefaultAccentColor;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
          const GapH(4),
          Text(
            status,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// Action Button Widget
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final bool isPrimary;
  final double? iconSize;
  final double? fontSize;
  final EdgeInsets? padding;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.isPrimary = false,
    this.iconSize = 14,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor ?? theme.colorScheme.primary,
              (backgroundColor ?? theme.colorScheme.primary).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: (backgroundColor ?? theme.colorScheme.primary).withOpacity(
                0.25,
              ),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: iconSize,
            color: foregroundColor ?? Colors.white,
          ),
          label: Text(
            label,
            style: TextStyle(
              color: foregroundColor ?? Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.grey.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSize,
          color: foregroundColor ?? Colors.grey.withOpacity(0.9),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: foregroundColor ?? Colors.grey.withOpacity(0.9),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.grey.withOpacity(0.1),
          side: BorderSide.none,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
