import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/shared/providers/theme_provider.dart';

class ListItemTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? subtitle2;
  final Widget? badge;
  final VoidCallback onTap;

  const ListItemTile({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitle2,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.bgSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                if (badge != null) badge!,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textSecondary,
                ),
              ),
            ],
            if (subtitle2 != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle2!,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
