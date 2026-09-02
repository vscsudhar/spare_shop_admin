import 'package:flutter/material.dart';
import 'package:spare_shop_admin/core/theme/theme_service.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_settings_viewmodel.dart';

class AdminSettingsView extends StackedView<AdminSettingsViewModel> {
  const AdminSettingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminSettingsViewModel viewModel,
    Widget? child,
  ) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= AdminBreakpoints.tablet;

    final sections = [
      'General',
      'Billing',
      'POS Settings',
      'Inventory',
      'Appearance',
      'Security',
    ];

    return AdminShell(
      title: 'Console Control Settings',
      selectedItem: AdminNavigationItem.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section Selector (Desktop navigation rail/tabs)
              if (isWide)
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AdminColors.panelBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sections.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final sec = sections[index];
                      final isSelected = viewModel.selectedSection == sec;
                      return ListTile(
                        title: Text(
                          sec,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AdminColors.primaryGreen
                                : AdminColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor:
                            AdminColors.primaryGreen.withValues(alpha: 0.12),
                        onTap: () => viewModel.setSection(sec),
                      );
                    },
                  ),
                ),

              // Right Section Content (Form Panels)
              Expanded(
                child: Column(
                  children: [
                    // Mobile Dropdown Selector
                    if (!isWide) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AdminColors.border),
                          borderRadius: BorderRadius.circular(8),
                          color: AdminColors.panelBackground,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: viewModel.selectedSection,
                            isExpanded: true,
                            dropdownColor: AdminColors.panelBackground,
                            items: sections
                                .map((sec) => DropdownMenuItem(
                                    value: sec,
                                    child: Text(sec,
                                        style: TextStyle(
                                            color: AdminColors.textPrimary))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) viewModel.setSection(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${viewModel.selectedSection} Parameters',
                              style: AdminTextStyles.sectionHeader
                                  .copyWith(fontSize: 16)),
                          const Divider(height: 32),
                          _buildActiveSectionContent(context, viewModel),
                          const Divider(height: 48),

                          // Save Action row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: viewModel.resetSettings,
                                style: OutlinedButton.styleFrom(
                                    side:
                                        BorderSide(color: AdminColors.border)),
                                child: Text('Reset to Defaults',
                                    style: TextStyle(
                                        color: AdminColors.textPrimary)),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    viewModel.saveSettings(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Save System Changes'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSectionContent(
      BuildContext context, AdminSettingsViewModel viewModel) {
    switch (viewModel.selectedSection) {
      case 'General':
        return Column(
          children: [
            _textInput(viewModel.storeNameController, 'HQ Headquarters Name'),
            _textInput(viewModel.phoneController, 'Contact Support Phone'),
            _textInput(viewModel.emailController, 'Corporate Email address'),
            _textInput(viewModel.gstNumberController, 'Tax GSTIN Registration'),
            _textInput(
                viewModel.addressController, 'Logistics Warehouse Address'),
          ],
        );
      case 'Billing':
        return Column(
          children: [
            _textInput(
                viewModel.invoicePrefixController, 'Invoice Prefix Schema'),
            _textInput(viewModel.nextInvoiceController,
                'Next Ticket Autoincrement No'),
            SwitchListTile(
              title: const Text('GST Calculations Enabled',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.gstEnabled,
              onChanged: viewModel.setGstEnabled,
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      case 'POS Settings':
        return Column(
          children: [
            _textInput(viewModel.taxPercentageController,
                'POS Tax / GST Percentage (%)'),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Support Split POS Payment Method',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.allowSplitPayment,
              onChanged: (val) {
                viewModel.allowSplitPayment = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Allow Cash Overpayment (Give Change)',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.allowCashOverpayment,
              onChanged: (val) {
                viewModel.allowCashOverpayment = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Require Reference/Txn ID for UPI POS',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.requireUpiId,
              onChanged: (val) {
                viewModel.requireUpiId = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Require Card Reference authorization',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.requireCardRef,
              onChanged: (val) {
                viewModel.requireCardRef = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      case 'Inventory':
        return Column(
          children: [
            _textInput(viewModel.lowStockThresholdController,
                'Low Stock Level Limit (Units)'),
            SwitchListTile(
              title: const Text('Out of Stock Warnings Enabled',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.outOfStockNotify,
              onChanged: (val) {
                viewModel.outOfStockNotify = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Allow Negative Inventory Sell Out',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.negativeStockAllowed,
              onChanged: (val) {
                viewModel.negativeStockAllowed = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      case 'Appearance':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visual Theme Preference',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            _themeRadioTile(
                viewModel, AppThemePreference.light, 'Clear Light Mode'),
            _themeRadioTile(
                viewModel, AppThemePreference.dark, 'Deep Graphite Dark Mode'),
            _themeRadioTile(viewModel, AppThemePreference.system,
                'Follow Platform OS settings'),
          ],
        );
      case 'Security':
        return Column(
          children: [
            _textInput(TextEditingController(), 'Old Console Password',
                obscure: true),
            _textInput(TextEditingController(), 'New Target Password',
                obscure: true),
            _textInput(TextEditingController(), 'Confirm New Password',
                obscure: true),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _textInput(TextEditingController ctrl, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _themeRadioTile(
      AdminSettingsViewModel vm, AppThemePreference pref, String label) {
    return RadioListTile<AppThemePreference>(
      value: pref,
      groupValue: vm.themePreference,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      activeColor: AdminColors.primaryGreen,
      onChanged: (val) {
        if (val != null) vm.setTheme(val);
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  AdminSettingsViewModel viewModelBuilder(BuildContext context) =>
      AdminSettingsViewModel();
}
