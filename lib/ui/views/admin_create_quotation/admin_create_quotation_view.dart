import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_create_quotation_viewmodel.dart';

class AdminCreateQuotationView
    extends StackedView<AdminCreateQuotationViewModel> {
  final String requestId;

  const AdminCreateQuotationView({
    Key? key,
    required this.requestId,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminCreateQuotationViewModel viewModel,
    Widget? child,
  ) {
    viewModel.initialize(requestId);

    return AdminShell(
      title: 'Quotation Builder: #${viewModel.requestId}',
      selectedItem: AdminNavigationItem.rareRequests,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          TextButton.icon(
            onPressed: viewModel.goBack,
            icon: Icon(Icons.arrow_back,
                size: 16, color: AdminColors.textSecondary),
            label: Text('Back to Chat Room',
                style: TextStyle(color: AdminColors.textSecondary)),
          ),
          const SizedBox(height: 16),

          Form(
            key: viewModel.formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Panel: Form Inputs
                Expanded(
                  flex: 2,
                  child: AdminPanelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quotation details',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: viewModel.nameController,
                          decoration: const InputDecoration(
                              labelText: 'Spare Part Sourced Name',
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: viewModel.priceController,
                                keyboardType: TextInputType.number,
                                onChanged: (v) => viewModel.calculateTotal(),
                                decoration: const InputDecoration(
                                    labelText: 'Part Base Price (₹)',
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: viewModel.shippingController,
                                keyboardType: TextInputType.number,
                                onChanged: (v) => viewModel.calculateTotal(),
                                decoration: const InputDecoration(
                                    labelText: 'Delivery Charge (₹)',
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: viewModel.discountController,
                                keyboardType: TextInputType.number,
                                onChanged: (v) => viewModel.calculateTotal(),
                                decoration: const InputDecoration(
                                    labelText: 'Member Discount (₹)',
                                    border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: viewModel.timelineController,
                          decoration: const InputDecoration(
                              labelText: 'Estimated Delivery Timeline',
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: viewModel.notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                              labelText: 'Validity Notes / Warranty Info',
                              border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Right Panel: Invoice Calculation & Send
                Expanded(
                  child: AdminPanelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quotation Summary Breakdown',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _priceRow('Part Base Price',
                            '₹${double.tryParse(viewModel.priceController.text)?.toStringAsFixed(2) ?? '0.00'}'),
                        _priceRow('Delivery Charges',
                            '₹${double.tryParse(viewModel.shippingController.text)?.toStringAsFixed(2) ?? '0.00'}'),
                        _priceRow('CGST / SGST Tax (18%)',
                            '₹${viewModel.gst.toStringAsFixed(2)}'),
                        _priceRow('Member Discount',
                            '-₹${double.tryParse(viewModel.discountController.text)?.toStringAsFixed(2) ?? '0.00'}',
                            color: Colors.green),
                        const Divider(height: 24),
                        _priceRow('Total Bid Grand Amount',
                            '₹${viewModel.total.toStringAsFixed(2)}',
                            isBold: true, color: AdminColors.primaryGreen),
                        const SizedBox(height: 24),
                        const Text(
                          'Estimated Sourcing Delivery:',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          viewModel.timelineController.text.isNotEmpty
                              ? viewModel.timelineController.text
                              : 'Awaiting estimation',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: viewModel.sendQuotation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Send Quotation to Client Chat',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: isBold ? 16 : 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }

  @override
  AdminCreateQuotationViewModel viewModelBuilder(BuildContext context) =>
      AdminCreateQuotationViewModel();
}
