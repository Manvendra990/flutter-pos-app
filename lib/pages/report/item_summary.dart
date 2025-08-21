import 'package:flutter/material.dart';

class ItemSummery extends StatefulWidget {
  const ItemSummery({super.key});

  @override
  State<ItemSummery> createState() => _ItemSummeryState();
}

class _ItemSummeryState extends State<ItemSummery>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.redAccent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Current Order"),
            Tab(text: "Online Order"),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          filterTabs(),
          statusLegend(),
          const SizedBox(height: 10),

          // Data Table inside Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        MaterialStateProperty.all(Colors.grey.shade200),
                    dataRowColor: MaterialStateProperty.resolveWith((states) {
                      return states.contains(MaterialState.selected)
                          ? Colors.redAccent.withOpacity(0.1)
                          : null;
                    }),
                    columns: const [
                      DataColumn(label: Text("Order No.")),
                      DataColumn(label: Text("Order Type")),
                      DataColumn(label: Text("Customer Phone")),
                      DataColumn(label: Text("Customer Name")),
                      DataColumn(label: Text("Payment Type")),
                      DataColumn(label: Text("Amount")),
                      DataColumn(label: Text("Tax")),
                      DataColumn(label: Text("Discount")),
                      DataColumn(label: Text("Grand Total")),
                      DataColumn(label: Text("Created Date")),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: List.generate(10, (index) {
                      return DataRow(cells: [
                        DataCell(Text("#${index + 1}")),
                        const DataCell(Text("Dine In")),
                        const DataCell(Text("9876543210")),
                        const DataCell(Text("John Doe")),
                        const DataCell(Text("Cash")),
                        const DataCell(Text("500")),
                        const DataCell(Text("50")),
                        const DataCell(Text("20")),
                        const DataCell(Text("530")),
                        const DataCell(Text("2025-08-14")),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Colors.blue),
                              onPressed: () {},
                              tooltip: "View",
                            ),
                            IconButton(
                              icon: const Icon(Icons.print,
                                  color: Colors.green),
                              onPressed: () {},
                              tooltip: "Reprint",
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel,
                                  color: Colors.red),
                              onPressed: () {},
                              tooltip: "Cancel",
                            ),
                          ],
                        )),
                      ]);
                    }),
                  ),
                ),
              ),
            ),
          ),

          // Pagination
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text("${index + 1}"),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget filterTabs() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          tabButton(Icons.grid_view, "All"),
          tabButton(Icons.restaurant, "Dine In"),
          tabButton(Icons.delivery_dining, "Delivery"),
          tabButton(Icons.receipt, "Bill"),
          const Spacer(),
          SizedBox(
            width: 200,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tabButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Icon(icon, color: Colors.redAccent),
          Text(label, style: const TextStyle(color: Colors.redAccent)),
        ],
      ),
    );
  }

  Widget statusLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          statusDot(Colors.grey, "Saved Bill"),
          statusDot(Colors.green, "Printed Bill"),
          statusDot(Colors.red, "Cancelled Bill"),
          statusDot(Colors.orange, "Paid"),
        ],
      ),
    );
  }

  Widget statusDot(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
