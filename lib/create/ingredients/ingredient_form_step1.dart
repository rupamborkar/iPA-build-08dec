import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_app_login/create/ingredients/form_fields.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientFormStep1 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> data;

  const IngredientFormStep1({
    required this.formKey,
    required this.data,
    super.key,
  });

  @override
  State<IngredientFormStep1> createState() => _IngredientFormStep1State();
}

class _IngredientFormStep1State extends State<IngredientFormStep1> {
  String? selectedUnit; // Variable to hold selected unit

  String? selectedSupplierId;

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  // List<String> supplierList = [];
  List<Map<String, dynamic>> supplierList = [];
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

  int Result = 0;
  void calculate() {
    final int price = widget.data['price'] is int
        ? widget.data['price'] as int
        : int.tryParse(widget.data['price'].toString()) ?? 0;

    final int tax = widget.data['tax'] is int
        ? widget.data['tax'] as int
        : int.tryParse(widget.data['tax'].toString()) ?? 1;

    final int result = tax == 0 ? 0 : price + tax;

    setState(() {
      Result = result;
      widget.data['cost'] = Result;
    });

    print('Price: $price, Quantity: $tax, Result: $Result');
  }

  @override
  void initState() {
    super.initState();

    _loadTokenAndFetchDetails();
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

      await fetchSupplierList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
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
        });
      } else {
        print(
            'Failed to load supplier data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: widget.formKey,
            //return
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed title at the top
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Basic Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                // Scrollable form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        buildTextField(
                          'Ingredient Name *',
                          'e.g. Carrot, Almond',
                          onSaved: (value) {
                            widget.data['name'] = value;
                          },
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        buildDropdownField(
                          'Category *',
                          categories,
                          onSaved: (value) {
                            widget.data['category'] = value;
                          },
                          onChanged: (value) {
                            widget.data['category'] = value;
                          },
                        ),
                        const SizedBox(height: 16),

                        buildDropdownField(
                          'Supplier *',
                          supplierList
                              .map((e) => e['name']! as String)
                              .toList(),
                          onSaved: (value) {
                            final selectedSupplier = supplierList.firstWhere(
                              (supplier) => supplier['name'] == value,
                            );
                            widget.data['supplier_id'] =
                                int.tryParse(selectedSupplier['id'] ?? '0') ??
                                    0;
                            //selectedSupplier['id'];
                          },
                          onChanged: (value) {
                            final selectedSupplier = supplierList.firstWhere(
                              (supplier) => supplier['name'] == value,
                            );
                            setState(() {
                              selectedSupplierId = selectedSupplier['id'];
                            });
                          },
                        ),

                        const SizedBox(height: 16),
                        buildTextField(
                          'Supplier Product Code',
                          'e.g. CB12234',
                          onSaved: (value) {
                            widget.data['product_code'] = value;
                          },
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        _buildQuantityAndUnitFields(),

                        const SizedBox(height: 16),

                        buildTextField(
                          'Tax (%)',
                          'Enter a tax %',
                          onSaved: (value) {
                            widget.data['tax'] =
                                int.tryParse(value ?? '1') ?? 1;
                            calculate();
                          },
                          // onChanged: (value) {},
                          onChanged: (value) {
                            setState(() {
                              widget.data['tax'] = int.tryParse(value) ?? 1;
                            });
                            calculate(); // Recalculate cost when the quantity is changed
                          },
                        ),
                        const SizedBox(height: 16),

                        buildTextField(
                          'Price',
                          'Enter a price',
                          onSaved: (value) {
                            widget.data['price'] =
                                int.tryParse(value ?? '0') ?? 0;
                            calculate(); // Recalculate cost when the price is saved
                          },
                          onChanged: (value) {
                            setState(() {
                              widget.data['price'] = int.tryParse(value) ?? 0;
                            });
                            calculate();
                            // onSaved: (value) {
                            //   widget.data['price'] = value;
                            // widget.data['price'] = int.tryParse(value) ?? 0;
                            // calculate(); // Recalculate cost on change
                          },
                        ),
                        const SizedBox(height: 16),
                        buildTextField(
                          'Comments',
                          'Enter the comments',
                          onSaved: (value) {
                            widget.data['comments'] = value;
                          },
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        // Next button can be added here
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget _buildQuantityAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity Purchased',
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
              width: 100.0,
              height: 40,
              child: TextFormField(
                //initialValue: widget.data['quantity'],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  hintStyle: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(10, 15, 13, 1)),
                  // const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  // isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                onSaved: (value) {
                  widget.data['quantity'] = int.tryParse(value ?? '1') ?? 1;
                  //calculate(); // Recalculate cost when the quantity is saved
                },
                // onChanged: (value) {
                //   setState(() {
                //     widget.data['quantity'] = int.tryParse(value) ?? 1;
                //   });
                //   calculate(); // Recalculate cost when the quantity is changed
                // },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 220.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedUnit,
                hint: const Text(
                  'Select unit',
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(10, 15, 13, 1)),
                  //TextStyle(color: Colors.grey),
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
                    //selectedUnit = newValue;
                    widget.data['quantity_unit'] = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  // isDense: true,
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
}
