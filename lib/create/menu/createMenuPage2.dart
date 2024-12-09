import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateMenuPage2 extends StatefulWidget {
  final String token;
  final Map<String, dynamic> menuData;

  const CreateMenuPage2(
      {super.key, required this.menuData, required this.token});

  @override
  _CreateMenuPage2State createState() => _CreateMenuPage2State();
}

class _CreateMenuPage2State extends State<CreateMenuPage2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> recipeList = [];
  String? _jwtToken;

  final List<String> massUnits = [
    'Gram(g)',
    'Kilogram(kg)',
    'Ounce(oz)',
    'Liter(L)',
    'Each(ea)',
    'Serving(serv)',
    'Piece(piece)',
    'Dozen(dozen)',
    'Slice(slice)',
    'Cup(cup)',
  ];

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
      await fetchRecipeList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchRecipeList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/recipes_list'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> recipeData = json.decode(response.body);
        setState(() {
          recipeList = recipeData.map((recipe) {
            return {
              'name': recipe['name'],
              'id': recipe['id'],
              'cost': recipe['cost'],
              'selling_price': recipe['selling_price'],
              'food_cost': recipe['food_cost'],
              'net_earnings': recipe['net_earnings'],
            };
          }).toList();
        });
      } else {
        print(
            'Failed to load recipe data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipe data: $e');
    }
  }

  void addRecipeCard() {
    setState(() {
      recipes.add({
        'id': null,
        'name': null,
        'quantity': null,
        'quantity_unit': null,
        'cost': null,
        'selling_price': null,
        'food_cost': null,
        'net_earnings': null,
      });
    });
  }

  void saveMenu() async {
    final dataToSend = {
      ...widget.menuData,
      "recipes": recipes.where((recipe) {
        return recipe['id'] != null &&
            recipe['quantity'] != null &&
            recipe['quantity_unit'] != null;
      }).toList(),
    };

    print("Data to Send: ${json.encode(dataToSend)}");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/menu/add_menu'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        },
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu saved successfully!')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        throw Exception('Failed to save menu');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Widget buildRecipeCard(int index) {
    return Card(
      color: const Color.fromRGBO(253, 253, 253, 1),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side:
            const BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDropdownField(
              'Recipe Name',
              recipeList.map((e) => e['name'] as String).toList(),
              onChanged: (value) {
                final selectedRecipe =
                    recipeList.firstWhere((recipe) => recipe['name'] == value);
                setState(() {
                  recipes[index]['name'] = value;
                  recipes[index]['id'] = selectedRecipe['id'];
                  recipes[index]['cost'] = selectedRecipe['cost'];
                  recipes[index]['selling_price'] =
                      selectedRecipe['selling_price'];
                  recipes[index]['food_cost'] = selectedRecipe['food_cost'];
                  recipes[index]['net_earnings'] =
                      selectedRecipe['net_earnings'];
                });
              },
            ),
            const SizedBox(height: 10),
            _buildQuantityAndUnitFields(index),
            const SizedBox(height: 10),
            _buildDisabledTextField(
                'Cost', recipes[index]['cost']?.toString() ?? 'N/A'),
            _buildDisabledTextField('Selling Price',
                recipes[index]['selling_price']?.toString() ?? 'N/A'),
            _buildDisabledTextField(
                'Food Cost', recipes[index]['food_cost']?.toString() ?? 'N/A'),
            _buildDisabledTextField('Net Earnings',
                recipes[index]['net_earnings']?.toString() ?? 'N/A'),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    recipes.removeAt(index);
                  });
                },
                child: const Text('Delete Recipe',
                    style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityAndUnitFields(int index) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                recipes[index]['quantity'] = double.tryParse(value);
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Unit'),
            items: massUnits.map((unit) {
              return DropdownMenuItem(value: unit, child: Text(unit));
            }).toList(),
            onChanged: (value) {
              setState(() {
                recipes[index]['quantity_unit'] = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildDropdownField(String label, List<String> items,
      {Function(String?)? onChanged}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDisabledTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5.0),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color.fromRGBO(231, 231, 231, 1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Menu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Recipe'),
                IconButton(
                    icon: const Icon(Icons.add), onPressed: addRecipeCard),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) => buildRecipeCard(index),
              ),
            ),
            Container(
              width: double.infinity,
              height: 50, // Adjust height as needed
              child: ElevatedButton(
                onPressed: saveMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF008080), // Teal background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded edges
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16), // Button padding
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white, // White text color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
