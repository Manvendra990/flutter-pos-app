import 'package:flutter/cupertino.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PrinterHelper {
  /// Prints the POS bill
  static Future<void> printReceipt({
    required Map<String, Map<String, dynamic>> cartItems,
    String shopName = "My POS Shop",
    String address = "",
    String maddres = "",
    String contact = "",
    String FSSAINo = "",
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // 👈 80mm thermal printer
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Shop Name
              pw.Center(
                child: pw.Text(
                  shopName,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              if (address.isNotEmpty)
                pw.Center(child: pw.Text(" $address", style: pw.TextStyle(fontSize: 10))),
              pw.SizedBox(height: 5),
               pw.Center(child: pw.Text(" $maddres", style: pw.TextStyle(fontSize: 10))),
              pw.SizedBox(height: 5),
               pw.Center(child: pw.Text(" $contact", style: pw.TextStyle(fontSize: 10))),
              pw.SizedBox(height: 5),
               pw.Center(child: pw.Text(" $FSSAINo", style: pw.TextStyle(fontSize: 10))),
              pw.SizedBox(height: 5),
              pw.Text("Date: ${DateTime.now()}",
                  style: pw.TextStyle(fontSize: 10)),
              pw.Divider(),

              // Table Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(flex: 4, child: pw.Text("Item", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  pw.Expanded(flex: 1, child: pw.Text("Qty", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  pw.Expanded(flex: 2, child: pw.Text("Price", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.Divider(),

              // Items List
              ...cartItems.entries.map((entry) {
                final name = entry.value['name'] ?? '';
                final qty = entry.value['qty'] ?? 0;
                final price = entry.value['price'] ?? 0;

                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(flex: 4, child: pw.Text(name, style: pw.TextStyle(fontSize: 10))),
                    pw.Expanded(flex: 1, child: pw.Text(qty.toString(), style: pw.TextStyle(fontSize: 10))),
                    pw.Expanded(flex: 2, child: pw.Text("₹${price.toString()}", style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                  ],
                );
              }),

              pw.Divider(),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(
                    "₹${cartItems.values.fold(0, (sum, item) => sum + ((item['qty'] * item['price']) as int))}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              pw.Center(child: pw.Text("Thank You! Visit Again", style: pw.TextStyle(fontSize: 10))),
            ],
          );
        },
      ),
    );

    // Print or Preview
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
