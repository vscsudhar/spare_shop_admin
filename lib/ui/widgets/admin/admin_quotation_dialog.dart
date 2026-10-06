import 'package:flutter/material.dart';
import 'package:spare_shop_admin/core/models/bulk_quotation_model.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/app_strings.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_invoice_dialog.dart';

class AdminQuotationDialog extends StatelessWidget {
  final BulkQuotationModel quotation;
  final VoidCallback? onConvertToInvoice;

  const AdminQuotationDialog({
    Key? key,
    required this.quotation,
    this.onConvertToInvoice,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    BulkQuotationModel quotation, {
    VoidCallback? onConvertToInvoice,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AdminQuotationDialog(
        quotation: quotation,
        onConvertToInvoice: onConvertToInvoice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AdminColors.isDarkTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: 960,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Modal Action Bar
            _buildTopActionBar(context),

            // Scrollable A4 Document View
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Center(
                  child: Container(
                    width: 820,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF1E293B),
                        fontSize: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeaderSection(),
                          const SizedBox(height: 20),
                          _buildCustomerSection(),
                          const SizedBox(height: 20),
                          _buildItemsTable(),
                          const SizedBox(height: 16),
                          _buildTotalsAndSummarySection(),
                          const SizedBox(height: 24),
                          _buildFooterSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_outlined, color: Colors.blueAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Quotation ${quotation.quotationNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: quotation.isConverted
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quotation.isConverted ? 'CONVERTED TO INVOICE' : 'B2B QUOTATION',
                          style: TextStyle(
                            color: quotation.isConverted ? Colors.greenAccent : Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Customer: ${quotation.customerName} ${quotation.customerGst.isNotEmpty ? '• GST: ${quotation.customerGst}' : ''}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (!quotation.isConverted && onConvertToInvoice != null) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConvertToInvoice!();
                  },
                  icon: const Icon(Icons.transform, size: 16),
                  label: const Text('Convert to Tax Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 10),
              ] else if (quotation.isConverted) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    final invoice = quotation.toInvoiceModel();
                    AdminInvoiceDialog.show(context, invoice);
                  },
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('View Tax Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.electric_bolt, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      VoltSpareBusinessConfig.storeName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  VoltSpareBusinessConfig.legalEntityName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const Text(
                  '${VoltSpareBusinessConfig.defaultAddressLine1}, ${VoltSpareBusinessConfig.defaultCity} - ${VoltSpareBusinessConfig.defaultPincode}',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
                const Text(
                  'GSTIN: ${VoltSpareBusinessConfig.defaultGstin} | State: ${VoltSpareBusinessConfig.defaultState} (Code: ${VoltSpareBusinessConfig.defaultStateCode})',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
                const Text(
                  'Phone: ${VoltSpareBusinessConfig.supportPhone} | Email: ${VoltSpareBusinessConfig.billingEmail}',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'PROFORMA / B2B QUOTATION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _metaRow('Quotation No:', quotation.quotationNumber, isBold: true),
                  _metaRow('Date:', '${quotation.createdAt.day.toString().padLeft(2, '0')}/${quotation.createdAt.month.toString().padLeft(2, '0')}/${quotation.createdAt.year}'),
                  _metaRow('Status:', quotation.status),
                  if (quotation.invoiceNumber != null && quotation.invoiceNumber!.isNotEmpty)
                    _metaRow('Invoice Linked:', quotation.invoiceNumber!, isBold: true),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFCBD5E1), thickness: 1.5),
      ],
    );
  }

  Widget _metaRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QUOTATION ISSUED TO (CUSTOMER DETAILS)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  quotation.businessName.isNotEmpty
                      ? '${quotation.businessName} (${quotation.customerName})'
                      : quotation.customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  'Phone: ${quotation.customerPhone}',
                  style: const TextStyle(color: Color(0xFF334155), fontSize: 11),
                ),
                if (quotation.customerEmail.isNotEmpty)
                  Text(
                    'Email: ${quotation.customerEmail}',
                    style: const TextStyle(color: Color(0xFF334155), fontSize: 11),
                  ),
                Text(
                  'Address: ${quotation.customerAddress.isNotEmpty ? quotation.customerAddress : 'Customer Workshop / Retail Counter'}',
                  style: const TextStyle(color: Color(0xFF334155), fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CUSTOMER GSTIN / TAX ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(
                  quotation.customerGst.isNotEmpty ? quotation.customerGst : 'URP (Unregistered Person)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: quotation.customerGst.isNotEmpty ? const Color(0xFF0F172A) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.6), // S.No
          1: FlexColumnWidth(3.0), // Item
          2: FlexColumnWidth(1.0), // HSN
          3: FlexColumnWidth(0.8), // Qty
          4: FlexColumnWidth(1.2), // Rate Tier
          5: FlexColumnWidth(1.2), // Unit Rate
          6: FlexColumnWidth(1.2), // Taxable
          7: FlexColumnWidth(0.9), // GST %
          8: FlexColumnWidth(1.4), // Line Total
        },
        children: [
          // Table Header
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
            children: [
              _th('#'),
              _th('Item Description / SKU'),
              _th('HSN Code'),
              _th('Qty', align: TextAlign.right),
              _th('Price Tier'),
              _th('Unit Price (₹)', align: TextAlign.right),
              _th('Taxable (₹)', align: TextAlign.right),
              _th('GST %', align: TextAlign.right),
              _th('Total (₹)', align: TextAlign.right),
            ],
          ),
          // Items
          ...quotation.items.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value;
            final isEven = entry.key % 2 == 0;

            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? Colors.white : const Color(0xFFF8FAFC),
              ),
              children: [
                _td('$idx', align: TextAlign.center),
                _tdCustom(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
                      if (item.partNumber.isNotEmpty)
                        Text('Part No: ${item.partNumber}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                _td(item.hsnCode, align: TextAlign.center),
                _td('${item.quantity}', align: TextAlign.right),
                _td(item.priceTier.shortName, align: TextAlign.center),
                _td('₹${item.unitPrice.toStringAsFixed(2)}', align: TextAlign.right),
                _td('₹${item.totalTaxable.toStringAsFixed(2)}', align: TextAlign.right),
                _td('${item.gstRate.toStringAsFixed(0)}%', align: TextAlign.right),
                _td('₹${item.grandTotal.toStringAsFixed(2)}', align: TextAlign.right, isBold: true),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _th(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _td(String text, {TextAlign align = TextAlign.left, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _tdCustom(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: child,
    );
  }

  Widget _buildTotalsAndSummarySection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notes / Validity Box
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quotation Notes & Conditions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 4),
                Text(quotation.notes, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Totals Box
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _totalRow('Subtotal (Taxable):', '₹${quotation.subtotal.toStringAsFixed(2)}'),
                _totalRow('CGST (9%):', '₹${(quotation.totalTax / 2).toStringAsFixed(2)}'),
                _totalRow('SGST (9%):', '₹${(quotation.totalTax / 2).toStringAsFixed(2)}'),
                const Divider(color: Color(0xFFCBD5E1), height: 12),
                _totalRow('Grand Total (INR):', '₹${quotation.grandTotal.toStringAsFixed(2)}', isGrand: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, String value, {bool isGrand = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrand ? 12 : 11,
              fontWeight: isGrand ? FontWeight.bold : FontWeight.w500,
              color: isGrand ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isGrand ? 14 : 11,
              fontWeight: FontWeight.bold,
              color: isGrand ? const Color(0xFF10B981) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        const Divider(color: Color(0xFFCBD5E1)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thank you for your business!',
              style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B), fontSize: 11),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('For VoltSpare Solutions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 24),
                Text('Authorized Signatory', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
