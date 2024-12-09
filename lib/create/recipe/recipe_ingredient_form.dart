import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_app_login/create/recipe/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeIngredientForm extends StatefulWidget {
  final Function(List<Map<String, String>>) onSave;

  const RecipeIngredientForm({super.key, required this.onSave});

  @override
  _RecipeIngredientFormState createState() => _RecipeIngredientFormState();
}

class _RecipeIngredientFormState extends State<RecipeIngredientForm> {
  final List<Map<String, String>> ingredients = [];
  String? selectedIngreId;
  String? selectedUnit;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
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
  List<Map<String, dynamic>> ingredientList = [];

  void addIngredient() {
    setState(() {
      ingredients.add({
        "id": "",
        // "ingredient_name": "",
        "quantity": "",
        "quantity_unit": "",
        // "wastage": "",
        "cost": "",
      });
    });
  }

  @override
  void initState() {
    super.initState();
    addIngredient(); // Start with one ingredient entry
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

      await fetchIngredientList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchIngredientList() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients/ingredients_list'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        setState(() {
          ingredientList = fetchedData.map((item) {
            return {
              'id': item['ingredient_id'],
              'name': item['name'],
              'ingredient_cost': item['ingredient_cost'],
            };
          }).toList();
        });
      } else {
        print(
            'Failed to load ingredeint data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Ingredient ${index + 1}',
              //   style: const TextStyle(fontWeight: FontWeight.bold),
              // ),

              buildDropdownIngreField(
                label: 'Ingredient Name',
                items: ingredientList,
                onChanged: (value) {
                  final selectedIngredient = ingredientList.firstWhere(
                    (ingredient) => ingredient['name'] == value,
                  );
                  setState(() {
                    ingredients[index]['ingredient_id'] =
                        selectedIngredient['id'];
                  });
                },
                onSaved: (value) {
                  final selectedIngredient = ingredientList.firstWhere(
                    (ingredient) => ingredient['name'] == value,
                  );
                  ingredients[index]['ingredient_id'] =
                      selectedIngredient['id'];
                },
              ),

              const SizedBox(height: 8),

              _buildQuantityAndUnitFields(),
              const SizedBox(height: 8),
              buildDisabledTextField(
                'Wastage',
                'None',
                onChanged: (value) {
                  ingredient['wastage'] = value;
                },
              ),
              const SizedBox(height: 8),
              buildDisabledTextField(
                'Cost',
                'N/A',
                onChanged: (value) {
                  ingredient['cost'] = value;
                },
              ),
              const SizedBox(height: 8),
              // const Divider(height: 16, color: Colors.grey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'delete');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(244, 67, 54, 1),
                    ),
                    child: const Text('Delete Ingredient'),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget buildDropdownIngreField({
    required String label,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
    required FormFieldSetter<String?> onSaved,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          decoration: InputDecoration(
            labelText: label,
            // border: OutlineInputBorder(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['name'], // Dropdown displays the ingredient name
              child: Text(item['name']),
            );
          }).toList(),
          onChanged: onChanged,
          onSaved: onSaved,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an ingredient';
            }
            return null;
          },
        ),
      ),
    ]);
  }

  Widget _buildQuantityAndUnitFields() {
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
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 120.0,
              height: 40,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '1',
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 190.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedUnit,
                hint: const Text(
                  'bag',
                  style: TextStyle(color: Colors.grey),
                ),
                items: massUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
