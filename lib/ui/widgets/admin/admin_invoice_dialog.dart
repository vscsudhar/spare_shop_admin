import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spare_shop_admin/core/services/invoice_service.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';

class AdminInvoiceDialog extends StatelessWidget {
  final InvoiceModel invoice;

  const AdminInvoiceDialog({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  static Future<void> show(BuildContext context, InvoiceModel invoice) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AdminInvoiceDialog(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoiceService = InvoiceService();
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
            _buildTopActionBar(context, invoiceService),

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
                          // 1. Business Header & Invoice Meta
                          _buildHeaderSection(),
                          const SizedBox(height: 20),

                          // 2. Customer & Dispatch Details Box
                          _buildCustomerAndDispatchSection(),
                          const SizedBox(height: 20),

                          // 3. Product Line Items Table
                          _buildItemsTable(),
                          const SizedBox(height: 16),

                          // 4. Amount in Words & Totals Breakdown
                          _buildTotalsAndSummarySection(),
                          const SizedBox(height: 24),

                          // 5. Terms & Conditions + Authorized Signatory
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

  Widget _buildTopActionBar(BuildContext context, InvoiceService service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AdminColors.primaryGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AdminColors.primaryGreen.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long, color: AdminColors.primaryGreen, size: 16),
                const SizedBox(width: 6),
                Text(
                  invoice.invoiceNumber,
                  style: TextStyle(
                    color: AdminColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Copy Invoice ID',
            icon: const Icon(Icons.copy, color: Colors.white70, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: invoice.invoiceNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied ${invoice.invoiceNumber} to clipboard!'),
                  backgroundColor: AdminColors.primaryGreen,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => service.printInvoice(invoice),
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Print / Save PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => service.downloadInvoiceFile(invoice),
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download HTML'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white70, size: 18),
            tooltip: 'Open Full Page in New Tab',
            onPressed: () => service.openInvoiceInNewTab(invoice),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    final b = invoice.business;
    final dateStr = invoice.invoiceDate.toString().substring(0, 10);
    final orderDateStr = invoice.orderDate.toString().substring(0, 10);

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Business Name & Contact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F9F59),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      b.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(b.legalName,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Builder(
                  builder: (context) {
                    final street = [b.addressLine1, b.addressLine2]
                        .where((s) => s.trim().isNotEmpty)
                        .join(', ');
                    final cityState = [b.city, b.state]
                        .where((s) => s.trim().isNotEmpty)
                        .join(', ');
                    final pin =
                        b.pincode.trim().isNotEmpty ? ' - ${b.pincode.trim()}' : '';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (street.isNotEmpty)
                          Text(street,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF334155))),
                        if (cityState.isNotEmpty || pin.isNotEmpty)
                          Text('$cityState$pin',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF334155))),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                    children: [
                      const TextSpan(
                          text: 'GSTIN: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${b.gstin}   '),
                      const TextSpan(
                          text: 'PAN: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: b.pan),
                    ],
                  ),
                ),
                Text('Email: ${b.email} | Phone: ${b.phone}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),

          // Right: Tax Invoice Badge & Meta
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'TAX INVOICE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _metaKeyValue('Invoice No:', invoice.invoiceNumber, isBold: true),
              _metaKeyValue('Invoice Date:', dateStr),
              _metaKeyValue('Order No:', invoice.orderNumber, isBold: true),
              _metaKeyValue('Order Date:', orderDateStr),
              _metaKeyValue('Payment Mode:', invoice.paymentMethod),
              _metaKeyValue(
                  'Place of Supply:', '${invoice.customer.state} (${invoice.customer.stateCode})'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaKeyValue(String key, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(key,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          Text(
            val,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAndDispatchSection() {
    final c = invoice.customer;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Billed To / Customer
        Expanded(
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
                const Text(
                  'BILLED TO & SHIPPED TO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const Divider(height: 12, color: Color(0xFFE2E8F0)),
                Text(c.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(c.address,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
                if (c.city.isNotEmpty)
                  Text('${c.city}, ${c.state} (Code: ${c.stateCode})',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF334155))),
                const SizedBox(height: 4),
                Text('Phone: ${c.phone}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155))),
                Text('GSTIN: ${c.gstin}',
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Dispatch & Fulfillment Meta
        Expanded(
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
                const Text(
                  'DISPATCH & FULFILLMENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const Divider(height: 12, color: Color(0xFFE2E8F0)),
                _detailLine('Fulfillment Hub',
                    invoice.fulfillmentHub ?? 'Central Dispatch Hub'),
                _detailLine('Sales Channel',
                    invoice.channel == 'pos' ? 'Store POS' : 'Mobile App'),
                _detailLine('Order Status', invoice.orderStatus),
                _detailLine('Payment Status', invoice.paymentStatus),
                _detailLine('Reverse Charge', 'No (Normal Forward Charge)'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          Text(value,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    final isIntraState = invoice.summary.isIntraState;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(35),
          1: FlexColumnWidth(4),
          2: FixedColumnWidth(60),
          3: FixedColumnWidth(45),
          4: FixedColumnWidth(85),
          5: FixedColumnWidth(85),
          6: FixedColumnWidth(75),
          7: FixedColumnWidth(75),
          8: FixedColumnWidth(90),
        },
        border: TableBorder.all(color: const Color(0xFFE2E8F0), width: 1),
        children: [
          // Table Header
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
            children: [
              _th('#', align: TextAlign.center),
              _th('Item Description & SKU'),
              _th('HSN', align: TextAlign.center),
              _th('Qty', align: TextAlign.center),
              _th('Unit Price', align: TextAlign.right),
              _th('Taxable Val', align: TextAlign.right),
              _th('CGST', align: TextAlign.right),
              _th(isIntraState ? 'SGST' : 'IGST', align: TextAlign.right),
              _th('Total (₹)', align: TextAlign.right),
            ],
          ),

          // Table Items
          ...invoice.items.map((item) {
            final cgstStr = isIntraState
                ? '₹${item.cgstAmount.toStringAsFixed(2)}\n(${item.cgstRate}%)'
                : '-';
            final sgstOrIgstStr = isIntraState
                ? '₹${item.sgstAmount.toStringAsFixed(2)}\n(${item.sgstRate}%)'
                : '₹${item.igstAmount.toStringAsFixed(2)}\n(${item.igstRate}%)';

            return TableRow(
              children: [
                _td('${item.sNo}', align: TextAlign.center),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text('SKU: ${item.sku}',
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                _td(item.hsnCode, align: TextAlign.center),
                _td('${item.quantity}', align: TextAlign.center),
                _td('₹${item.unitPrice.toStringAsFixed(2)}',
                    align: TextAlign.right),
                _td('₹${item.taxableValue.toStringAsFixed(2)}',
                    align: TextAlign.right),
                _td(cgstStr, align: TextAlign.right),
                _td(sgstOrIgstStr, align: TextAlign.right),
                _td('₹${item.total.toStringAsFixed(2)}',
                    align: TextAlign.right, isBold: true),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _th(String label, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _td(String label,
      {TextAlign align = TextAlign.left, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        label,
        textAlign: align,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildTotalsAndSummarySection() {
    final s = invoice.summary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Amount in Words & Notes
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: const Border(
                      left: BorderSide(color: Color(0xFF0F9F59), width: 3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amount in Words:',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    Text(
                      s.amountInWords,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        color: Color(0xFF0F9F59), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GST Paid Tax Invoice verified under CGST / SGST / IGST Act 2017.',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // Right: Summary Table
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _summaryLine('Taxable Subtotal',
                    '₹${s.taxableAmount.toStringAsFixed(2)}'),
                if (s.isIntraState) ...[
                  _summaryLine(
                      'Central Tax (CGST)', '₹${s.totalCgst.toStringAsFixed(2)}'),
                  _summaryLine(
                      'State Tax (SGST)', '₹${s.totalSgst.toStringAsFixed(2)}'),
                ] else ...[
                  _summaryLine('Integrated Tax (IGST)',
                      '₹${s.totalIgst.toStringAsFixed(2)}'),
                ],
                if (s.deliveryCharges > 0)
                  _summaryLine('Delivery / Freight',
                      '₹${s.deliveryCharges.toStringAsFixed(2)}'),
                if (s.totalDiscount > 0)
                  _summaryLine('Discount',
                      '-₹${s.totalDiscount.toStringAsFixed(2)}',
                      textColor: Colors.red),
                const Divider(color: Color(0xFF0F172A), thickness: 1.5, height: 16),
                _summaryLine(
                  'Grand Total',
                  '₹${s.grandTotal.toStringAsFixed(2)}',
                  isBold: true,
                  fontSize: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryLine(String label, String value,
      {bool isBold = false, double fontSize = 11, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B))),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: textColor ?? (isBold ? const Color(0xFF0F172A) : const Color(0xFF1E293B)))),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Terms & Conditions
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Terms & Conditions:',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569))),
              const SizedBox(height: 4),
              ...invoice.terms.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF64748B))),
                        Expanded(
                          child: Text(t,
                              style: const TextStyle(
                                  fontSize: 9.5, color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Signature Box
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('For ${invoice.business.name}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 36),
              Container(
                width: 160,
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF0F172A))),
                ),
                padding: const EdgeInsets.only(top: 4),
                child: const Text(
                  'Authorized Signatory',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
