// import 'package:flutter/material.dart';

// class ItemPopup extends StatelessWidget {
//   final Map<String, dynamic> item;

//   const ItemPopup({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     print("🟢 ItemPopup item data: $item");

//     // ✅ Direct root se uthao (sub_items hata diya)
//     final List variants = item["variants"] ?? [];
//     final List toppings = item["toppings"] ?? [];

//     double selectedPrice = item["price"] ?? 0.0;
//     int selectedVariantIndex = -1;
//     List<int> selectedToppings = [];

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text(item["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // 🔹 Variations
//               if (variants.isNotEmpty) ...[
//                 const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text("Variation", style: TextStyle(fontWeight: FontWeight.bold))),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: List.generate(variants.length, (index) {
//                     final v = variants[index];
//                     return ChoiceChip(
//                       label: Text("${v['name']} ₹${v['price']}"),
//                       selected: selectedVariantIndex == index,
//                       onSelected: (_) {
//                         setState(() {
//                           selectedVariantIndex = index;
//                           selectedPrice = v['price'];
//                         });
//                       },
//                     );
//                   }),
//                 ),
//               ],
//               const SizedBox(height: 20),

//               // 🔹 Toppings
//               if (toppings.isNotEmpty) ...[
//                 const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text("Add Toppings", style: TextStyle(fontWeight: FontWeight.bold))),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: List.generate(toppings.length, (index) {
//                     final t = toppings[index];
//                     return FilterChip(
//                       label: Text("${t['name']} ₹${t['price']}"),
//                       selected: selectedToppings.contains(index),
//                       onSelected: (selected) {
//                         setState(() {
//                           if (selected) {
//                             selectedToppings.add(index);
//                             selectedPrice += t['price'];
//                           } else {
//                             selectedToppings.remove(index);
//                             selectedPrice -= t['price'];
//                           }
//                         });
//                       },
//                     );
//                   }),
//                 ),
//               ],
//             ],
//           ),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("₹ $selectedPrice",
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   Row(
//                     children: [
//                       TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//                       ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(context, {
//                               "variant": selectedVariantIndex >= 0 ? variants[selectedVariantIndex] : null,
//                               "toppings": selectedToppings.map((i) => toppings[i]).toList(),
//                               "finalPrice": selectedPrice,
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                           child: const Text("Save")),
//                     ],
//                   )
//                 ],
//               ),
//             )
//           ],
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';

class ItemPopup extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemPopup({super.key, required this.item});

  @override
  State<ItemPopup> createState() => _ItemPopupState();
}

class _ItemPopupState extends State<ItemPopup> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List variants = [];
  final List toppings = [];
  double selectedPrice = 0.0;
  int selectedVariantIndex = -1;
  List<int> selectedToppings = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Initialize data
    variants.addAll(widget.item["variants"] ?? []);
    toppings.addAll(widget.item["toppings"] ?? []);
    selectedPrice = widget.item["price"]?.toDouble() ?? 0.0;

    // Auto-select first variant if available
    if (variants.isNotEmpty) {
      selectedVariantIndex = 0;
      selectedPrice = variants[0]["price"]?.toDouble() ?? selectedPrice;
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateTotalPrice() {
    double total = widget.item["price"]?.toDouble() ?? 0.0;
    
    // Add variant price
    if (selectedVariantIndex >= 0 && selectedVariantIndex < variants.length) {
      total = variants[selectedVariantIndex]["price"]?.toDouble() ?? total;
    }
    
    // Add toppings price
    for (int index in selectedToppings) {
      if (index < toppings.length) {
        total += toppings[index]["price"]?.toDouble() ?? 0.0;
      }
    }
    
    setState(() {
      selectedPrice = total;
    });
  }

  void _selectVariant(int index) {
    setState(() {
      selectedVariantIndex = index;
    });
    _calculateTotalPrice();
  }

  void _toggleTopping(int index) {
    setState(() {
      if (selectedToppings.contains(index)) {
        selectedToppings.remove(index);
      } else {
        selectedToppings.add(index);
      }
    });
    _calculateTotalPrice();
  }

  Future<void> _closePopup([Map<String, dynamic>? result]) async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.item["name"] ?? "Item",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Variations Section
                          if (variants.isNotEmpty) ...[
                            const Text(
                              "Variation",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF424242),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(variants.length, (index) {
                                final variant = variants[index];
                                final isSelected = selectedVariantIndex == index;
                                
                                return GestureDetector(
                                  onTap: () => _selectVariant(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? const Color(0xFFFF5722)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected 
                                            ? const Color(0xFFFF5722)
                                            : const Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "${variant['name']} ₹${variant['price']}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected 
                                            ? Colors.white
                                            : const Color(0xFF424242),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Toppings Section
                          if (toppings.isNotEmpty) ...[
                            const Text(
                              "Add Toppings",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF424242),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(toppings.length, (index) {
                                final topping = toppings[index];
                                final isSelected = selectedToppings.contains(index);
                                
                                return GestureDetector(
                                  onTap: () => _toggleTopping(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? const Color(0xFFFF5722)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected 
                                            ? const Color(0xFFFF5722)
                                            : const Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected) ...[
                                          const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          "${topping['name']} ₹${topping['price']}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected 
                                                ? Colors.white
                                                : const Color(0xFF424242),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price Display
                      Text(
                        "₹ ${selectedPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                      ),

                      // Action Buttons
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _closePopup(),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF666666),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              final result = {
                                "variant": selectedVariantIndex >= 0 
                                    ? variants[selectedVariantIndex] 
                                    : null,
                                "toppings": selectedToppings
                                    .map((i) => toppings[i])
                                    .toList(),
                                "finalPrice": selectedPrice,
                              };
                              _closePopup(result);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5722),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}