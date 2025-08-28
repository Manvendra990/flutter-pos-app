import 'package:flutter/material.dart';

class ItemSummary extends StatefulWidget {
  const ItemSummary({super.key});

  @override
  State<ItemSummary> createState() => _ItemSummaryState();
}

class _ItemSummaryState extends State<ItemSummary>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedFilterIndex = 0;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Reports & Analytics",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E3440),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2E3440),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF88C0D0),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: "Current Orders"),
                Tab(text: "Online Orders"),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Enhanced Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Filter Tabs
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(Icons.grid_view_rounded, "All", 0),
                            _buildFilterChip(Icons.restaurant_rounded, "Dine In", 1),
                            _buildFilterChip(Icons.delivery_dining_rounded, "Delivery", 2),
                            _buildFilterChip(Icons.receipt_long_rounded, "Takeaway", 3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade400,
                      ),
                      hintText: "Search orders, customers, phone numbers...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C566A),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusLegend(const Color(0xFF5E81AC), "Saved"),
                        _buildStatusLegend(const Color(0xFFA3BE8C), "Completed"),
                        _buildStatusLegend(const Color(0xFFBF616A), "Cancelled"),
                        _buildStatusLegend(const Color(0xFFD08770), "Pending"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Data Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dataTableTheme: DataTableThemeData(
                        headingRowColor: MaterialStateProperty.all(
                          const Color(0xFF2E3440),
                        ),
                        dataRowColor: MaterialStateProperty.resolveWith(
                          (states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const Color(0xFF88C0D0).withOpacity(0.1);
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    child: DataTable(
                      horizontalMargin: 16,
                      columnSpacing: 24,
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      dataTextStyle: const TextStyle(
                        color: Color(0xFF4C566A),
                        fontSize: 13,
                      ),
                      columns: const [
                        DataColumn(label: Text("Order #")),
                        DataColumn(label: Text("Type")),
                        DataColumn(label: Text("Customer")),
                        DataColumn(label: Text("Phone")),
                        DataColumn(label: Text("Payment")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Tax")),
                        DataColumn(label: Text("Discount")),
                        DataColumn(label: Text("Total")),
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: List.generate(8, (index) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF88C0D0).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "#${1000 + index}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5E81AC),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(_buildTypeChip(_getOrderType(index))),
                            DataCell(Text(_getCustomerName(index))),
                            DataCell(Text(_getPhoneNumber(index))),
                            DataCell(_buildPaymentChip(_getPaymentType(index))),
                            DataCell(Text("₹${_getAmount(index)}")),
                            DataCell(Text("₹${_getTax(index)}")),
                            DataCell(Text("₹${_getDiscount(index)}")),
                            DataCell(
                              Text(
                                "₹${_getTotal(index)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E3440),
                                ),
                              ),
                            ),
                            DataCell(Text(_getDate(index))),
                            DataCell(_buildActionButtons()),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Enhanced Pagination
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Showing 1-8 of 50 orders",
                  style: TextStyle(
                    color: Color(0xFF4C566A),
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    _buildPaginationButton(Icons.chevron_left, () {}),
                    ...List.generate(5, (index) {
                      return _buildPaginationNumber(index + 1, index == 0);
                    }),
                    _buildPaginationButton(Icons.chevron_right, () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label, int index) {
    bool isSelected = selectedFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilterIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF88C0D0) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF88C0D0) : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF4C566A),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4C566A),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLegend(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4C566A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    switch (type) {
      case "Dine In":
        color = const Color(0xFF5E81AC);
        break;
      case "Delivery":
        color = const Color(0xFFD08770);
        break;
      case "Takeaway":
        color = const Color(0xFFA3BE8C);
        break;
      default:
        color = const Color(0xFF4C566A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPaymentChip(String payment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: payment == "Cash" 
            ? const Color(0xFFA3BE8C).withOpacity(0.1)
            : const Color(0xFF88C0D0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        payment,
        style: TextStyle(
          color: payment == "Cash" 
              ? const Color(0xFFA3BE8C)
              : const Color(0xFF88C0D0),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          Icons.visibility_rounded,
          const Color(0xFF5E81AC),
          "View",
          () {},
        ),
        const SizedBox(width: 4),
        _buildActionButton(
          Icons.print_rounded,
          const Color(0xFFA3BE8C),
          "Print",
          () {},
        ),
        const SizedBox(width: 4),
        _buildActionButton(
          Icons.cancel_rounded,
          const Color(0xFFBF616A),
          "Cancel",
          () {},
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPaginationButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        color: const Color(0xFF4C566A),
      ),
    );
  }

  Widget _buildPaginationNumber(int number, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFF88C0D0) : Colors.transparent,
          foregroundColor: isActive ? Colors.white : const Color(0xFF4C566A),
          side: BorderSide(
            color: isActive ? const Color(0xFF88C0D0) : Colors.grey.shade300,
          ),
          minimumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "$number",
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Helper methods for demo data
  String _getOrderType(int index) {
    List<String> types = ["Dine In", "Delivery", "Takeaway"];
    return types[index % 3];
  }

  String _getCustomerName(int index) {
    List<String> names = ["John Doe", "Alice Smith", "Bob Johnson", "Emma Wilson"];
    return names[index % 4];
  }

  String _getPhoneNumber(int index) {
    List<String> phones = ["+91 98765 43210", "+91 87654 32109", "+91 76543 21098"];
    return phones[index % 3];
  }

  String _getPaymentType(int index) {
    return index % 2 == 0 ? "Cash" : "Card";
  }

  int _getAmount(int index) => 450 + (index * 50);
  int _getTax(int index) => (450 + (index * 50)) ~/ 10;
  int _getDiscount(int index) => index % 3 == 0 ? 50 : 0;
  int _getTotal(int index) => _getAmount(index) + _getTax(index) - _getDiscount(index);

  String _getDate(int index) {
    List<String> dates = ["Aug 27", "Aug 26", "Aug 25", "Aug 24"];
    return dates[index % 4];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}