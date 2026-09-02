import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_new_return_viewmodel.dart';

class AdminNewReturnView extends StackedView<AdminNewReturnViewModel> {
  final String? prefillBill;

  const AdminNewReturnView({Key? key, this.prefillBill}) : super(key: key);

  @override
  void onViewModelReady(AdminNewReturnViewModel viewModel) {
    viewModel.initialize(prefillBill);
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminNewReturnViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Initiate Return / Exchange',
      selectedItem: AdminNavigationItem.returnsExchanges,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            TextButton.icon(
              onPressed: () => viewModel.handleBack(),
              icon: Icon(Icons.arrow_back,
                  size: 16, color: AdminColors.textSecondary),
              label: Text('Back to Returns & Exchanges',
                  style: TextStyle(color: AdminColors.textSecondary)),
            ),
            const SizedBox(height: 12),

            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => viewModel.handleBack(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  tooltip: 'Back to Returns List',
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Return / Damage / Exchange',
                        style: AdminTextStyles.sectionHeader),
                    const SizedBox(height: 2),
                    Text(
                      'Search a bill, select actions per item, and submit case',
                      style: AdminTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar Card
            AdminPanelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Bill / Order',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter Bill Number, Invoice Number, Order ID, or Customer Phone',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: viewModel.searchController,
                          onSubmitted: (_) => viewModel.searchBill(),
                          decoration: InputDecoration(
                            hintText: 'e.g. INV-3408944 or ORD-782910 or 9876543210',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: viewModel.isBusy
                            ? null
                            : () => viewModel.searchBill(),
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Search Bill'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                      ),
                    ],
                  ),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bill Loaded View
            if (viewModel.bill != null) ...[
              _buildBillSummaryCard(viewModel.bill!),
              const SizedBox(height: 20),
              _buildItemProcessingSection(context, viewModel),
              const SizedBox(height: 20),
              _buildSubmissionCard(context, viewModel),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummaryCard(BillLookupResult bill) {
    return AdminPanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: AdminColors.primaryGreen),
                  const SizedBox(width: 8),
                  Text('Bill Details: ${bill.billNumber}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              AdminStatusChip(
                label: bill.orderStatus.toUpperCase(),
                color: Colors.green,
              ),
            ],
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 32,
            runSpacing: 12,
            children: [
              _infoTile('Order Number', bill.orderNumber),
              if (bill.invoiceNumber.isNotEmpty)
                _infoTile('Invoice Number', bill.invoiceNumber),
              _infoTile('Customer Name', bill.customerName),
              if (bill.customerPhone.isNotEmpty)
                _infoTile('Phone', bill.customerPhone),
              _infoTile('Order Date',
                  '${bill.orderDate.day}/${bill.orderDate.month}/${bill.orderDate.year}'),
              _infoTile('Payment',
                  '${bill.paymentMethod.toUpperCase()} (${bill.paymentStatus})'),
              _infoTile('Bill Total', '₹${bill.grandTotal.toStringAsFixed(2)}',
                  isHighlight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String val, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isHighlight ? AdminColors.primaryGreen : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildItemProcessingSection(
      BuildContext context, AdminNewReturnViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Purchased Items & Actions',
            style: AdminTextStyles.sectionHeader),
        const SizedBox(height: 4),
        const Text(
          'Select an action for each product. Unchanged items can remain "No Action".',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ...viewModel.itemForms.map((form) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildItemCard(context, viewModel, form),
          );
        }),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, AdminNewReturnViewModel viewModel,
      ItemFormState form) {
    final item = form.item;

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: form.action != AfterSalesAction.none
              ? AdminColors.primaryGreen.withValues(alpha: 0.5)
              : AdminColors.border,
          width: form.action != AfterSalesAction.none ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top line: product name, purchased, previously processed, available
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: item.image.isNotEmpty
                    ? Image.network(item.image, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.build, color: Colors.grey, size: 20))
                    : const Icon(Icons.build, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    if (item.sku.isNotEmpty)
                      Text('SKU: ${item.sku}',
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('Unit Price: ₹${item.unitPrice.toStringAsFixed(2)}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Purchased: ${item.purchasedQty}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white70)),
                  if (item.returnedQty > 0 ||
                      item.damagedQty > 0 ||
                      item.exchangedQty > 0)
                    Text(
                      'Prev: Ret ${item.returnedQty} | Dam ${item.damagedQty} | Exch ${item.exchangedQty}',
                      style: const TextStyle(fontSize: 10, color: Colors.orange),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.availableQty > 0
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Available: ${item.availableQty}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            item.availableQty > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // Action selector row
          Row(
            children: [
              const Text('Action: ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<AfterSalesAction>(
                value: form.action,
                dropdownColor: AdminColors.panelBackground,
                onChanged: item.availableQty <= 0
                    ? null
                    : (val) {
                        if (val != null) viewModel.setItemAction(form, val);
                      },
                items: AfterSalesAction.values.map((act) {
                  return DropdownMenuItem(
                    value: act,
                    child: Text(act.label),
                  );
                }).toList(),
              ),
              if (form.action != AfterSalesAction.none) ...[
                const SizedBox(width: 24),
                const Text('Quantity: ',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: form.quantity,
                  dropdownColor: AdminColors.panelBackground,
                  onChanged: (val) {
                    if (val != null) viewModel.setItemQuantity(form, val);
                  },
                  items: List.generate(
                          item.availableQty, (index) => index + 1)
                      .map((q) => DropdownMenuItem(
                            value: q,
                            child: Text(q.toString()),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),

          // Action-specific form sub-sections
          if (form.action == AfterSalesAction.returnAction)
            _buildReturnSubForm(context, viewModel, form)
          else if (form.action == AfterSalesAction.damage)
            _buildDamageSubForm(context, viewModel, form)
          else if (form.action == AfterSalesAction.exchange)
            _buildExchangeSubForm(context, viewModel, form),
        ],
      ),
    );
  }

  Widget _buildReturnSubForm(BuildContext context,
      AdminNewReturnViewModel viewModel, ItemFormState form) {
    final reasons = [
      'Wrong Product',
      'Incorrect Fitment',
      'Customer Changed Mind',
      'Product Not Required',
      'Quality Issue',
      'Product Defective',
      'Product Damaged',
      'Late Delivery',
      'Other',
    ];

    final conditions = [
      {'val': 'unused', 'label': 'Unused (Original)'},
      {'val': 'sealed', 'label': 'Sealed Pack'},
      {'val': 'opened', 'label': 'Opened / Inspected'},
      {'val': 'used', 'label': 'Used / Installed'},
      {'val': 'defective', 'label': 'Defective'},
      {'val': 'damaged', 'label': 'Damaged'},
      {'val': 'incomplete', 'label': 'Incomplete / Missing parts'},
    ];

    final dispositions = [
      {'val': 'sellable', 'label': 'Return to Sellable Stock (+stock)'},
      {'val': 'damaged', 'label': 'Return to Damaged Stock (no +stock)'},
      {'val': 'vendor', 'label': 'Send to Vendor'},
      {'val': 'scrap', 'label': 'Scrap item'},
      {'val': 'none', 'label': 'No Inventory Change'},
    ];

    final refundMethods = [
      'cash',
      'upi',
      'card',
      'bank_transfer',
      'original',
      'store_credit',
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Return Parameters',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: form.returnReason,
                  decoration: const InputDecoration(
                      labelText: 'Return Reason *',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: reasons
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) viewModel.setItemReturnReason(form, val);
                  },
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: form.condition,
                  decoration: const InputDecoration(
                      labelText: 'Item Condition *',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: conditions
                      .map((c) => DropdownMenuItem(
                          value: c['val'], child: Text(c['label']!)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) viewModel.setItemCondition(form, val);
                  },
                ),
              ),
              SizedBox(
                width: 250,
                child: DropdownButtonFormField<String>(
                  initialValue: form.inventoryDisposition,
                  decoration: const InputDecoration(
                      labelText: 'Inventory Action *',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: dispositions
                      .map((d) => DropdownMenuItem(
                          value: d['val'], child: Text(d['label']!)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) viewModel.setItemDisposition(form, val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: form.refundRequired,
                onChanged: (val) =>
                    viewModel.setItemRefundRequired(form, val ?? false),
              ),
              const Text('Issue Customer Refund',
                  style: TextStyle(fontSize: 13)),
              if (form.refundRequired) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    initialValue: form.refundMethod,
                    decoration: const InputDecoration(
                        labelText: 'Refund Method',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                    items: refundMethods
                        .map((m) => DropdownMenuItem(
                            value: m, child: Text(m.toUpperCase())))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) viewModel.setItemRefundMethod(form, val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Amount: ₹${form.originalValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                      fontSize: 13),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDamageSubForm(BuildContext context,
      AdminNewReturnViewModel viewModel, ItemFormState form) {
    final damageTypes = [
      {'val': 'physical', 'label': 'Physical Damage'},
      {'val': 'broken', 'label': 'Broken Part'},
      {'val': 'scratched', 'label': 'Scratched / Cosmetic'},
      {'val': 'electrical', 'label': 'Electrical Failure'},
      {'val': 'packaging', 'label': 'Packaging Damage'},
      {'val': 'missing_part', 'label': 'Missing Internal Part'},
      {'val': 'defect', 'label': 'Manufacturing Defect'},
      {'val': 'other', 'label': 'Other Damage'},
    ];

    final locations = [
      {'val': 'customer', 'label': 'Reported by Customer'},
      {'val': 'delivery', 'label': 'Delivery Transit'},
      {'val': 'store', 'label': 'In-store / Counter'},
      {'val': 'warehouse', 'label': 'Warehouse Intake'},
    ];

    final resolutions = [
      {'val': 'no_refund', 'label': 'Record Only (No Refund)'},
      {'val': 'refund', 'label': 'Issue Refund'},
      {'val': 'replacement', 'label': 'Warranty Replacement'},
      {'val': 'vendor_claim', 'label': 'Vendor Warranty Claim'},
      {'val': 'scrap', 'label': 'Scrap Defective Item'},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Damage Inspection & Resolution',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: form.damageType,
                  decoration: const InputDecoration(
                      labelText: 'Damage Classification *',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: damageTypes
                      .map((d) => DropdownMenuItem(
                          value: d['val'], child: Text(d['label']!)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) viewModel.setItemDamageType(form, val);
                  },
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: form.damageDiscoveredAt,
                  decoration: const InputDecoration(
                      labelText: 'Discovered At *',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: locations
                      .map((l) => DropdownMenuItem(
                          value: l['val'], child: Text(l['label']!)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      viewModel.setItemDamageDiscoveredAt(form, val);
                    }
                  },
                ),
              ),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  initialValue: form.damageResolution,
                  decoration: const InputDecoration(
                      labelText: 'Damage Resolution *',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: resolutions
                      .map((r) => DropdownMenuItem(
                          value: r['val'], child: Text(r['label']!)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      viewModel.setItemDamageResolution(form, val);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeSubForm(BuildContext context,
      AdminNewReturnViewModel viewModel, ItemFormState form) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product Exchange Specification',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ProductModel>(
                  initialValue: form.replacementProduct,
                  decoration: const InputDecoration(
                    labelText: 'Select Replacement Product from Database *',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  dropdownColor: AdminColors.panelBackground,
                  items: viewModel.allProducts.map((p) {
                    final stockStr = p.stockCount.toString();
                    return DropdownMenuItem(
                      value: p,
                      child: Text(
                        '${p.name} (₹${p.price.toStringAsFixed(0)} - Stock: $stockStr)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (prod) =>
                      viewModel.setItemReplacementProduct(form, prod),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<int>(
                  initialValue: form.replacementQuantity,
                  decoration: const InputDecoration(
                    labelText: 'Repl. Qty *',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  dropdownColor: AdminColors.panelBackground,
                  items: [1, 2, 3, 4, 5]
                      .map((q) => DropdownMenuItem(
                            value: q,
                            child: Text(q.toString()),
                          ))
                      .toList(),
                  onChanged: (q) {
                    if (q != null) viewModel.setItemReplacementQuantity(form, q);
                  },
                ),
              ),
            ],
          ),
          if (form.replacementProduct != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Original Value: ₹${form.originalValue.toStringAsFixed(2)} | Replacement Value: ₹${form.replacementValue.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  if (form.exchangeDifference > 0)
                    Text(
                      'Customer Pays: ₹${form.exchangeDifference.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent),
                    )
                  else if (form.exchangeDifference < 0)
                    Text(
                      'Refund Due: ₹${form.exchangeDifference.abs().toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    )
                  else
                    const Text(
                      'Even Exchange (₹0 Difference)',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(
      BuildContext context, AdminNewReturnViewModel viewModel) {
    return AdminPanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Case Summary & Actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items Configured: ${viewModel.configuredItemsCount}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if (viewModel.calculatedTotalRefund > 0)
                    Text(
                      'Total Refund to Customer: ₹${viewModel.calculatedTotalRefund.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    ),
                  if (viewModel.calculatedTotalPayable > 0)
                    Text(
                      'Total Payable by Customer: ₹${viewModel.calculatedTotalPayable.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent),
                    ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: viewModel.canSubmit
                    ? () => viewModel.submitCase(context)
                    : null,
                icon: viewModel.isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: Text(viewModel.isBusy
                    ? 'Processing...'
                    : 'Submit Return / Exchange Case'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: viewModel.adminNotesController,
            decoration: const InputDecoration(
              labelText: 'Internal Admin Notes (Optional)',
              hintText: 'Add inspection details or notes for audit trail...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  @override
  AdminNewReturnViewModel viewModelBuilder(BuildContext context) =>
      AdminNewReturnViewModel();
}
