import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';

class AdminDataTable extends StatelessWidget {
  final List<String> columns;
  final List<Widget> rows;
  final List<int>? columnFlex;
  final double minWidth;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnFlex,
    this.minWidth = 980,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidget = Container(
          decoration: BoxDecoration(
            color: AdminColors.panelBackground,
            borderRadius: BorderRadius.circular(AdminRadius.card),
            border: Border.all(color: AdminColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: AdminColors.background,
                padding: const EdgeInsets.symmetric(
                    horizontal: AdminSpacing.m, vertical: AdminSpacing.m),
                child: Row(
                  children: columns.asMap().entries.map((entry) {
                    final flex = columnFlex != null &&
                            entry.key < columnFlex!.length
                        ? columnFlex![entry.key]
                        : 1;
                    return Expanded(
                      flex: flex,
                      child: Text(
                        entry.value,
                        style: AdminTextStyles.tableHeader,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(height: 1, color: AdminColors.border),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AdminSpacing.xl),
                  child: Center(
                    child: Text('No data available',
                        style: TextStyle(color: AdminColors.textLight)),
                  ),
                )
              else
                ...rows,
            ],
          ),
        );

        if (constraints.maxWidth < minWidth) {
          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: minWidth,
                child: tableWidget,
              ),
            ),
          );
        }

        return tableWidget;
      },
    );
  }
}

class AdminTableRow extends StatelessWidget {
  final List<Widget> cells;
  final VoidCallback? onTap;
  final List<int>? columnFlex;

  const AdminTableRow({
    super.key,
    required this.cells,
    this.onTap,
    this.columnFlex,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AdminSpacing.m, vertical: AdminSpacing.m),
            child: Row(
              children: cells.asMap().entries.map((entry) {
                final flex =
                    columnFlex != null && entry.key < columnFlex!.length
                        ? columnFlex![entry.key]
                        : 1;
                return Expanded(
                  flex: flex,
                  child: entry.value,
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: AdminColors.border),
        ],
      ),
    );
  }
}

class StockLevelIndicator extends StatelessWidget {
  final int stock;
  final int reorderLevel;

  const StockLevelIndicator({
    super.key,
    required this.stock,
    this.reorderLevel = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = stock <= reorderLevel;
    final isOutOfStock = stock == 0;

    final color = isOutOfStock
        ? AdminColors.cancelled
        : isLow
            ? AdminColors.pending
            : AdminColors.success;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isOutOfStock ? 'Out of stock' : '$stock units',
          style: AdminTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: isLow ? FontWeight.bold : FontWeight.normal,
            color: isLow ? color : AdminColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
