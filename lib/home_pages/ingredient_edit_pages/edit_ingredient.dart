import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_app_login/home_pages/ingredient_edit_pages/edit_measurements.dart';
import 'package:flutter_app_login/home_pages/ingredient_edit_pages/edit_wastage.dart';
import 'package:flutter_app_login/home_pages/ingredient_edit_pages/ingredient_tab.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For JWT storage
import 'package:http/http.dart' as http;

class EditIngredientsDetail extends StatefulWidget {
  final String ingredientId; // Ingredient ID for fetching specific data
  // final String jwtToken; // JWT token for authentication

  const EditIngredientsDetail({
    required this.ingredientId,
    // required this.jwtToken,
    Key? key,
  }) : super(key: key);

  @override
  State<EditIngredientsDetail> createState() => _EditIngredientsDetailState();
}

class _EditIngredientsDetailState extends State<EditIngredientsDetail> {
  Map<String, dynamic>? ingredientData;

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;

  List<Map<String, dynamic>> supplierList = [];
  String? selectedSupplierId;
  final List<String> categories = [
    'Salad',
    'herb',
    'vegetable',
    'mushroom',
    'fresh nut',
    'meat',
    'fruit',
    'seafood',
    'cured meat',
    'cheese',
    'dairy',
    'dry good',
    'grain',
    'flour',
    'spices',
    'chocolate',
    'oil',
    'vinegar',
    'alcohol',
    'bakery',
    'flower',
    'grains/seeds',
    'nuts',
    'sugar',
    'dryfruits',
    'ice cream',
    'consumable',
    'Beverage',
    'Dessert',
    'snack',
    'Drink'
  ];
  String? selectedCategory;
  String? selectedUnit; // Variable to hold selected unit
  final List<String> massUnits = [
    'gm',
    'kg',
    'oz',
    'lbs',
    'tonne',
    'ml',
    'cl',
    'dl',
    'L',
    'Pint',
    'Quart',
    'fl oz',
    'gallon',
    'Each',
    'Serving',
    'Box',
    'bag',
    'Can',
    'Carton',
    'Jar',
    'Punnet',
    'Container',
    'Packet',
    'Roll',
    'Bunch',
    'Bottle',
    'Tin',
    'tub',
    'Piece',
    'Block',
    'Portion',
    'Dozen',
    'Bucket',
    'Slice',
    'Pinch',
    'Tray',
    'Teaspoon',
    'Tablespoon',
    'Cup'
  ];

  // Controllers for text fields
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController supplierController;
  late TextEditingController supplierProductCController;
  late TextEditingController quantityController;
  late TextEditingController quantityUnitController;
  late TextEditingController taxController;
  late TextEditingController priceController;
  late TextEditingController commentsController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTokenAndFetchDetails();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    categoryController = TextEditingController();
    supplierController = TextEditingController();
    supplierProductCController = TextEditingController();
    quantityController = TextEditingController();
    quantityUnitController = TextEditingController();
    taxController = TextEditingController();
    priceController = TextEditingController();
    commentsController = TextEditingController();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });

      await fetchIngredientDetails();
      fetchSupplierList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchIngredientDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients/${widget.ingredientId}/full'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ingredientData = data;
          _populateControllers(data);
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

  Future<void> fetchSupplierList() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/supplier/supplier_list'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> suppData = json.decode(response.body);
        setState(() {
          supplierList = suppData.map((supplier) {
            return {
              'name': supplier['name'],
              'id': supplier['supplier_id'],
            };
          }).toList();
          print(supplierList);
        });
      } else {
        print(
            'Failed to load supplier data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
    }
  }

  void _populateControllers(Map<String, dynamic> data) {
    nameController.text = data['name'] ?? '';
    categoryController.text = data['category'] ?? '';
    supplierController.text = data['supplier'] ?? '';
    supplierProductCController.text = data['product_code'] ?? '';
    quantityController.text = data['quantity_purchased']?.toString() ?? '';
    quantityUnitController.text = data['quantity_unit'] ?? '';
    taxController.text = data['tax']?.toString() ?? '';
    priceController.text = data['price']?.toString() ?? '';
    commentsController.text = data['comments'] ?? '';

    setState(() {
      selectedUnit = data['quantity_unit'];
      selectedCategory = data['category']; // Add this variable if not present
    });
  }

  Future<void> _updateIngredientDetails() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/ingredients/${widget.ingredientId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text,
          'category': categoryController.text,
          'supplier': selectedSupplierId,
          //'supplier': supplierController.text,
          'product_code': supplierProductCController.text,
          'quantity_purchased': quantityController.text,
          "quantity_unit": quantityUnitController.text,
          'tax': taxController.text,
          'price': priceController.text,
          // 'price': double.tryParse(priceController.text) ?? 0.0,
          'comments': commentsController.text,
          'cost': ingredientData?['cost'],
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient updated successfully!')),
        );

        Navigator.of(context).pop(true);
      } else {
        throw Exception('Failed to update ingredient details');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating ingredient: $error')),
      );
    }
  }

  int Result = 0;
  void calculate() {
    final int price = int.tryParse(priceController.text) ?? 0;

    final int tax = int.tryParse(taxController.text) ?? 0;

    final int result = price + tax;

    setState(() {
      Result = result;
      ingredientData?['cost'] = Result;
    });

    print('Price: $price, Tax: $tax, Result: $Result');
  }

  @override
  Widget build(BuildContext context) {
    if (ingredientData == null) {
      return Scaffold(
        // appBar: AppBar(title: const Text('Edit Ingredient Details')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Ingredient', nameController,
                    onSaved: (value) {}, onChanged: (value) {}),
                const SizedBox(height: 10),
                buildDropdownField(
                    'Category',
                    categories,
                    initialValue: ingredientData?['category'],
                    categoryController),
                const SizedBox(height: 10),
                buildSuppDropdownField(
                  'Supplier *',
                  supplierList.map((e) => e['name']! as String).toList(),
                  initialValue: ingredientData?['supplier'],
                  onSaved: (value) {
                    final selectedSupplier = supplierList.firstWhere(
                      (supplier) => supplier['name'] == value,
                    );
                    // widget.data['supplier'] =
                    supplierController =
                        (int.tryParse(selectedSupplier['id'] ?? '0') ?? 0)
                            as TextEditingController;
                    //selectedSupplier['id'];
                  },
                  onChanged: (value) {
                    final selectedSupplier = supplierList.firstWhere(
                      (supplier) => supplier['name'] == value,
                    );
                    setState(() {
                      selectedSupplierId = selectedSupplier['id'];
                      print(selectedSupplierId);
                    });
                  },
                ),

                // _buildTextField('Supplier', supplierController),
                const SizedBox(height: 10),
                _buildTextField(
                    'Supplier_product_code', supplierProductCController,
                    onSaved: (value) {}, onChanged: (value) {}),
                const SizedBox(height: 10),
                _buildQuantityAndUnitFields(quantityController),
                const SizedBox(height: 10),
                _buildTextField(
                  'Tax',
                  taxController,
                  onSaved: (value) {
                    ingredientData?['tax'] = int.tryParse(value ?? '1') ?? 1;
                    calculate();
                  },
                  // onChanged: (value) {},
                  onChanged: (value) {
                    setState(() {
                      ingredientData?['tax'] = int.tryParse(value) ?? 1;
                    });
                    calculate(); // Recalculate cost when the quantity is changed
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField('Price', priceController, isNumber: true,
                    onSaved: (value) {
                  ingredientData?['price'] = int.tryParse(value ?? '0') ?? 0;
                  calculate(); // Recalculate cost when the price is saved
                }, onChanged: (value) {
                  setState(() {
                    ingredientData?['price'] = int.tryParse(value) ?? 0;
                  });
                  calculate();
                }),
                const SizedBox(height: 10),
                _buildTextField('Comments', commentsController,
                    onChanged: (value) {}, onSaved: (value) {}),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            //width: double.infinity,
            width: 353,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _updateIngredientDetails();
                // Handle update logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 128, 128, 1),
              ),
              child: Text(
                'Update',
                style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color.fromRGBO(253, 253, 253, 1)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false,
      required Null Function(dynamic value) onSaved,
      required Null Function(dynamic value) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color.fromRGBO(150, 152, 151, 1),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40, // Fixed height of 40px
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              //hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                  color: Color.fromRGBO(10, 15, 13, 1)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1.0, style: BorderStyle.solid),
              ),
            ),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            //maxLines: maxLines,
            validator: (value) {
              if (label.contains('*') &&
                  (value == null || value.trim().isEmpty)) {
                return 'Enter the ${label.replaceAll('*', '').trim()}';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget buildDropdownField(
      String label, List<String> items, TextEditingController controller,
      {required initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: const TextStyle(
              color: Color.fromRGBO(150, 152, 151, 1),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40,
          child: DropdownButtonFormField<String>(
            value: initialValue,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                // value: selectedCategory,
                //controller.text.isNotEmpty ? controller.text : null,
                value: item,
                child: SizedBox(
                  width: 150, // Set the width of the dropdown item
                  height: 40,
                  child: Text(item),
                ),
              );
            }).toList(),
            //  onChanged: (value) {},
            // onChanged: (value) {
            //   if (value != null) {
            //     controller.text = value; // Update the controller
            //   }
            // },
            onChanged: (newValue) {
              setState(() {
                selectedCategory = newValue; // Update selected value
                controller.text = newValue ?? '';
              });
            },

            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                  color: Color.fromRGBO(10, 15, 13, 1)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1.0, style: BorderStyle.solid),
              ),
            ),

            // decoration: InputDecoration(
            //   hintText: 'Select $label',
            //   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            // ),
            dropdownColor: Color.fromRGBO(253, 253, 253, 1),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityAndUnitFields(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Qty Purchased',
          style: TextStyle(
            color: Color.fromRGBO(150, 152, 151, 1),
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            SizedBox(
              width: 120,
              height: 40,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  //hintText: '1',
                  hintStyle: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(10, 15, 13, 1)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  //isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantity is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 225.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedUnit ?? quantityUnitController.text,
                // value: selectedUnit,
                hint: const Text(
                  'bag',
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(10, 15, 13, 1)),
                ),
                items: massUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: SizedBox(
                      width: 150, // Set the width of the dropdown item
                      height: 40,
                      child: Text(unit),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue;
                    quantityUnitController.text = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (selectedUnit == null) {
                    return 'Unit is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  //  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                dropdownColor: Color.fromRGBO(253, 253, 253, 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSuppDropdownField(
    String label,
    List<String> items, {
    required Function(String?) onSaved,
    Function(String?)? onChanged,
    required initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40,

          child: DropdownButtonFormField<String>(
            value: initialValue,
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: SizedBox(
                  width: 150, // Set the width of the dropdown item
                  height: 40,
                  child: Text(item),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            onSaved: onSaved,
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            dropdownColor: Color.fromRGBO(253, 253, 253, 1),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    supplierController.dispose();
    priceController.dispose();
    super.dispose();
  }
}

class IngredientEdit extends StatelessWidget {
  final String ingredientId;
  final String jwtToken;

  const IngredientEdit({
    required this.ingredientId,
    required this.jwtToken,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IngredientTabs(
      initialIndex: 0, // Start with the 'Details' tab
      tabViews: [
        EditIngredientsDetail(
          ingredientId: ingredientId,
          // jwtToken: jwtToken,
        ),
        EditMeasurementsContent(
          ingredientId: ingredientId,
          //jwtToken: jwtToken,
        ),
        EditWastageContent(
          ingredientId: ingredientId,
          //jwtToken: jwtToken,
        ),
      ],
    );
  }
}
