import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_billing_viewmodel.dart';
import 'package:spare_shop_admin/core/utils/thermal_printer_web.dart';

class AdminBillingView extends StackedView<AdminBillingViewModel> {
  const AdminBillingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminBillingViewModel viewModel,
    Widget? child,
  ) {
    viewModel.initialize();
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 1000;

    return AdminShell(
      title: 'POS Billing Counter',
      selectedItem: AdminNavigationItem.billing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Items and Split Payment Allocation Form
              Expanded(
                flex: isWide ? 2 : 3,
                child: Column(
                  children: [
                    // Search Bar
                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Search Spare Part to Add',
                                  style: AdminTextStyles.sectionHeader
                                      .copyWith(fontSize: 14)),
                              ElevatedButton.icon(
                                icon:
                                    const Icon(Icons.history_rounded, size: 16),
                                label: const Text('Billing History'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                onPressed: () {
                                  _showPastBillsDialog(context, viewModel);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: viewModel.setSearchQuery,
                            decoration: InputDecoration(
                              hintText: 'Enter part name or SKU barcode...',
                              prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          if (viewModel.searchResults.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 180),
                              decoration: BoxDecoration(
                                border: Border.all(color: AdminColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: viewModel.searchResults.length,
                                itemBuilder: (context, index) {
                                  final prod = viewModel.searchResults[index];
                                  return ListTile(
                                    title: Text(prod.name),
                                    subtitle: Text(
                                        'SKU: ${prod.id} • Price: ₹${prod.price}'),
                                    trailing: Icon(Icons.add,
                                        color: AdminColors.primaryGreen),
                                    onTap: () =>
                                        viewModel.addProductToInvoice(prod),
                                  );
                                },
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cart Items List
                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Invoice Items list',
                                  style: AdminTextStyles.sectionHeader
                                      .copyWith(fontSize: 14)),
                              if (viewModel.invoiceItems.isNotEmpty)
                                TextButton(
                                  onPressed: viewModel.clearInvoice,
                                  child: const Text('Clear All',
                                      style: TextStyle(color: Colors.red)),
                                )
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (viewModel.invoiceItems.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.0),
                              child: Center(
                                child: Text(
                                  'Invoice cart is empty. Scan barcodes to add spares.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: viewModel.invoiceItems.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final item = viewModel.invoiceItems[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item.product.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      'Unit Price: ₹${item.product.price}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline,
                                            color: Colors.grey),
                                        onPressed: () =>
                                            viewModel.updateQuantity(
                                                item, item.quantity - 1),
                                      ),
                                      Text('${item.quantity}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline,
                                            color: AdminColors.primaryGreen),
                                        onPressed: () =>
                                            viewModel.updateQuantity(
                                                item, item.quantity + 1),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () =>
                                            viewModel.removeItem(item),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Split Allocator Block
                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Split Payment Allocator',
                              style: AdminTextStyles.sectionHeader
                                  .copyWith(fontSize: 14)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<PaymentMethod>(
                                  initialValue: viewModel.selectedMethod,
                                  decoration: const InputDecoration(
                                      labelText: 'Method',
                                      border: OutlineInputBorder()),
                                  items: PaymentMethod.values.map((method) {
                                    return DropdownMenuItem(
                                      value: method,
                                      child: Text(method.name.toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      viewModel.setSelectedMethod(val);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: viewModel.amountController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Amount (₹)',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: viewModel.referenceController,
                                  decoration: const InputDecoration(
                                      labelText:
                                          'Transaction/Ref ID (Required for UPI/Card)',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: viewModel.noteController,
                                  decoration: const InputDecoration(
                                      labelText: 'Audit Note',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Quick Fill Row
                          Wrap(
                            spacing: 8,
                            children: [
                              _quickFillButton(context, viewModel,
                                  'Pay Full Remaining', 'full'),
                              _quickFillButton(
                                  context, viewModel, '50% of Remaining', '50'),
                              _quickFillButton(
                                  context, viewModel, '25% of Remaining', '25'),
                              _quickFillButton(context, viewModel, 'Exact Cash',
                                  'exact_cash'),
                              _quickFillButton(
                                  context, viewModel, 'Clear Amount', 'clear'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: viewModel.clearAllPayments,
                                child: const Text('Clear Payments',
                                    style: TextStyle(color: Colors.red)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: viewModel.addPaymentAllocation,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Allocation'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              )
                            ],
                          ),
                          const Divider(height: 32),

                          // List of allocations
                          if (viewModel.payments.isEmpty)
                            const Center(
                                child: Text('No payment allocations added yet.',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 13)))
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: viewModel.payments.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final p = viewModel.payments[index];
                                final isUpi = p.method == PaymentMethod.upi;
                                final isCard =
                                    p.method == PaymentMethod.creditCard ||
                                        p.method == PaymentMethod.debitCard;
                                final hasRef = p.referenceNumber != null;
                                final refErr = (isUpi || isCard) && !hasRef;

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: AdminColors.primaryGreen
                                        .withValues(alpha: 0.12),
                                    child: Icon(_getPaymentIcon(p.method),
                                        color: AdminColors.primaryGreen,
                                        size: 18),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(p.method.name.toUpperCase(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      const SizedBox(width: 8),
                                      if (p.referenceNumber != null)
                                        Text('(${p.referenceNumber})',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                    ],
                                  ),
                                  subtitle: refErr
                                      ? const Text(
                                          'Missing Transaction/Reference ID!',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold))
                                      : (p.note != null
                                          ? Text(p.note!,
                                              style: const TextStyle(fontSize: 11))
                                          : null),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('₹${p.amount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 18),
                                        onPressed: () => viewModel
                                            .removePaymentAllocation(p),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column: Split Payment summaries & Complete button
              Expanded(
                child: Column(
                  children: [
                    // Client Details
                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Billing Client Profile',
                              style: AdminTextStyles.sectionHeader
                                  .copyWith(fontSize: 14)),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: viewModel.selectedCustomer,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8)),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Walk-in Guest',
                                  child: Text('Walk-in Guest')),
                              DropdownMenuItem(
                                  value: 'Ravi Kumar',
                                  child: Text('Ravi Kumar (Workshop)')),
                              DropdownMenuItem(
                                  value: 'Suresh EV Services',
                                  child: Text('Suresh EV (Workshop)')),
                              DropdownMenuItem(
                                  value: 'Anjali Sharma',
                                  child: Text('Anjali Sharma (Retail)')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                viewModel.setSelectedCustomer(val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Split Payment Metrics
                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('POS Calculations Summary',
                              style: AdminTextStyles.sectionHeader
                                  .copyWith(fontSize: 14)),
                          const SizedBox(height: 16),
                          _mathRow('Subtotal',
                              '₹${viewModel.subtotal.toStringAsFixed(2)}'),
                          _mathRow(
                              'CGST (${(viewModel.taxPercentage / 2).toStringAsFixed(1)}%)',
                              '₹${(viewModel.gstAmount / 2).toStringAsFixed(2)}'),
                          _mathRow(
                              'SGST (${(viewModel.taxPercentage / 2).toStringAsFixed(1)}%)',
                              '₹${(viewModel.gstAmount / 2).toStringAsFixed(2)}'),
                          _mathRow('Discounts Applied',
                              '-₹${viewModel.discount.toStringAsFixed(2)}',
                              color: Colors.green),
                          const Divider(height: 20),
                          _mathRow('Bill Total',
                              '₹${viewModel.billTotal.toStringAsFixed(2)}',
                              isBold: true),
                          _mathRow('Total Paid',
                              '₹${viewModel.totalPaid.toStringAsFixed(2)}',
                              isBold: true, color: AdminColors.primaryGreen),
                          _mathRow('Remaining Balance',
                              '₹${viewModel.remainingAmount.toStringAsFixed(2)}',
                              isBold: true,
                              color: viewModel.remainingAmount > 0
                                  ? Colors.red
                                  : Colors.grey),
                          _mathRow('Change to Return',
                              '₹${viewModel.changeAmount.toStringAsFixed(2)}',
                              isBold: true,
                              color: viewModel.changeAmount > 0
                                  ? Colors.green
                                  : Colors.grey),
                          const Divider(height: 24),

                          // Dynamic Warning Banners
                          if (viewModel.remainingAmount > 0)
                            _warningAlert(
                                '₹${viewModel.remainingAmount.toStringAsFixed(2)} remaining',
                                Colors.orange)
                          else if (viewModel.hasOverPaymentFailure)
                            _warningAlert(
                                'Overpayment NOT allowed for UPI/Card. Overpayment allowed only for cash.',
                                Colors.red)
                          else if (!viewModel.isReferencesValid)
                            _warningAlert(
                                'UPI/Card Transaction ID is required.',
                                Colors.red)
                          else if (viewModel.isFullyPaid)
                            _warningAlert(
                                'Payment completed. Change amount: ₹${viewModel.changeAmount.toStringAsFixed(2)}',
                                Colors.green),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: viewModel.canCompleteSale
                                  ? () => _showConfirmationDialog(
                                      context, viewModel)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminColors.primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Complete Sale & Cash Out',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _quickFillButton(BuildContext context, AdminBillingViewModel vm,
      String label, String action) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () => vm.quickFill(action),
      backgroundColor: AdminColors.isDarkTheme
          ? Colors.white10
          : Colors.black12.withValues(alpha: 0.04),
    );
  }

  Widget _mathRow(String label, String value,
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
                  fontSize: isBold ? 15 : 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }

  Widget _warningAlert(String msg, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        msg,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  IconData _getPaymentIcon(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.upi:
        return Icons.qr_code;
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.storeCredit:
        return Icons.stars;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  void _showConfirmationDialog(
      BuildContext context, AdminBillingViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Sale Checkout'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _confirmLine('Customer', viewModel.selectedCustomer),
                _confirmLine(
                    'Total Items', '${viewModel.invoiceItems.length} spares'),
                _confirmLine(
                    'Subtotal', '₹${viewModel.subtotal.toStringAsFixed(2)}'),
                _confirmLine(
                    'Discounts', '₹${viewModel.discount.toStringAsFixed(2)}'),
                _confirmLine(
                    'GST (${viewModel.taxPercentage.toStringAsFixed(0)}%)',
                    '₹${viewModel.gstAmount.toStringAsFixed(2)}'),
                const Divider(),
                _confirmLine(
                    'Grand Total', '₹${viewModel.billTotal.toStringAsFixed(2)}',
                    isBold: true),
                _confirmLine(
                    'Total Paid', '₹${viewModel.totalPaid.toStringAsFixed(2)}',
                    isBold: true, color: AdminColors.primaryGreen),
                _confirmLine('Change Return',
                    '₹${viewModel.changeAmount.toStringAsFixed(2)}',
                    isBold: true, color: Colors.green),
                const SizedBox(height: 16),
                const Text('Payment Breakdown:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                ...viewModel.payments.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.method.name.toUpperCase(),
                            style: const TextStyle(fontSize: 12)),
                        Text('₹${p.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final invoice = await viewModel.completeSale();
                if (invoice != null) {
                  _showInvoiceReceiptModal(context, viewModel, invoice);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to complete sale')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white),
              child: const Text('Confirm & Print Receipt'),
            )
          ],
        );
      },
    );
  }

  Widget _confirmLine(String label, String val,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }

  void _showInvoiceReceiptModal(BuildContext context,
      AdminBillingViewModel viewModel, Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final List<dynamic> items = invoice['items'] ?? [];
        final List<dynamic> payments = invoice['payments'] ?? [];

        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.electric_bolt_rounded,
                        color: Colors.green, size: 24),
                    SizedBox(width: 8),
                    Text('VoltSpare Receipt',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                const Center(
                    child: Text('In-store POS counter checkout receipt',
                        style: TextStyle(fontSize: 10, color: Colors.grey))),
                const Divider(height: 24),
                _confirmLine('Invoice Number', invoice['invoiceNumber']),
                _confirmLine('Customer Name', invoice['customerName']),
                _confirmLine('Date', invoice['dateStr']),
                const Divider(),
                const Text('Items Purchased:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text('${item['name']} x${item['quantity']}',
                                style: const TextStyle(fontSize: 12))),
                        Text(
                            '₹${(item['totalPrice'] as double).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }),
                const Divider(),
                _confirmLine('Grand Total',
                    '₹${(invoice['grandTotal'] as double).toStringAsFixed(2)}',
                    isBold: true),
                _confirmLine('Total Paid',
                    '₹${(invoice['amountPaid'] as double).toStringAsFixed(2)}',
                    isBold: true, color: AdminColors.primaryGreen),
                _confirmLine('Change Returned',
                    '₹${(invoice['changeReturned'] as double).toStringAsFixed(2)}',
                    isBold: true, color: Colors.green),
                const Divider(),
                const Text('Payment details:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                ...payments.map((p) {
                  return _confirmLine(p['method'].toString().toUpperCase(),
                      '₹${(p['amount'] as double).toStringAsFixed(2)}');
                }),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel/Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.print, size: 16),
                        onPressed: () {
                          printThermalReceiptWeb(
                            invoiceNum: invoice['invoiceNumber'],
                            customerName: invoice['customerName'],
                            dateStr: invoice['dateStr'],
                            subtotal: invoice['subtotal'],
                            gstAmount: invoice['gstAmount'],
                            discount: invoice['discount'],
                            grandTotal: invoice['grandTotal'],
                            amountPaid: invoice['amountPaid'],
                            changeReturned: invoice['changeReturned'],
                            items: List<Map<String, dynamic>>.from(items),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        label: const Text('Print Receipt'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPastBillsDialog(
      BuildContext context, AdminBillingViewModel viewModel) {
    viewModel.loadPastInvoices();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 800, maxHeight: 600),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('POS Billing History',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: viewModel.isBusy
                          ? const Center(child: CircularProgressIndicator())
                          : viewModel.pastInvoices.isEmpty
                              ? const Center(
                                  child: Text('No past invoices found.'))
                              : SingleChildScrollView(
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Invoice No')),
                                      DataColumn(label: Text('Customer')),
                                      DataColumn(label: Text('Date')),
                                      DataColumn(label: Text('Grand Total')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: viewModel.pastInvoices.map((inv) {
                                      final double total =
                                          inv['grandTotal'] as double;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(inv['invoiceNumber'])),
                                          DataCell(Text(inv['customerName'])),
                                          DataCell(Text(inv['dateStr'])),
                                          DataCell(Text(
                                              '₹${total.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.visibility_outlined,
                                                      size: 18),
                                                  onPressed: () {
                                                    _showInvoiceReceiptModal(
                                                        context,
                                                        viewModel,
                                                        inv);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.print,
                                                      size: 18),
                                                  onPressed: () {
                                                    printThermalReceiptWeb(
                                                      invoiceNum:
                                                          inv['invoiceNumber'],
                                                      customerName:
                                                          inv['customerName'],
                                                      dateStr: inv['dateStr'],
                                                      subtotal: inv['subtotal'],
                                                      gstAmount:
                                                          inv['gstAmount'],
                                                      discount: inv['discount'],
                                                      grandTotal:
                                                          inv['grandTotal'],
                                                      amountPaid:
                                                          inv['amountPaid'],
                                                      changeReturned:
                                                          inv['changeReturned'],
                                                      items: List<
                                                              Map<String,
                                                                  dynamic>>.from(
                                                          inv['items']),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  AdminBillingViewModel viewModelBuilder(BuildContext context) =>
      AdminBillingViewModel();
}
