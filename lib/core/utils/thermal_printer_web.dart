import 'dart:html' as html;

void printThermalReceiptWeb({
  required String invoiceNum,
  required String customerName,
  required String dateStr,
  required double subtotal,
  required double gstAmount,
  required double discount,
  required double grandTotal,
  required double amountPaid,
  required double changeReturned,
  required List<Map<String, dynamic>> items,
}) {
  final itemsHtml = items.map((item) => '''
    <tr>
      <td style="max-width: 32mm; word-wrap: break-word;">${item['name']}</td>
      <td class="text-right">${item['quantity']}</td>
      <td class="text-right">₹${item['unitPrice'].toStringAsFixed(2)}</td>
      <td class="text-right">₹${item['totalPrice'].toStringAsFixed(2)}</td>
    </tr>
  ''').join('');

  final htmlContent = '''
    <html>
      <head>
        <title>Receipt $invoiceNum</title>
        <style>
          body {
            font-family: 'Courier New', Courier, monospace;
            width: 72mm; /* standard 3-inch/80mm thermal printer width */
            margin: 0 auto;
            padding: 5px;
            font-size: 11px;
            color: #000;
          }
          .header { text-align: center; margin-bottom: 8px; }
          .title { font-size: 14px; font-weight: bold; }
          .divider { border-top: 1px dashed #000; margin: 6px 0; }
          .item-table { width: 100%; border-collapse: collapse; }
          .item-table th { text-align: left; font-size: 10px; border-bottom: 1px dashed #000; padding-bottom: 4px; }
          .item-table td { padding: 3px 0; vertical-align: top; }
          .text-right { text-align: right; }
          .totals { width: 100%; margin-top: 6px; }
          .totals td { padding: 2px 0; }
          .footer { text-align: center; margin-top: 15px; font-size: 9px; }
          @media print {
            body { margin: 0; padding: 0; width: 72mm; }
            @page { margin: 0; size: auto; }
          }
        </style>
      </head>
      <body>
        <div class="header">
          <span class="title">VOLTSPARE AUTOMOTIVE</span><br>
          <span>GST: 33AAAAA1111A1Z1</span><br>
          <span>Ph: +91 99000 88000</span>
        </div>
        <div class="divider"></div>
        <div>
          <span>Date: $dateStr</span><br>
          <span>Invoice: $invoiceNum</span><br>
          <span>Customer: $customerName</span>
        </div>
        <div class="divider"></div>
        <table class="item-table">
          <thead>
            <tr>
              <th>Item</th>
              <th class="text-right">Qty</th>
              <th class="text-right">Price</th>
              <th class="text-right">Total</th>
            </tr>
          </thead>
          <tbody>
            $itemsHtml
          </tbody>
        </table>
        <div class="divider"></div>
        <table class="totals">
          <tr>
            <td>Subtotal:</td>
            <td class="text-right">₹${subtotal.toStringAsFixed(2)}</td>
          </tr>
          <tr>
            <td>GST:</td>
            <td class="text-right">₹${gstAmount.toStringAsFixed(2)}</td>
          </tr>
          <tr>
            <td>Discount:</td>
            <td class="text-right">-₹${discount.toStringAsFixed(2)}</td>
          </tr>
          <tr style="font-weight: bold; border-top: 1px dashed #000;">
            <td>Grand Total:</td>
            <td class="text-right">₹${grandTotal.toStringAsFixed(2)}</td>
          </tr>
          <tr style="border-top: 1px dashed #000;">
            <td>Amount Paid:</td>
            <td class="text-right">₹${amountPaid.toStringAsFixed(2)}</td>
          </tr>
          <tr>
            <td>Change:</td>
            <td class="text-right">₹${changeReturned.toStringAsFixed(2)}</td>
          </tr>
        </table>
        <div class="divider"></div>
        <div class="footer">
          <span>Thank you for your purchase!</span><br>
          <span>Powered by VoltSpare</span>
        </div>
        <script>
          window.onload = function() {
            window.print();
            setTimeout(function() { window.close(); }, 500);
          }
        </script>
      </body>
    </html>
  ''';

  final printWindow = html.window.open('', '_blank', 'width=450,height=600');
  if (printWindow is html.Window) {
    final doc = printWindow.document as html.HtmlDocument;
    doc.body?.setInnerHtml(
      htmlContent,
      treeSanitizer: html.NodeTreeSanitizer.trusted,
    );
    // Trigger print
    printWindow.print();
    // Close window after printing
    Future.delayed(const Duration(milliseconds: 500), () {
      printWindow.close();
    });
  }
}
