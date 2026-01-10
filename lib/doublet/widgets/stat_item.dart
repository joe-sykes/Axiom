import 'package:flutter/material.dart';

/// Reusable stat item widget used in stats cards and results screens
class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final double iconSize;
  final TextStyle? valueStyle;

  const StatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.iconSize = 24,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: iconSize,
            semanticLabel: label,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: valueStyle ??
                Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
