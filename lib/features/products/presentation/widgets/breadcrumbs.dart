import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/category_model.dart';

/// Widget de breadcrumbs para navegación de categorías
class Breadcrumbs extends StatelessWidget {
  final List<CategoryModel> breadcrumbPath;
  final Function(CategoryModel)? onCategoryTap;
  final VoidCallback? onHomeTap;

  const Breadcrumbs({
    super.key,
    required this.breadcrumbPath,
    this.onCategoryTap,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (breadcrumbPath.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMD,
        vertical: UIConstants.spacingSM,
      ),
      decoration: BoxDecoration(
        color: isDark ? UIConstants.cardBgDark : UIConstants.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? UIConstants.grayDark : UIConstants.grayLight,
            width: UIConstants.borderThin,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildHomeButton(context, isDark),
            ...breadcrumbPath.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Row(
                children: [
                  _buildSeparator(context, isDark),
                  _buildCategoryButton(context, category, isDark,
                      index == breadcrumbPath.length - 1),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: onHomeTap,
      borderRadius: BorderRadius.circular(UIConstants.radiusSM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingSM,
          vertical: UIConstants.spacingXS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_outlined,
              size: UIConstants.iconSizeSM,
              color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
            ),
            const SizedBox(width: UIConstants.spacingXS),
            Text(
              'Inicio',
              style: TextStyle(
                fontSize: UIConstants.fontSizeSM,
                fontWeight: UIConstants.fontWeightMedium,
                color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingXS),
      child: Icon(
        Icons.chevron_right,
        size: UIConstants.iconSizeSM,
        color: isDark ? UIConstants.textLight : UIConstants.textSecondary,
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    CategoryModel category,
    bool isDark,
    bool isLast,
  ) {
    return InkWell(
      onTap: isLast ? null : () => onCategoryTap?.call(category),
      borderRadius: BorderRadius.circular(UIConstants.radiusSM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingSM,
          vertical: UIConstants.spacingXS,
        ),
        decoration: isLast
            ? BoxDecoration(
                color: UIConstants.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                border: Border.all(
                  color: UIConstants.primaryBlue.withOpacity(0.3),
                  width: UIConstants.borderThin,
                ),
              )
            : null,
        child: Text(
          category.name,
          style: TextStyle(
            fontSize: UIConstants.fontSizeSM,
            fontWeight: isLast
                ? UIConstants.fontWeightBold
                : UIConstants.fontWeightMedium,
            color: isLast
                ? UIConstants.primaryBlue
                : (isDark ? UIConstants.textWhite : UIConstants.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Widget de breadcrumbs simplificado para casos básicos
class SimpleBreadcrumbs extends StatelessWidget {
  final String currentPath;
  final VoidCallback? onHomeTap;

  const SimpleBreadcrumbs({
    super.key,
    required this.currentPath,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMD,
        vertical: UIConstants.spacingSM,
      ),
      decoration: BoxDecoration(
        color: isDark ? UIConstants.cardBgDark : UIConstants.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? UIConstants.grayDark : UIConstants.grayLight,
            width: UIConstants.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onHomeTap,
            borderRadius: BorderRadius.circular(UIConstants.radiusSM),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingSM,
                vertical: UIConstants.spacingXS,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: UIConstants.iconSizeSM,
                    color: isDark
                        ? UIConstants.textWhite
                        : UIConstants.textPrimary,
                  ),
                  const SizedBox(width: UIConstants.spacingXS),
                  Text(
                    'Inicio',
                    style: TextStyle(
                      fontSize: UIConstants.fontSizeSM,
                      fontWeight: UIConstants.fontWeightMedium,
                      color: isDark
                          ? UIConstants.textWhite
                          : UIConstants.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: UIConstants.spacingXS),
            child: Icon(
              Icons.chevron_right,
              size: UIConstants.iconSizeSM,
              color: isDark ? UIConstants.textLight : UIConstants.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingSM,
              vertical: UIConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: UIConstants.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConstants.radiusSM),
              border: Border.all(
                color: UIConstants.primaryBlue.withOpacity(0.3),
                width: UIConstants.borderThin,
              ),
            ),
            child: Text(
              currentPath,
              style: TextStyle(
                fontSize: UIConstants.fontSizeSM,
                fontWeight: UIConstants.fontWeightBold,
                color: UIConstants.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
