import 'package:flutter/material.dart';
import 'package:posapp/storage/db_helper.dart';


class CategorySummaryPage extends StatefulWidget {
  const CategorySummaryPage({super.key});

  @override
  State<CategorySummaryPage> createState() => _CategorySummaryPageState();
}

class _CategorySummaryPageState extends State<CategorySummaryPage> {
  List<Map<String, dynamic>> summaryData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    final data = await DBHelper.getCategorySummary();
    setState(() {
      summaryData = data;
      print(summaryData);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
final totalOrders = summaryData.fold<int>(
  0,
  (sum, e) => sum + (e['orders'] ?? 0) as int,
);

final totalItems = summaryData.fold<int>(
  0,
  (sum, e) => sum + (e['item_count'] ?? 0) as int,
);

final totalNet = summaryData.fold<double>(
  0.0,
  (sum, e) => sum + ((e['net_amount'] ?? 0) as num).toDouble(),
);

final totalDiscount = summaryData.fold<double>(
  0.0,
  (sum, e) => sum + ((e['discount'] ?? 0) as num).toDouble(),
);

final totalTax = summaryData.fold<double>(
  0.0,
  (sum, e) => sum + ((e['tax'] ?? 0) as num).toDouble(),
);

final totalSales = summaryData.fold<double>(
  0.0,
  (sum, e) => sum + ((e['total_sale'] ?? 0) as num).toDouble(),
);


    return Scaffold(
      appBar: AppBar(title: const Text('Category Report')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
Row(
  children: [
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text("Columns"),
    ),
    const SizedBox(width: 10),
    ElevatedButton(
      onPressed: () {},
      child: const Text("Save Preference"),
    ),
  ],
),
 const SizedBox(height: 10),
                  _actionBar(),
                  const SizedBox(height: 12),
                  _headerRow(),
                  _columnHeaderRow(),
                  _dataRow(
                    isHeader: true,
                    data: {
                      'subitem_name': 'Total',
                      'orders': totalOrders,
                      'item_count': totalItems,
                      'net_amount': totalNet,
                      'discount': totalDiscount,
                      'tax': totalTax,
                      'total_sale': totalSales,
                      'percent': null,
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: summaryData.length,
                      itemBuilder: (context, index) {
                        final row = summaryData[index];
                        final percent = totalSales > 0
                            ? (row['total_sale'] as double) / totalSales * 100
                            : 0;
                        return _dataRow(
                          data: {
                            'subitem_name': row['subitem_name'],
                            'orders': row["orders"], // not tracked per row in DB
                            'item_count': row['item_count'],
                            'net_amount': row['net_amount'],
                            'discount': row['discount'],
                            'tax': row['tax'],
                            'total_sale': row['total_sale'],
                            'percent': percent,
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _actionBar() {
    return Row(
      children: [
        ElevatedButton(onPressed: () {}, child: const Text("🔍 Search")),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {},
          child: const Text("⚙️ Print Configuration"),
        ),
        const Spacer(),
       
        const SizedBox(width: 10),
        OutlinedButton(onPressed: () {}, child: const Text("Export Excel")),
        const SizedBox(width: 10),
        OutlinedButton(onPressed: () {}, child: const Text("Print")),
      ],
    );
  }

  Widget _headerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        "Category Report - ${DateTime.now().toString().substring(0, 10)}",
        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
      ),
    );
  }



Widget _columnHeaderRow() {
  const headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: Colors.white,
  );

  return Container(
    color: Colors.blue, // Header background color
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        _cell("Category", flex: 3, style: headerStyle),
        _cell("Orders", style: headerStyle),
        _cell("Items", style: headerStyle),
        _cell("Net Amount", style: headerStyle),
        _cell("Discount", style: headerStyle),
        _cell("Tax", style: headerStyle),
        _cell("Total Sales", style: headerStyle),
        _cell("%", style: headerStyle),
      ],
    ),
  );
}

  

  Widget _dataRow({required Map<String, dynamic> data, bool isHeader = false}) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: 14,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _cell(data['subitem_name']?.toString() ?? "", flex: 3, style: style),
          _cell(data['orders'].toString(), style: style),
          _cell(data['item_count'].toString(), style: style),
          _cell("₹${_format(data['net_amount'])}", style: style),
          _cell("₹${_format(data['discount'])}", style: style),
          _cell("₹${_format(data['tax'])}", style: style),
          _cell("₹${_format(data['total_sale'])}", style: style),
          _cell(
            data['percent'] != null
                ? "${(data['percent'] as double).toStringAsFixed(2)}%"
                : "-",
            style: style,
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, {int flex = 1, TextStyle? style}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }

  String _format(dynamic val) {
    if (val == null) return "0.00";
    return (val as num).toStringAsFixed(2);
  }
}
