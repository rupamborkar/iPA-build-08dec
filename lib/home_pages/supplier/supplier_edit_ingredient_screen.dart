import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupplierEditIngredientScreen extends StatefulWidget {
  final String supplierId;

  const SupplierEditIngredientScreen({super.key, required this.supplierId});

  @override
  _SupplierEditIngredientScreenState createState() =>
      _SupplierEditIngredientScreenState();
}

class _SupplierEditIngredientScreenState
    extends State<SupplierEditIngredientScreen> {
  final TextEditingController ingredientNameController =
      TextEditingController();

  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage for JWT token
  String? _jwtToken;
  List<dynamic> ingredients = [];
  bool isAddingIngredient = false; // Controls visibility of add form

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchIngredients();
  }

  Future<void> _loadTokenAndFetchIngredients() async {
    try {
      // Retrieve JWT token from secure storage
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });

      await fetchIngredients();
    } catch (e) {
      print("Error loading token or fetching ingredients: $e");
    }
  }

  Future<void> fetchIngredients() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/supplier/${widget.supplierId}/supplier_ingredients'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          ingredients = data; // Assign fetched data to the list
        });
      } else {
        print(
            'Failed to load ingredients. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredients: $e');
    }
  }

  Future<void> addIngredient(String ingredientName) async {
    if (_jwtToken == null || ingredientName.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/supplier/${widget.supplierId}/supplier_ingredients'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': ingredientName}),
      );

      if (response.statusCode == 201) {
        // Successfully added the ingredient
        fetchIngredients(); // Refresh the list
        ingredientNameController.clear();
        setState(() {
          isAddingIngredient = false;
        });
      } else {
        print('Failed to add ingredient. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding ingredient: $e');
    }
  }

  Future<void> deleteIngredient(String ingredientId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'api/supplier/${widget.supplierId}/supplier_ingredients/$ingredientId'),
        //('$baseUrl/api/supplier/$supplierId'),
        headers: {
          'Authorization': 'Bearer $_jwtToken', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredients deleted successfully')),
        );
        Navigator.of(context).pop(); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete supplier.')),
        );
      }
    } catch (e) {
      print('Error deleting Ingredients: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the Ingredients.')),
      );
    }
  }

  void confirmDelete(String ingredientId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this supplier?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteIngredient(
                    ingredientId); // Call deleteSupplier with the supplier ID
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  // void deleteIngredient(int index) {
  //   setState(() {
  //     ingredients.removeAt(index);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Edit Ingredients',
            style: TextStyle(
              color: Color.fromRGBO(10, 15, 13, 8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _editIngredientsTab(),
    );
  }

  Widget _editIngredientsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Ingredient Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Ingredient',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(
                    isAddingIngredient ? Icons.close : Icons.add), // Add icon
                onPressed: () {
                  setState(() {
                    isAddingIngredient = !isAddingIngredient;
                    if (!isAddingIngredient) {
                      ingredientNameController.clear();
                    }
                  });
                },
              ),
            ],
          ),
        ),
        if (isAddingIngredient)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingredient Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(150, 152, 151, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: ingredientNameController,
                      hintText: 'Oats',
                      isEnabled: true,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          // if (ingredientNameController.text.isNotEmpty) {
                          //   addIngredient(ingredientNameController.text);
                          // }
                        },
                        child: const Text(
                          'Delete',
                          style:
                              TextStyle(color: Color.fromRGBO(0, 128, 128, 1)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              // final ingredient = ingredients[index]['name'] ?? 'Unknown';
              // final ingredientId = ingredient['id'];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side:
                      const BorderSide(color: Color.fromRGBO(231, 231, 231, 1)),
                  // borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    //ingredient,
                    ingredient['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(10, 15, 13, 1),
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () => confirmDelete(ingredient['id'].toString()),
                    //deleteIngredient(ingredientId),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Submit button at the bottom
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle update action here
                if (ingredientNameController.text.isNotEmpty) {
                  addIngredient(ingredientNameController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 128, 128, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w300,
              color: Color.fromRGBO(10, 15, 13, 1)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14.0),
        ),
      ),
    );
  }
}
