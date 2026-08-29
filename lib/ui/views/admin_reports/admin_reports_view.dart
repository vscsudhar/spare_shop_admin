import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_reports_viewmodel.dart';

class AdminReportsView extends StackedView<AdminReportsViewModel> {
  const AdminReportsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminReportsViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Business Analytics & Reports',
      selectedItem: AdminNavigationItem.reports,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Financial & Tax Performance',
                  style: AdminTextStyles.sectionHeader),
              DropdownButton<String>(
                value: viewModel.selectedPeriod,
                onChanged: (val) {
                  if (val != null) viewModel.setSelectedPeriod(val);
                },
                items: const [
                  DropdownMenuItem(value: 'Today', child: Text('Today')),
                  DropdownMenuItem(value: 'Weekly', child: Text('This Week')),
                  DropdownMenuItem(value: 'Monthly', child: Text('This Month')),
                  DropdownMenuItem(value: 'Yearly', child: Text('This Year')),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),

          // Stat Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 1.4 : 1.7,
                children: [
                  AdminMetricCard(
                    title: 'Net Sales Revenue',
                    value: '₹${viewModel.netSales.toStringAsFixed(0)}',
                    icon: Icons.attach_money_rounded,
                    iconColor: Colors.green,
                  ),
                  AdminMetricCard(
                    title: 'Gross Profit',
                    value: '₹${viewModel.grossProfit.toStringAsFixed(0)}',
                    icon: Icons.trending_up_rounded,
                    iconColor: Colors.blue,
                  ),
                  AdminMetricCard(
                    title: 'Avg Order Value',
                    value: '₹${viewModel.averageOrderValue.toStringAsFixed(0)}',
                    icon: Icons.shopping_basket_rounded,
                    iconColor: Colors.purple,
                  ),
                  AdminMetricCard(
                    title: 'GST Tax Payable',
                    value: '₹${viewModel.gstPayable.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: Colors.orange,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          Text('Export Financial Statements',
              style: AdminTextStyles.sectionHeader),
          const SizedBox(height: 16),

          // Export cards grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 3.5 : 4.5,
                children: [
                  _exportCard(context, 'Sales & Revenue Report',
                      'Details summaries of UPI checkout values and POS register tallies.'),
                  _exportCard(context, 'GST GSTR-1 Tax Ledger',
                      'Monthly report of tax collections categorized by 18% bracket items.'),
                  _exportCard(context, 'Stock Valuation & Turnover',
                      'Summarizes total units in warehouse and slow-moving items.'),
                  _exportCard(context, 'Workshop Outstanding Dues',
                      'Outstanding balances details filtered by workshop customer profiles.'),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _exportCard(BuildContext context, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.description, color: AdminColors.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: AdminTextStyles.body
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AdminTextStyles.bodySecondary),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.download, color: AdminColors.primaryGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Exporting CSV: $title... Saved to Downloads.')),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  AdminReportsViewModel viewModelBuilder(BuildContext context) =>
      AdminReportsViewModel();
}
