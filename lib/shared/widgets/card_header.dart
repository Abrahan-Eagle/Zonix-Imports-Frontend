import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/shared/providers/theme_provider.dart';

class CardHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const CardHeader({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.borderColor,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
