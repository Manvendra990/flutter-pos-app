import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:posapp/storage/db_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddItemPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? item;

  const AddItemPage({super.key, this.isEdit = false, this.item});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController shortCodeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  String? selectedCategory;
  String? selectedChoice;
  final Set<String> selectedOrderTypes = {};

  bool hasVariants = false;
  List<Map<String, TextEditingController>> variants = [];

  bool hasToppings = false;
  List<Map<String, TextEditingController>> toppings = [];

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    if (widget.isEdit && widget.item != null) {
      nameController.text = widget.item!['name'] ?? "";
      priceController.text = widget.item!['price']?.toString() ?? "";
      descriptionController.text = widget.item!['description'] ?? "";
      shortCodeController.text = widget.item!['short_code'] ?? "";
      unitController.text = widget.item!['unit'] ?? "";
      selectedCategory = widget.item!['category'];
      selectedChoice = widget.item!['choice'];

      // Order Types
      if (widget.item?['order_types'] != null) {
        final data = widget.item!['order_types'];
        if (data is String) {
          selectedOrderTypes.addAll(data.split(","));
        } else if (data is List) {
          selectedOrderTypes.addAll(List<String>.from(data));
        }
      }

      // Variants
      if (widget.item?['variants'] != null) {
        var data = widget.item!['variants'];
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (e) {
            data = [];
          }
        }
        if (data is List) {
          variants = data.map<Map<String, TextEditingController>>((variant) => {
                "name": TextEditingController(text: variant['name']?.toString() ?? ""),
                "price": TextEditingController(text: variant['price']?.toString() ?? ""),
              }).toList();
          hasVariants = variants.isNotEmpty;
        }
      }

      // Toppings
      if (widget.item?['toppings'] != null) {
        var data = widget.item!['toppings'];
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (e) {
            data = [];
          }
        }
        if (data is List) {
          toppings = data.map<Map<String, TextEditingController>>((top) => {
                "name": TextEditingController(text: top['name']?.toString() ?? ""),
                "price": TextEditingController(text: top['price']?.toString() ?? ""),
              }).toList();
          hasToppings = toppings.isNotEmpty;
        }
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var v in variants) {
      v['name']?.dispose();
      v['price']?.dispose();
    }
    for (var t in toppings) {
      t['name']?.dispose();
      t['price']?.dispose();
    }
    super.dispose();
  }

  void _addVariant() {
    setState(() {
      variants.add({
        "name": TextEditingController(),
        "price": TextEditingController(),
      });
    });
  }

  void _addTopping() {
    setState(() {
      toppings.add({
        "name": TextEditingController(),
        "price": TextEditingController(),
      });
    });
  }

  void _resetForm() {
    nameController.clear();
    shortCodeController.clear();
    priceController.clear();
    descriptionController.clear();
    unitController.clear();

    setState(() {
      selectedCategory = null;
      selectedChoice = null;
      selectedOrderTypes.clear();
      hasVariants = false;
      hasToppings = false;
      variants.clear();
      toppings.clear();
      _imageFile = null;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveItemToDatabase() async {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();

    if (name.isEmpty || (!hasVariants && priceText.isEmpty)) {
      _showSnackBar("Please fill required fields", isError: true);
      return;
    }

    double? price;
    if (!hasVariants) {
      price = double.tryParse(priceText);
    } else {
      price = 0;
    }

    // Prepare variants
    List<Map<String, dynamic>> variantData = [];
    if (hasVariants) {
      for (var v in variants) {
        final vName = v['name']!.text.trim();
        final vPrice = double.tryParse(v['price']!.text.trim()) ?? 0;
        if (vName.isNotEmpty) {
          variantData.add({"name": vName, "price": vPrice});
        }
      }
    }

    // Prepare toppings
    List<Map<String, dynamic>> toppingData = [];
    if (hasToppings) {
      for (var t in toppings) {
        final tName = t['name']!.text.trim();
        final tPrice = double.tryParse(t['price']!.text.trim()) ?? 0;
        if (tName.isNotEmpty) {
          toppingData.add({"name": tName, "price": tPrice});
        }
      }
    }

    if (widget.isEdit && widget.item != null) {
      final itemId = widget.item!['id'];
      await DBHelper.updateSubItem(
        itemId,
        name,
        price ?? 0,
        shortCode: shortCodeController.text.trim(),
        unit: unitController.text.trim(),
        description: descriptionController.text.trim(),
        choice: selectedChoice,
        orderTypes: selectedOrderTypes.join(','),
        imagePath: _imageFile?.path,
        variants: variantData,
        isvarient: hasVariants,
        toppings: toppingData,
        hastoppings: hasToppings,
      );
      _showSnackBar("Item updated successfully", isError: false);
    } else {
      final categoryId = await DBHelper.insertItem(selectedCategory!);
      await DBHelper.insertSubItem(
        categoryId,
        name,
        price ?? 0,
        shortCode: shortCodeController.text.trim(),
        unit: unitController.text.trim(),
        description: descriptionController.text.trim(),
        choice: selectedChoice,
        orderTypes: selectedOrderTypes.join(','),
        imagePath: _imageFile?.path,
        variants: variantData,
        isvarient: hasVariants,
        toppings: toppingData,
        hastoppings: hasToppings,
      );
      _showSnackBar("Item saved successfully", isError: false);
    }

    _resetForm();
    Navigator.pop(context, true);
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Custom App Bar
              _buildCustomAppBar(),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoCard(),
                      const SizedBox(height: 20),
                      _buildImageUploadCard(),
                      const SizedBox(height: 20),
                      _buildCategoryCard(),
                      const SizedBox(height: 20),
                      _buildChoiceCard(),
                      const SizedBox(height: 20),
                      _buildVariantsCard(),
                      const SizedBox(height: 20),
                      _buildToppingsCard(),
                      const SizedBox(height: 30),
                      _buildSaveButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEdit ? "Edit Item" : "Add New Item",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                widget.isEdit ? "Update item details" : "Create a new menu item",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget child, {IconData? icon}) {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.blue[600], size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard("Basic Information", Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField("Item Name *", controller: nameController)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("Short Code", controller: shortCodeController)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField("Price *", controller: priceController, isNumber: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("Unit", controller: unitController)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField("Description", controller: descriptionController, maxLines: 3),
        const SizedBox(height: 20),
        _buildOrderTypesSection(),
      ],
    ), icon: Icons.info_outline);
  }

  Widget _buildImageUploadCard() {
    return _buildCard("Product Image", Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.blue[600], size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Tap to upload image",
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Supported formats: JPG, PNG",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    ), icon: Icons.image);
  }

  Widget _buildCategoryCard() {
    return _buildCard("Category", Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            hint: const Text("Select Category"),
            value: selectedCategory,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            items: [
              'Favorite Items',
              'Veg Burgers',
              'Appetizers',
              'Cakes',
              'Combos',
              'Desserts',
              'Fried Rice',
              'Ice Creams'
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) => setState(() => selectedCategory = value),
          ),
        ),
      ],
    ), icon: Icons.category);
  }

  Widget _buildChoiceCard() {
    return _buildCard("Food Type", Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ["Veg", "Non-Veg", "Egg", "Vegan"].map((choice) {
            final isSelected = selectedChoice == choice;
            return GestureDetector(
              onTap: () => setState(() => selectedChoice = choice),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green[500] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.green[500]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getChoiceColor(choice),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      choice,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ), icon: Icons.restaurant_menu);
  }

  Widget _buildVariantsCard() {
    return _buildCard("Variants", Column(
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: hasVariants,
                activeColor: Colors.blue[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (value) {
                  setState(() {
                    hasVariants = value!;
                    if (hasVariants && variants.isEmpty) {
                      _addVariant();
                    } else if (!hasVariants) {
                      variants.clear();
                    }
                  });
                },
              ),
            ),
            const Text("This item has variants", style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        if (hasVariants) ...[
          const SizedBox(height: 16),
          Column(
            children: [
              for (int i = 0; i < variants.length; i++) _buildVariantRow(i),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Add Variant"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[600],
                  backgroundColor: Colors.blue[50],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _addVariant,
              ),
            ],
          ),
        ],
      ],
    ), icon: Icons.tune);
  }

  Widget _buildToppingsCard() {
    return _buildCard("Toppings", Column(
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: hasToppings,
                activeColor: Colors.blue[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (value) {
                  setState(() {
                    hasToppings = value!;
                    if (hasToppings && toppings.isEmpty) {
                      _addTopping();
                    } else if (!hasToppings) {
                      toppings.clear();
                    }
                  });
                },
              ),
            ),
            const Text("This item has toppings", style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        if (hasToppings) ...[
          const SizedBox(height: 16),
          Column(
            children: [
              for (int i = 0; i < toppings.length; i++) _buildToppingRow(i),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Add Topping"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange[600],
                  backgroundColor: Colors.orange[50],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _addTopping,
              ),
            ],
          ),
        ],
      ],
    ), icon: Icons.local_pizza);
  }

  Widget _buildTextField(String label, {
    TextEditingController? controller,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildOrderTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Order Types *", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ["Delivery", "Bill", "Dine In"].map((option) {
            final isSelected = selectedOrderTypes.contains(option);
            return GestureDetector(
              onTap: () {
                setState(() {
                  isSelected ? selectedOrderTypes.remove(option) : selectedOrderTypes.add(option);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[500] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.blue[500]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVariantRow(int index) {
    final variant = variants[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[25],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: variant['name']!.text.isEmpty ? null : variant['name']!.text,
                hint: const Text("Select Variant"),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                items: ["Small", "Medium", "Large", "Family Pack"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => variant['name']!.text = value ?? ""),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: variant['price'],
              decoration: InputDecoration(
                labelText: "Price",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[600]),
              onPressed: () => setState(() => variants.removeAt(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToppingRow(int index) {
    final topping = toppings[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[25],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: topping['name'],
              decoration: InputDecoration(
                labelText: "Topping Name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: topping['price'],
              decoration: InputDecoration(
                labelText: "Price",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[600]),
              onPressed: () => setState(() => toppings.removeAt(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[700]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveItemToDatabase,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          widget.isEdit ? "Update Item" : "Save Item",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getChoiceColor(String choice) {
    switch (choice) {
      case 'Veg':
        return Colors.green;
      case 'Non-Veg':
        return Colors.red;
      case 'Egg':
        return Colors.orange;
      case 'Vegan':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }
}