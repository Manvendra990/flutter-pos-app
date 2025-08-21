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

class PetPoojaPOS extends StatefulWidget {
  final String countData;
  final List<String>? cart;
  final String? status;

  const PetPoojaPOS({Key? key, required this.countData, this.cart, this.status}) : super(key: key);

  @override
  State<PetPoojaPOS> createState() => _PetPoojaPOSState();
}

class _PetPoojaPOSState extends State<PetPoojaPOS> {
  
  String selectedTab = "DINE IN"; // At the top of your state class

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


  
  
  get selectedMode => null;

  @override
  void initState() {
    super.initState();
    loadDatabaseItems();
  }

  Future<void> loadDatabaseItems() async {
    final items = await DBHelper.getItemsWithSubItems();
    Map<String, List<Map<String, dynamic>>> grouped = {};
    print(items);

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
}}


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
  final totalItems = cartItems.values.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

  for (var entry in cartItems.entries) {
    final key = entry.key;
    final item = entry.value;
    final quantity = item['quantity'] as int;
    final price = item['price'] as num;
    final netAmount = quantity * price;

    final parent = item['parent'];   // ✅ Must be stored in cartItems
    final subItem = item['name'];    // ✅ Must be stored in cartItems

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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Summary saved with parent & sub-items.")),
  );
}


final Map<String, bool> paymentSelections = {
  "Cash": false,
  "Card": false,
  "Due": false,
  "Other": false,
  "Part": false,
};





Future<void> saveTabletoDb() async {
  final discount = int.tryParse(discountController.text) ?? 0;
  final tax = 0;
  final totalItems = cartItems.values.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

  for (var entry in cartItems.entries) {
    final key = entry.key;
    final item = entry.value;
    final quantity = item['quantity'] as int;
    final price = item['price'] as num;
    final netAmount = quantity * price;

    final parent = item['parent'];   // ✅ Must be stored in cartItems
    final subItem = item['name'];    // ✅ Must be stored in cartItems

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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Summary saved with parent & sub-items.")),
  );
}


void clearCart() {
  setState(() {
    cartItems.clear();
  });
  print("Cart is cleared from ✅");
}

void Saveandprint (){
 PrinterHelper.printReceipt(
      cartItems: cartItems,
      shopName: "Burger Pont",
      gstNumber: "34434344434",
    );

    print('RReceipt printed successfully');
}


  @override
  Widget build(BuildContext context) {
     return BlocListener<OrderBloc, OrderState>(
      listenWhen: (previous, current) => current.cartCleared,
      listener: (context, state) {
        clearCart();
      },
    child: Scaffold(
      body: itemSubItemMap.isEmpty
          ? Center(child: Text("No items found. Please add items from DB."))
          : Row(
              children: [
                Container(
                  width: 180,
                  color: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: ListView(
                    children: itemSubItemMap.keys.map((itemName) {
                      final isSelected = selectedItemGroup == itemName;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedItemGroup = itemName);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.greenAccent.shade400 : Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            child: Text(
                              itemName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = (constraints.maxWidth / 160).floor();
                      return GridView.count(
                        crossAxisCount: crossAxisCount.clamp(1, 5),
                        childAspectRatio: 2.5,
                        padding: EdgeInsets.all(10),
                        children: itemSubItemMap[selectedItemGroup]!.map((subItem) {
                          final name = subItem['name'];
                          final price = subItem['price'];
                          final parent = subItem['parent'];
                          final key = "$parent - $name";
                           

                          return InkWell(
                     onTap: () async {
  if (subItem['isvarient'] == 1) {
    // 🔥 Agar item me variant hai to popup khulega
    final result = await showDialog(
      context: context,
      builder: (context) => ItemPopup(item: subItem),
    );

    if (result != null) {
      setState(() {
        // Agar variant select nahi hua to default key bana dena
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
            'selectedVariant': result['variant'],   // null bhi ho sakta hai
            'selectedToppings': result['toppings'],
          };
        }
      });
    }
  } else {
    // 🔥 Normal item (without variant) direct add
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
},

                            child: Card(
                              elevation: 2,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

Expanded( 
  flex: 2,
  child: Column(
    children: [
      // Top Tabs and Icons
      Column(
        children: [
        Row(
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

Container(
  color: Colors.grey.shade200,
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: 
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _iconButton(Icons.table_bar, index: 0),
    _iconButton(Icons.person, index: 1),
    _iconButton(Icons.diversity_1, index: 2),
    _iconButton(Icons.receipt_long, index: 3),
  ],
),

),

Container(
    width: double.infinity,
  color: const Color.fromARGB(255, 229, 229, 229),
  padding: EdgeInsets.all(10),
 child: activeIconIndex != null
      ? _buildInputFields(activeIconIndex!) // ✅ har icon ke hisaab se input dikhega
      : const SizedBox.shrink(),
),

        ],
      ),

      // Cart Items Header
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.grey.shade300,
        child: Row(
          children: const [
            Expanded(flex: 4, child: Text("ITEMS", style: TextStyle(fontSize: 10))),
            Expanded(flex: 2, child: Text("CHECK ITEMS", style: TextStyle(fontSize: 10))),
            Expanded(flex: 2, child: Text("QTY", style: TextStyle(fontSize: 10))),
            Expanded(flex: 2, child: Text("PRICE", style: TextStyle(fontSize: 10))),
          ],
        ),
      ),

      // Cart Item List
      Expanded(
        child: cartItems.isEmpty
            ?
            Expanded(
  child: SingleChildScrollView(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Item Selected",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            "Please Select item from Left Menu",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    ),
  ),
)

            : ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final key = cartItems.keys.elementAt(index);
                  final item = cartItems[key]!;
                  final subname = item['name'] ?? "";
                  final quantity = item['quantity'] as int;
                  final price = item['price'] as double;
                  final total = quantity * price;
                  final isvarient = item['isvarient'] as int;

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.close, color:  Color.fromARGB(255, 77, 93, 243),),
                                onPressed: () => setState(() => cartItems.remove(key)),
                              ),
                              Expanded(child: Text(subname, style: TextStyle(fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ),
                        Expanded(flex: 2, child: Checkbox(value: true, onChanged: (_) {})),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              ),
                              Text('$quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(Icons.add, size: 18),
                                onPressed: () => setState(() => cartItems[key]!['quantity'] += 1),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("₹$price", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                              Text("₹$total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),

      // Expand/Collapse
      Align(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(isBottomExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 30),
          onPressed: () => setState(() => isBottomExpanded = !isBottomExpanded),
        ),
      ),

      // Billing Summary
if (isBottomExpanded)
            // Billing Summary
 
      AnimatedSize(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: isBottomExpanded
            ? Material(
                elevation: 8,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(),
                      _summaryRow("Sub Total", "₹${getTotalAmount()}"),
                      _inputRow("Discount", discountController),
                      _inputRow("Delivery Charge", deliveryChargeController),
                      _inputRow("Customer Charge", customerChargeController),
                      _summaryRow("Tax", "0.00"),
                      _summaryRow("Round Off", "0.00"),
                    ],
                  ),
                ),
              )
            : SizedBox.shrink(),
      ),

Container(
  color: Colors.grey.shade900,
child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    
 
      // Split / Complimentary / Sales Return
     Container(
  // Dark background for contrast
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white, // makes text white
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: Text(
          "Split",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
 

    ],

  ),
),


   Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Total ₹${getTotalAmount()}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color.fromARGB(255, 0, 56, 239),
              ),
            ),
          ],
        ),
      ),


  ],
),
      // Net Total
),

      // Payment Type
Container(
  width: double.infinity,
  color: Colors.grey.shade900,
  padding: EdgeInsets.all(10),
  child: Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      _paymentOption("Cash"),
      _paymentOption("Card"),
      _paymentOption("Due"),
      _paymentOption("Other"),
      _paymentOption("Part"),
    ],
  ),
),




      // Save and Action Buttons
    Container(
  width: double.infinity, // 🔥 Make container take full width
  color: Colors.grey.shade900,
  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8), // spacing inside
  child: Wrap(
    spacing: 10,
    runSpacing: 8,
    alignment: WrapAlignment.center,
    children: [
      ElevatedButton(
        onPressed: saveSummaryToDB,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
        ),
        child: Text("SAVE"),
      ),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
        ),
        child: Text("SAVE & PRINT"),
      ),
      ElevatedButton(
        onPressed: () {
          Saveandprint();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
        ),
        child: Text("SAVE & eBILL"),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context, {
            'cart': cartItems.keys.toList(),
            'action': 'kot',
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
        ),
        child: Text("KOT"),
      ),
      // ElevatedButton(
      //   onPressed: () {
      //     Navigator.pop(context, {
      //       'cart': [],
      //       'action': 'settle',
      //     });
      //   },
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: Colors.grey,
      //     foregroundColor: Colors.white,
      //     textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
      //   ),
      //   child: Text("Settle"),
      // ),

      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
        ),
        child: Text("KOT & PRINT"),
      ),
    ],
  ),
),

SizedBox(height:  20,)

    ],
  ),



)
,

    
              ],
            ),
         ) );
         
  
  }










Widget _buildTab(String title, {bool isActive = false, required VoidCallback onTap}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap, // 🔥 Make it clickable
      child: Container(
        color: isActive ? Color.fromARGB(255, 77, 93, 243) : Colors.grey.shade300,
        padding: EdgeInsets.all(4),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _iconButton(
  IconData icon, {
  String? number,
  int? index,
  TextEditingController? controller,
  VoidCallback? onClick, // ✅ custom click callback
}) {
  bool isActive = activeIconIndex == index;

  // ✅ Only table_bar supports input
  bool isInputAllowed = (icon == Icons.table_bar);

  // ✅ Bind correct controller automatically for table_bar
  if (isInputAllowed) {
    controller = tableBarController;
  }

  return GestureDetector(
  onTap: () {
  setState(() {
    // ✅ Toggle behavior (same icon pe tap karne par band ho jaye)
    activeIconIndex = (activeIconIndex == index) ? null : index;
  });

  if (onClick != null) onClick();
},

    child: Row(
      children: [
        Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 20),
                if (number != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),

        // ✅ Show input only for active table_bar
        if (isActive && isInputAllowed) ...[
          const SizedBox(width: 6),
       
        ],

      ],
    ),
  );
}

Widget _summaryRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    ),
  );
}

Widget _inputRow(String title, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 28,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 12),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _paymentOption(String type) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Checkbox(
        value: paymentSelections[type],
        onChanged: (bool? value) {
          setState(() {
            paymentSelections[type] = value ?? false;
          });
        },
        activeColor: Colors.white,
        checkColor: Colors.black,
        fillColor: MaterialStateProperty.all(Colors.white),
      ),
      Text(
        type,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    ],
  );
}

Widget _Userdetaildata(String type) {
  return
   Row(
    mainAxisSize: MainAxisSize.min,
    children: [

    
    ],
  );
}




Widget _buildInputFields(int index) {
  switch (index) {
    case 0: // Table No
      return Container(
        margin: const EdgeInsets.only(top: 6),
        width: 40,
        child: TextField(
          controller: tableBarController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Table No",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
        ),
      );

    case 1: // Customer Name & Mobile
      return Container(
        margin: const EdgeInsets.only(top: 6),
        width: 160,
        child: Column(
          children: [
            TextField(
              controller: customerNameController,
              decoration: const InputDecoration(
                labelText: "Customer Name",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: customerMobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile No",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              ),
            ),
          ],
        ),
      );

    case 2: // Number of Persons
      return Container(
        margin: const EdgeInsets.only(top: 6),
        width: 100,
        child: TextField(
          controller: personCountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Persons",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
        ),
      );

    default: // Receipt icon => nothing
      return const SizedBox.shrink();
  }
}


void callVarients(BuildContext context,Map <String, dynamic> item){
final result =showDialog(context: context, builder: (BuildContext context) {
  return AlertDialog(
    title: Text(item['name']),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Price: ${item['price']}"),
        SizedBox(height: 16),
        Text("Variants:"),
        ...item['variants'].map<Widget>((variant) {
          return ListTile(
            title: Text(variant['name']),
            trailing: Text("\$${variant['price']}"),
          );
        }).toList(),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("Close"),
      ),
    ],
  );
});
}


}




