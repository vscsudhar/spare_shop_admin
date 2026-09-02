import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_supplier_detail_viewmodel.dart';

class AdminSupplierDetailView
    extends StackedView<AdminSupplierDetailViewModel> {
  final String supplierId;

  const AdminSupplierDetailView({
    Key? key,
    required this.supplierId,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminSupplierDetailViewModel viewModel,
    Widget? child,
  ) {
    viewModel.init(supplierId);
    final s = viewModel.supplier;

    if (s == null) {
      return AdminShell(
        title: 'Supplier Detail',
        selectedItem: AdminNavigationItem.suppliers,
        child: const Center(child: Text('Supplier not found.')),
      );
    }

    final outstandingVal = s.outstandingAmountInPaise / 100.0;

    return AdminShell(
      title: 'Supplier: ${s.companyName}',
      selectedItem: AdminNavigationItem.suppliers,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: viewModel.goBack,
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        viewModel.goToEditAdminSupplier(supplierId: s.id),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.textPrimary,
                      side: BorderSide(color: AdminColors.border),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: viewModel.toggleStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: s.isActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(s.isActive
                        ? 'Deactivate Supplier'
                        : 'Activate Supplier'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Profile Card, Contact Details, GST
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Profile card
                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AdminColors.primaryGreen
                                    .withValues(alpha: 0.12),
                                child: Icon(Icons.warehouse_rounded,
                                    color: AdminColors.primaryGreen, size: 30),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.companyName,
                                        style: AdminTextStyles.header
                                            .copyWith(fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        AdminStatusChip(
                                          label: s.isActive
                                              ? 'ACTIVE PARTNER'
                                              : 'INACTIVE PARTNER',
                                          color: s.isActive
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        if (s.suppliesEvParts)
                                          const AdminStatusChip(
                                              label: 'EV SPARES',
                                              color: Colors.blue),
                                        if (s.suppliesPetrolParts)
                                          const SizedBox(width: 6),
                                        if (s.suppliesPetrolParts)
                                          const AdminStatusChip(
                                              label: 'PETROL',
                                              color: Colors.amber),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          _infoRow('Contact Representative', s.contactPerson),
                          _infoRow('Primary Phone', s.phone),
                          _infoRow('Email Address', s.email),
                          _infoRow('GST Registration No.', s.gstNumber),
                          _infoRow('Corporate Office Address',
                              '${s.address}, ${s.city}, ${s.state}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bank Info
                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bank & Payment Logistics',
                              style: AdminTextStyles.sectionHeader
                                  .copyWith(fontSize: 14)),
                          const SizedBox(height: 12),
                          _infoRow('Bank Name', 'HDFC Bank Ltd'),
                          _infoRow('Account Number',
                              '50200088122334 (Current Account)'),
                          _infoRow('IFSC Code', 'HDFC0000123'),
                          _infoRow('UPI ID',
                              '${s.phone.replaceAll(' ', '').replaceAll('+', '')}@okhdfc'),
                          _infoRow('Standard Payment Terms',
                              'Net 30 Days credit period limit'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column: Ledger, Record payment
              Expanded(
                child: Column(
                  children: [
                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Outstanding Ledger',
                              style: AdminTextStyles.sectionHeader
                                  .copyWith(fontSize: 14)),
                          const SizedBox(height: 24),
                          Center(
                            child: Column(
                              children: [
                                const Text('CURRENT PAYABLE BALANCE',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(
                                  '₹${outstandingVal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: outstandingVal > 0
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: outstandingVal > 0
                                ? () =>
                                    _showRecordPaymentDialog(context, viewModel)
                                : null,
                            icon: const Icon(Icons.payment_rounded, size: 16),
                            label: const Text('Record Cash/UPI Payment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Supplied categories tags list
                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categories Supplied',
                              style: AdminTextStyles.sectionHeader
                                  .copyWith(fontSize: 14)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: s.categories.map((c) {
                              return Chip(
                                label: Text(c,
                                    style: const TextStyle(fontSize: 11)),
                                backgroundColor: AdminColors.isDarkTheme
                                    ? Colors.white10
                                    : Colors.black12.withValues(alpha: 0.04),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Purchase Orders History (Mock)
          AdminPanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Purchase Orders History',
                    style:
                        AdminTextStyles.sectionHeader.copyWith(fontSize: 14)),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('PO Number')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Total Value')),
                      DataColumn(label: Text('Payment Status')),
                      DataColumn(label: Text('Fulfilment')),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('PO-2026-0811',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(DateTime.now()
                            .subtract(const Duration(days: 5))
                            .toString()
                            .substring(0, 10))),
                        const DataCell(Text('₹35,000.00')),
                        const DataCell(AdminStatusChip(
                            label: 'PAID', color: Colors.green)),
                        const DataCell(AdminStatusChip(
                            label: 'DELIVERED', color: Colors.green)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('PO-2026-0812',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(DateTime.now()
                            .subtract(const Duration(days: 12))
                            .toString()
                            .substring(0, 10))),
                        const DataCell(Text('₹45,000.00')),
                        DataCell(AdminStatusChip(
                            label: outstandingVal > 0 ? 'PARTIAL' : 'PAID',
                            color: outstandingVal > 0
                                ? Colors.orange
                                : Colors.green)),
                        const DataCell(AdminStatusChip(
                            label: 'DELIVERED', color: Colors.green)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordPaymentDialog(
      BuildContext context, AdminSupplierDetailViewModel viewModel) {
    final amtController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Outstanding Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Input the payment amount made to this supplier to update the accounts ledger balance.',
                  style: TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: amtController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount Paid (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amtController.text) ?? 0.0;
                if (amt > 0) {
                  viewModel.recordPayment(amt);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white),
              child: const Text('Save Payment'),
            )
          ],
        );
      },
    );
  }

  @override
  AdminSupplierDetailViewModel viewModelBuilder(BuildContext context) =>
      AdminSupplierDetailViewModel();
}
