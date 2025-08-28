import 'package:flutter/material.dart';

class OrderReport extends StatefulWidget {
  @override
  _OrderReportState createState() => _OrderReportState();
}

class _OrderReportState extends State<OrderReport> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  String selectedFilter = "All";
  final List<String> filterOptions = ["All", "Dine In", "Delivery", "Take Away"];

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
      "paymentType": "Card",
      "amount": "350.00",
      "tax": "35.00",
      "discount": "10.00",
      "total": "375.00",
      "status": "cancelled",
      "created": "2025-08-02 13:49:58"
    },
    {
      "orderNo": "25",
      "orderType": "Dine In",
      "paymentType": "Cash",
      "amount": "130.00",
      "tax": "13.00",
      "discount": "0.00",
      "total": "143.00",
      "status": "printed",
      "created": "2025-08-02 13:47:48"
    },
    {
      "orderNo": "24",
      "orderType": "Take Away",
      "paymentType": "UPI",
      "amount": "220.00",
      "tax": "22.00",
      "discount": "20.00",
      "total": "222.00",
      "status": "paid",
      "created": "2025-08-02 12:30:15"
    },
    {
      "orderNo": "23",
      "orderType": "Delivery",
      "paymentType": "Cash",
      "amount": "180.00",
      "tax": "18.00",
      "discount": "0.00",
      "total": "198.00",
      "status": "saved",
      "created": "2025-08-02 11:15:30"
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "printed":
        return const Color(0xFF4CAF50);
      case "cancelled":
        return const Color(0xFFF44336);
      case "paid":
        return const Color(0xFFFF9800);
      case "saved":
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color getRowColor(String status) {
    switch (status.toLowerCase()) {
      case "printed":
        return const Color(0xFF4CAF50).withOpacity(0.08);
      case "cancelled":
        return const Color(0xFFF44336).withOpacity(0.08);
      case "paid":
        return const Color(0xFFFF9800).withOpacity(0.08);
      case "saved":
        return const Color(0xFF9E9E9E).withOpacity(0.08);
      default:
        return Colors.white;
    }
  }

  IconData getOrderTypeIcon(String orderType) {
    switch (orderType.toLowerCase()) {
      case "delivery":
        return Icons.delivery_dining;
      case "dine in":
        return Icons.restaurant;
      case "take away":
        return Icons.takeout_dining;
      default:
        return Icons.receipt;
    }
  }

  IconData getPaymentIcon(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case "cash":
        return Icons.money;
      case "card":
        return Icons.credit_card;
      case "upi":
        return Icons.qr_code;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Order Reports',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.download_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildFilterSection(),
            _buildStatusLegend(),
            _buildSummaryCards(),
            Expanded(child: _buildOrdersTable()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: filterOptions.map((filter) => _buildFilterTab(filter)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                'Past Orders',
                Icons.history,
                const Color(0xFF6366F1),
                () {},
              ),
              _buildActionButton(
                'Export',
                Icons.file_download,
                const Color(0xFF10B981),
                () {},
              ),
              _buildActionButton(
                'Refresh',
                Icons.refresh,
                const Color(0xFFFF9800),
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              _getFilterIcon(filter),
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case "All":
        return Icons.grid_view;
      case "Dine In":
        return Icons.restaurant;
      case "Delivery":
        return Icons.delivery_dining;
      case "Take Away":
        return Icons.takeout_dining;
      default:
        return Icons.receipt;
    }
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusDot(Colors.grey.shade600, "Saved"),
          _buildStatusDot(const Color(0xFF4CAF50), "Printed"),
          _buildStatusDot(const Color(0xFFF44336), "Cancelled"),
          _buildStatusDot(const Color(0xFFFF9800), "Paid"),
        ],
      ),
    );
  }

  Widget _buildStatusDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final totalOrders = orders.length;
    final totalAmount = orders.fold<double>(
      0,
      (sum, order) => sum + (double.tryParse(order['total'] ?? '0') ?? 0),
    );
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildSummaryCard('Total Orders', '$totalOrders', Icons.receipt, const Color(0xFF6366F1))),
          const SizedBox(width: 12),
          Expanded(child: _buildSummaryCard('Total Amount', '₹${totalAmount.toStringAsFixed(2)}', Icons.currency_rupee, const Color(0xFF10B981))),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowHeight: 60,
            dataRowHeight: 70,
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F9FA)),
            dividerThickness: 1,
            columns: const [
              DataColumn(
                label: Text(
                  'Order #',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ),
              DataColumn(
                label: Text(
                  'Type',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ),
              DataColumn(
                label: Text(
                  'Payment',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ),
              DataColumn(
                label: Text(
                  'Amount',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ),
              DataColumn(
                label: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ),
              DataColumn(
                label: Text(
                  'Created',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ),
            ],
            rows: orders.asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              final status = order['status'] ?? '';
              
              return DataRow(
                color: MaterialStateProperty.all(getRowColor(status)),
                cells: [
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${order['orderNo']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Icon(
                          getOrderTypeIcon(order['orderType'] ?? ''),
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(order['orderType'] ?? ''),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Icon(
                          getPaymentIcon(order['paymentType'] ?? ''),
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(order['paymentType'] ?? ''),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      '₹${order['amount']}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      '₹${order['total']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: status == 'cancelled' ? Colors.red : const Color(0xFF10B981),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: getStatusColor(status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      order['created']?.substring(0, 16) ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        _buildActionIcon(Icons.visibility, Colors.blue, () {}),
                        const SizedBox(width: 4),
                        _buildActionIcon(Icons.print, Colors.green, () {}),
                        const SizedBox(width: 4),
                        _buildActionIcon(Icons.cancel, Colors.red, () {}),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}