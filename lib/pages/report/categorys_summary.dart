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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Category Report',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildStatsCards(totalOrders, totalItems, totalSales),
                  const SizedBox(height: 20),
                  _buildControlPanel(),
                  const SizedBox(height: 20),
                  _buildReportTable(totalOrders, totalItems, totalNet,
                      totalDiscount, totalTax, totalSales),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsCards(int totalOrders, int totalItems, double totalSales) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Orders',
            totalOrders.toString(),
            Icons.shopping_cart_outlined,
            const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Items',
            totalItems.toString(),
            Icons.inventory_2_outlined,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Sales',
            '₹${_format(totalSales)}',
            Icons.trending_up,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildActionButton(
                'Columns',
                Icons.view_column,
                const Color(0xFFEF4444),
                () {},
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                'Save Preference',
                Icons.bookmark_outline,
                const Color(0xFF6B7280),
                () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionButton(
                'Search',
                Icons.search,
                const Color(0xFF3B82F6),
                () {},
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                'Print Config',
                Icons.settings_outlined,
                const Color(0xFF8B5CF6),
                () {},
              ),
              const Spacer(),
              _buildOutlinedButton('Export Excel', Icons.file_download, () {}),
              const SizedBox(width: 12),
              _buildOutlinedButton('Print', Icons.print, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
      String text, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF6B7280),
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildReportTable(int totalOrders, int totalItems, double totalNet,
      double totalDiscount, double totalTax, double totalSales) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Category Report",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateTime.now().toString().substring(0, 10),
                    style: TextStyle(
                      color: Colors.blue.shade100,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildTableHeader(),
            _buildTotalRow(totalOrders, totalItems, totalNet, totalDiscount,
                totalTax, totalSales),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: summaryData.length,
                itemBuilder: (context, index) {
                  final row = summaryData[index];
                  final percent = totalSales > 0
                      ? (row['total_sale'] as double) / totalSales * 100
                      : 0;
                  return _buildDataRow(
                    data: {
                      'subitem_name': row['subitem_name'],
                      'orders': row["orders"],
                      'item_count': row['item_count'],
                      'net_amount': row['net_amount'],
                      'discount': row['discount'],
                      'tax': row['tax'],
                      'total_sale': row['total_sale'],
                      'percent': percent,
                    },
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: Color(0xFF374151),
    );

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _buildHeaderCell("Category", flex: 3, style: headerStyle),
          _buildHeaderCell("Orders", style: headerStyle),
          _buildHeaderCell("Items", style: headerStyle),
          _buildHeaderCell("Net Amount", style: headerStyle),
          _buildHeaderCell("Discount", style: headerStyle),
          _buildHeaderCell("Tax", style: headerStyle),
          _buildHeaderCell("Total Sales", style: headerStyle),
          _buildHeaderCell("%", style: headerStyle),
        ],
      ),
    );
  }

  Widget _buildTotalRow(int totalOrders, int totalItems, double totalNet,
      double totalDiscount, double totalTax, double totalSales) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell("Total", flex: 3, isBold: true),
          _buildDataCell(totalOrders.toString(), isBold: true),
          _buildDataCell(totalItems.toString(), isBold: true),
          _buildDataCell("₹${_format(totalNet)}", isBold: true),
          _buildDataCell("₹${_format(totalDiscount)}", isBold: true),
          _buildDataCell("₹${_format(totalTax)}", isBold: true),
          _buildDataCell("₹${_format(totalSales)}", isBold: true),
          _buildDataCell("100%", isBold: true),
        ],
      ),
    );
  }

  Widget _buildDataRow({required Map<String, dynamic> data, required int index}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFAFAFA),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(data['subitem_name']?.toString() ?? "", flex: 3),
          _buildDataCell(data['orders'].toString()),
          _buildDataCell(data['item_count'].toString()),
          _buildDataCell("₹${_format(data['net_amount'])}"),
          _buildDataCell("₹${_format(data['discount'])}"),
          _buildDataCell("₹${_format(data['tax'])}"),
          _buildDataCell("₹${_format(data['total_sale'])}"),
          _buildDataCell(
            data['percent'] != null
                ? "${(data['percent'] as double).toStringAsFixed(1)}%"
                : "-",
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1, TextStyle? style}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text, {int flex = 1, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: const Color(0xFF374151),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _format(dynamic val) {
    if (val == null) return "0.00";
    return (val as num).toStringAsFixed(2);
  }
}