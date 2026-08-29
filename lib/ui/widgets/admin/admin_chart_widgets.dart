import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';

class SalesBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const SalesBarChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue = values.isEmpty
        ? 1.0
        : values.reduce((curr, next) => curr > next ? curr : next);

    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Sales Analytics',
                  style: AdminTextStyles.body
                      .copyWith(fontWeight: FontWeight.bold)),
              Icon(Icons.show_chart, color: AdminColors.primaryGreen, size: 20),
            ],
          ),
          const SizedBox(height: AdminSpacing.l),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final double val = values[index];
                final double pct = val / (maxValue == 0 ? 1.0 : maxValue);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '₹${val.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 120 * pct,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AdminColors.primaryGreen.withValues(alpha: 0.85),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(labels[index],
                          style: TextStyle(
                              fontSize: 10, color: AdminColors.textLight)),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
