import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';

class AdminMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;

  const AdminMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
        boxShadow: [AdminShadows.card],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminSpacing.s + 4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AdminSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AdminTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(value, style: AdminTextStyles.cardValue),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AdminTextStyles.bodySecondary.copyWith(
                      color: subtitle!.contains('+')
                          ? AdminColors.success
                          : AdminColors.textLight,
                    ),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AdminPanelCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AdminPanelCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
        boxShadow: [AdminShadows.card],
      ),
      child: child,
    );
  }
}

class AdminSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AdminTextStyles.sectionHeader),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AdminFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AdminFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminRadius.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AdminSpacing.m, vertical: AdminSpacing.s),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AdminRadius.chip),
          border: Border.all(
            color: isSelected ? AdminColors.primaryGreen : AdminColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AdminColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class AdminStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const AdminStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AdminRadius.chip),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const AdminEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AdminColors.textLight),
            const SizedBox(height: AdminSpacing.m),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AdminTextStyles.bodySecondary.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
