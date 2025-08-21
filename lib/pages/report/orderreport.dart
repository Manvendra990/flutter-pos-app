import 'package:flutter/material.dart';

class Orderreport extends StatelessWidget {
  final List<Map<String, String>> orders = [
    {
      "orderNo": "27",
      "orderType": "Delivery",
      "paymentType": "Cash",
      "amount": "99.00",
      "tax": "0.00",
      "discount": "0.00",
      "total": "99.00",
      "status": "cancelled",
      "created": "2025-08-02 13:51:14"
    },
    {
      "orderNo": "26",
      "orderType": "Delivery",
      "paymentType": "Cash",
      "amount": "350.00",
      "tax": "0.00",
      "discount": "0.00",
      "total": "350.00",
      "status": "cancelled",
      "created": "2025-08-02 13:49:58"
    },
    {
      "orderNo": "25",
      "orderType": "Delivery",
      "paymentType": "Cash",
      "amount": "130.00",
      "tax": "0.00",
      "discount": "0.00",
      "total": "130.00",
      "status": "printed",
      "created": "2025-08-02 13:47:48"
    },
    // Add more orders...
  ];

  Color getRowColor(String status) {
    switch (status) {
      case "printed":
        return Colors.green.withOpacity(0.2);
      case "cancelled":
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Orders'),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          filterTabs(),
          statusLegend(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowColor:
                    MaterialStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text('Order No.')),
                  DataColumn(label: Text('Order Type')),
                  DataColumn(label: Text('Payment')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Tax')),
                  DataColumn(label: Text('Discount')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Created')),
                  DataColumn(label: Text('Action')),
                ],
                rows: orders.map((order) {
                  final isCancelled = order['status'] == 'cancelled';
                  final rowColor = getRowColor(order['status']!);
                  return DataRow(
                    color: MaterialStateProperty.all(rowColor),
                    cells: [
                      DataCell(Text(order['orderNo'] ?? '')),
                      DataCell(Text(order['orderType'] ?? '')),
                      DataCell(Text(order['paymentType'] ?? '')),
                      DataCell(Text(order['amount'] ?? '')),
                      DataCell(Text(order['tax'] ?? '')),
                      DataCell(Text(order['discount'] ?? '')),
                      DataCell(Text(order['total'] ?? '',
                          style: TextStyle(
                              color: isCancelled ? Colors.red : Colors.black))),
                      DataCell(Text(order['created'] ?? '')),
                      DataCell(Row(
                        children: [
                          TextButton(onPressed: () {}, child: Text("View")),
                          Text('|'),
                          TextButton(onPressed: () {}, child: Text("Reprint")),
                          Text('|'),
                          TextButton(onPressed: () {}, child: Text("Cancel")),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
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
          tabButton(Icons.receipt, "Take Away"),
          Spacer(),
          ElevatedButton(
              onPressed: () {}, child: Text("Get Past Orders")),
          SizedBox(width: 8),
          ElevatedButton(
              onPressed: () {}, child: Text("Back")),
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
          Text(label, style: TextStyle(color: Colors.redAccent)),
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
          SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
