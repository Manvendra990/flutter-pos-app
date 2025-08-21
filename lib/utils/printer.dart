import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterHelper {
  /// Prints the POS bill
  static Future<void> printReceipt({
    required Map<String, Map<String, dynamic>> cartItems,
    String shopName = "My POS Shop",
    String gstNumber = "",
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(shopName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              if (gstNumber.isNotEmpty) pw.Text("GST No: $gstNumber"),
              pw.Text("Date: ${DateTime.now()}"),
              pw.Divider(),

              // Table Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Item", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text("Qty", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text("Price", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(),

              // Items
              ...cartItems.entries.map((entry) {
                final name = entry.value['name'] ?? '';
                final qty = entry.value['qty'] ?? 0;
                final price = entry.value['price'] ?? 0;
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(name),
                    pw.Text(qty.toString()),
                    pw.Text("₹${price.toString()}"),
                  ],
                );
              }),

              pw.Divider(),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    // "₹${cartItems.values.fold(0, (sum, item) => sum + (item['qty'] * item['price']))}",
                    "23333",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Print Preview
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
