import 'package:flutter/material.dart';

class LiveViewPage extends StatelessWidget {
  const LiveViewPage({super.key});

  final List<Map<String, dynamic>> orders = const [
    {
      "restaurant": "Burger Point",
      "kot": 29,
      "bill": 29,
      "timer": "01:58",
      "items": ["1x Butter Scotch Cake (500 Gm)"],
      "amount": 350,
      "orderType": "Delivery",
      "status": "Food Is Ready"
    },
    {
      "restaurant": "Burger Point",
      "kot": 28,
      "bill": 28,
      "timer": "02:05",
      "items": [
        "2x Veg Thick Burger (With Cheese)",
        "1x French Fires (Half)",
        "1x Virgin Mojito",
        "1x Cappuccino Coffee"
      ],
      "amount": 429,
      "orderType": "Delivery",
      "status": "Food Is Ready"
    },
    {
      "restaurant": "Burger Point",
      "kot": 27,
      "bill": 27,
      "timer": "20:58",
      "items": ["1x Cold Coffee Shake"],
      "amount": 99,
      "orderType": "Delivery",
      "status": "Food Is Ready"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Orders")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: orders.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(order);
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.pedal_bike_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(order['restaurant'], style: const TextStyle(fontWeight: FontWeight.bold))),
                Text(order['timer'], style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
          // KOT & Bill
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("KOT: ${order['kot']} | BILL: ${order['bill']}", style: const TextStyle(fontWeight: FontWeight.w500)),
                const Text("👤 Not Assigned"),
              ],
            ),
          ),
          // Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.builder(
                itemCount: order['items'].length,
                itemBuilder: (context, i) => Text(order['items'][i]),
              ),
            ),
          ),
          const Divider(),
          // Bottom Action Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () {},
                    child: const Text("Food Is Ready"),
                  ),
                ),
                const SizedBox(width: 6),
                Text("₹${order['amount']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
