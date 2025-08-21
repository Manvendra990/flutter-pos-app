import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posapp/component/drawer.dart';
import 'package:posapp/component/header.dart';
import 'package:posapp/component/itempop.dart';
import 'package:posapp/storage/bloc_statemanager.dart';
import 'package:posapp/storage/db_helper.dart';
import 'package:posapp/utils/printer.dart';

class POSDashboard extends StatefulWidget {
  final String countData;
  final List<String>? cart;
  final String? status;

  const POSDashboard({Key? key, required this.countData, this.cart, this.status}) : super(key: key);

  @override
  State<POSDashboard> createState() => _POSDashboardState();
}

class _POSDashboardState extends State<POSDashboard> with TickerProviderStateMixin {
  
  String selectedTab = "DINE IN";
  bool isComplimentary = false;
  bool isPaid = false;
  String selectedPayment = "Cash";
  String selectedItemGroup = "";
  Map<String, List<Map<String, dynamic>>> itemSubItemMap = {};
  Map<String, Map<String, dynamic>> cartItems = {};

  bool isBottomExpanded = false;
  TextEditingController discountController = TextEditingController();
  TextEditingController deliveryChargeController = TextEditingController();
  TextEditingController customerChargeController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  int? activeIconIndex;

  TextEditingController tableBarController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerMobileController = TextEditingController();
  TextEditingController personCountController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Enhanced Color Scheme
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    loadDatabaseItems();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadDatabaseItems() async {
    final items = await DBHelper.getItemsWithSubItems();
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in items) {
      final itemName = item['name'];
      final subItems = item['sub_items'] as List<dynamic>;

      for (var sub in subItems) {
        final subItem = {
          'id': sub['id'],
          'item_id': sub['item_id'],
          'parent': itemName,
          'name': sub['name'] ?? "",
          'short_code': sub['short_code'] ?? "",
          'unit': sub['unit'] ?? "",
          'description': sub['description'] ?? "",
          'choice': sub['choice'] ?? "",
          'order_types': sub['order_types'] ?? "",
          'image_path': sub['image_path'],
          'price': (sub['price'] ?? 0).toDouble(),
          'isvarient': sub['isvarient'] ?? 0,
          'hastoppings': sub['hastoppings'] ?? 0,
          'quantity': 0,
          'total': 0.0,
          'variants': sub['variants'] ?? [],
          'toppings': sub['toppings'] ?? [],
        };

        if (!grouped.containsKey(itemName)) {
          grouped[itemName] = [];
        }
        grouped[itemName]!.add(subItem);
      }
    }

    setState(() {
      itemSubItemMap = grouped;
      selectedItemGroup = grouped.keys.isNotEmpty ? grouped.keys.first : "";
    });
  }

  int getTotalAmount() {
    int total = 0;
    cartItems.forEach((key, value) {
      total += (value['quantity'] as int) * (value['price'] as num).toInt();
    });
    return total;
  }

  Future<void> saveSummaryToDB() async {
    String date = DateTime.now().toString().split(' ')[0].replaceAll('-', '');
    String orderId = 'ORD-$date-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final tableNumber = int.tryParse(tableBarController.text) ?? 0;
    final users_count = int.tryParse(personCountController.text) ?? 0;
    final discount = double.tryParse(discountController.text) ?? 0;
    final tax = 0;

    for (var entry in cartItems.entries) {
      final item = entry.value;
      final quantity = item['quantity'] as int;
      final price = item['price'] as num;
      final netAmount = quantity * price;
      final parent = item['parent'];
      final subItem = item['name'];
      final proper_amount = netAmount - discount;

      final summary = {
        "order_date": DateTime.now().toIso8601String(),
        "order_type": selectedTab,
        "order_id": orderId,
        'parent_name': parent,
        "table_number": tableNumber,
        "person_count": users_count,
        'subitem_name': subItem,
        'item_count': quantity,
        'net_amount': proper_amount,
        'discount': discount,
        'tax': tax,
        'total_sale': netAmount,
      };

      await DBHelper.insertCategorySummary(summary);
    }
    clearCart();
    _showSuccessSnackbar("Order saved successfully!");
  }

  final Map<String, bool> paymentSelections = {
    "Cash": false,
    "Card": false,
    "Due": false,
    "Other": false,
    "Part": false,
  };

  void clearCart() {
    setState(() {
      cartItems.clear();
    });
  }

  void Saveandprint() {
    PrinterHelper.printReceipt(
      cartItems: cartItems,
      shopName: "Burger Point",
      gstNumber: "34434344434",
    );
    _showSuccessSnackbar("Receipt printed successfully!");
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: secondaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listenWhen: (previous, current) => current.cartCleared,
      listener: (context, state) {
        clearCart();
      },
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: itemSubItemMap.isEmpty
              ? _buildLoadingState()
              : Row(
                  children: [
                    _buildCategoryMenu(),
                    _buildItemGrid(),
                    _buildCartSection(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            "Loading menu items...",
            style: TextStyle(color: textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryMenu() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              "Categories",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: itemSubItemMap.keys.map((itemName) {
                final isSelected = selectedItemGroup == itemName;
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => selectedItemGroup = itemName);
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                            ? LinearGradient(
                                colors: [primaryColor, Color(0xFF3B82F6)],
                              )
                            : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                            ? Border.all(color: Colors.white.withOpacity(0.3))
                            : null,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                itemName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid() {
    return Expanded(
      flex: 2,
      child: Container(
        color: surfaceColor,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.restaurant_menu, color: primaryColor),
                  SizedBox(width: 8),
                  Text(
                    selectedItemGroup.isNotEmpty ? selectedItemGroup : "Select Category",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: selectedItemGroup.isEmpty
                  ? _buildEmptyMenuState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = (constraints.maxWidth / 200).floor().clamp(1, 6);
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1.2,
                          padding: EdgeInsets.all(16),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: itemSubItemMap[selectedItemGroup]!.map((subItem) {
                            return _buildMenuItem(subItem);
                          }).toList(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMenuState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 64, color: textSecondary),
          SizedBox(height: 16),
          Text(
            "Select a category to view items",
            style: TextStyle(fontSize: 16, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> subItem) {
    final name = subItem['name'];
    final price = subItem['price'];
    final parent = subItem['parent'];

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleItemTap(subItem),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.2), secondaryColor.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.fastfood,
                  color: primaryColor,
                  size: 30,
                ),
              ),
              SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "₹$price",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleItemTap(Map<String, dynamic> subItem) async {
    final parent = subItem['parent'];
    
    if (subItem['isvarient'] == 1) {
      final result = await showDialog(
        context: context,
        builder: (context) => ItemPopup(item: subItem),
      );

      if (result != null) {
        setState(() {
          final variantName = result['variant']?['name'] ?? "default";
          final key = "${subItem['id']}_$variantName";

          if (cartItems.containsKey(key)) {
            cartItems[key]!['quantity'] += 1;
          } else {
            cartItems[key] = {
              'quantity': 1,
              'price': result['finalPrice'],
              'parent': parent,
              'name': subItem['name'],
              'isvarient': 1,
              'selectedVariant': result['variant'],
              'selectedToppings': result['toppings'],
            };
          }
        });
      }
    } else {
      final key = subItem['id'].toString();
      setState(() {
        if (cartItems.containsKey(key)) {
          cartItems[key]!['quantity'] += 1;
        } else {
          cartItems[key] = {
            'quantity': 1,
            'price': subItem['price'],
            'parent': parent,
            'name': subItem['name'],
            'isvarient': 0,
          };
        }
      });
    }
  }

  Widget _buildCartSection() {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildOrderTypeTabs(),
            _buildActionIcons(),
            _buildCartHeader(),
            _buildCartItems(),
            _buildExpandToggle(),
            if (isBottomExpanded) _buildBillingSummary(),
            _buildTotalSection(),
            _buildPaymentSection(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeTabs() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _buildTab("DINE IN", isActive: selectedTab == "DINE IN", onTap: () {
            setState(() => selectedTab = "DINE IN");
          }),
          _buildTab("DELIVERY", isActive: selectedTab == "DELIVERY", onTap: () {
            setState(() => selectedTab = "DELIVERY");
          }),
          _buildTab("PICK UP", isActive: selectedTab == "PICK UP", onTap: () {
            setState(() => selectedTab = "PICK UP");
          }),
        ],
      ),
    );
  }

  Widget _buildActionIcons() {
    return Container(
      color: surfaceColor,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _iconButton(Icons.table_restaurant, index: 0, ),
              _iconButton(Icons.person_outline, index: 1, ),
              _iconButton(Icons.groups_outlined, index: 2, ),
              _iconButton(Icons.receipt_long_outlined, index: 3, ),
            ],
          ),
          if (activeIconIndex != null) 
            Container(
              margin: EdgeInsets.only(top: 12),
              child: _buildInputFields(activeIconIndex!),
            ),
        ],
      ),
    );
  }

  Widget _buildCartHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_cart, color: Colors.white, size: 14),
          SizedBox(width: 2),
          Text(
            "Order Summary",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${cartItems.length} items",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return Expanded(
      child: cartItems.isEmpty
          ? _buildEmptyCartState()
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final key = cartItems.keys.elementAt(index);
                final item = cartItems[key]!;
                return _buildCartItem(key, item);
              },
            ),
    );
  }

Widget _buildEmptyCartState() {
  return Expanded(
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 40,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add items from the menu to get started",
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}



  Widget _buildCartItem(String key, Map<String, dynamic> item) {
    final subname = item['name'] ?? "";
    final quantity = item['quantity'] as int;
    final price = item['price'] as double;
    final total = quantity * price;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: dangerColor),
              onPressed: () => setState(() => cartItems.remove(key)),
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    "₹$price each",
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 18),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) {
                          cartItems[key]!['quantity'] -= 1;
                        } else {
                          cartItems.remove(key);
                        }
                      });
                    },
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$quantity',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 18),
                    onPressed: () => setState(() => cartItems[key]!['quantity'] += 1),
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${total.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandToggle() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: IconButton(
        icon: AnimatedRotation(
          turns: isBottomExpanded ? 0.5 : 0,
          duration: Duration(milliseconds: 300),
          child: Icon(Icons.expand_less),
        ),
        onPressed: () => setState(() => isBottomExpanded = !isBottomExpanded),
      ),
    );
  }

  Widget _buildBillingSummary() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          _summaryRow("Subtotal", "₹${getTotalAmount()}"),
          _inputRow("Discount", discountController),
          _inputRow("Delivery Charge", deliveryChargeController),
          _inputRow("Service Charge", customerChargeController),
          _summaryRow("Tax", "₹0"),
          _summaryRow("Round Off", "₹0"),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF3B82F6)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total Amount",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "₹${getTotalAmount()}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _paymentOption("Cash", Icons.money),
              _paymentOption("Card", Icons.credit_card),
              _paymentOption("Due", Icons.schedule),
              _paymentOption("Other", Icons.more_horiz),
              _paymentOption("Part", Icons.splitscreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFF0F172A),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _actionButton("SAVE", primaryColor, saveSummaryToDB),
          _actionButton("SAVE & PRINT", Colors.blueGrey, () {}),
          _actionButton("SAVE & eBILL", secondaryColor, Saveandprint),
          _actionButton("KOT", accentColor, () {
            Navigator.pop(context, {
              'cart': cartItems.keys.toList(),
              'action': 'kot',
            });
          }),
          _actionButton("KOT & PRINT", dangerColor, () {}),
        ],
      ),
    );
  }

  Widget _buildTab(String title, {bool isActive = false, required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? primaryColor : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: isActive ? primaryColor : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, {int? index,}) {
    bool isActive = activeIconIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          activeIconIndex = (activeIconIndex == index) ? null : index;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? primaryColor : Colors.grey.shade300,
              ),
              boxShadow: isActive ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ] : null,
            ),
            child: Icon(
              icon,
              size: 12,
              color: isActive ? Colors.white : textSecondary,
            ),
          ),
        
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputRow(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 22,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(String type, IconData icon) {
    bool isSelected = paymentSelections[type] ?? false;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          paymentSelections[type] = !isSelected;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputFields(int index) {
    switch (index) {
      case 0: // Table No
        return Container(
          width: 120,
          child: TextField(
            controller: tableBarController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Table Number",
              prefixIcon: Icon(Icons.table_restaurant, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        );

      case 1: // Customer Details
        return Column(
          children: [
            Container(
              width: 150,
              child: TextField(
                controller: customerNameController,
                decoration: InputDecoration(
                  labelText: "Customer Name",
                  prefixIcon: Icon(Icons.person, size: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 200,
              child: TextField(
                controller: customerMobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: Icon(Icons.phone, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        );

      case 2: // Person Count
        return Container(
          width: 120,
          child: TextField(
            controller: personCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Person Count",
              prefixIcon: Icon(Icons.groups, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        );

      default:
        return SizedBox.shrink();
    }
  }

  // Keep your existing methods for database operations
  Future<void> saveTabletoDb() async {
    final discount = int.tryParse(discountController.text) ?? 0;
    final tax = 0;

    for (var entry in cartItems.entries) {
      final item = entry.value;
      final quantity = item['quantity'] as int;
      final price = item['price'] as num;
      final netAmount = quantity * price;
      final parent = item['parent'];
      final subItem = item['name'];

      final summary = {
        "tablecount": widget.countData,
        "order_date": DateTime.now().toIso8601String(),
        "order_type": selectedTab,
        'parent_name': parent,
        'subitem_name': subItem,
        'item_count': quantity,
        'net_amount': netAmount,
        'discount': discount,
        'tax': tax,
        'total_sale': netAmount,
      };

      await DBHelper.insertCategorySummary(summary);
    }
    clearCart();
    _showSuccessSnackbar("Table order saved successfully!");
  }

  void callVarients(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            item['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Price: ₹${item['price']}"),
              SizedBox(height: 16),
              Text(
                "Variants:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...item['variants'].map<Widget>((variant) {
                return ListTile(
                  title: Text(variant['name']),
                  trailing: Text("₹${variant['price']}"),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}