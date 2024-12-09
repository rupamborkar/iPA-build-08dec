//working code with navigating through edit tabs
import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_ingredient_recipe.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_recipe_details.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_tabs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMethod extends StatefulWidget {
  final String recipeId;
  const EditMethod({super.key, required this.recipeId});

  @override
  _EditMethodState createState() => _EditMethodState();
}

class _EditMethodState extends State<EditMethod> {
  //String preparationMethod = '';

  final List<String> massUnits = ['kg', 'g', 'lbs', 'oz']; // List of mass units

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<Map<String, dynamic>?>? recipeData;
  String? _jwtToken; // Initialize as nullable.

  final TextEditingController _preparationMethodController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      // Retrieve JWT token from secure storage
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
        recipeData = fetchRecipeDetails(); // Fetch details once token is set.
      });
    } catch (e) {
      print("Error loading token or fetching recipe details: $e");
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    if (_jwtToken == null) {
      throw Exception('JWT token is null');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
        },
      );

      if (response.statusCode == 200) {
        //return jsonDecode(response.body);
        final data = jsonDecode(response.body);
        _preparationMethodController.text = data['method'] ?? '';
        return data;
      } else {
        throw Exception('Failed to load recipe data');
      }
    } catch (e) {
      throw Exception('Error fetching recipe data: $e');
    }
  }

  Future<void> _updateRecipe() async {
    if (_jwtToken == null) {
      throw Exception('JWT token is null');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'method': _preparationMethodController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update recipe');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating recipe: $e')),
      );
    }
  }

  // void _saveRecipe() {
  //   // Logic to save or update the recipe
  //   print("Recipe saved with preparation method: $preparationMethod");
  //   Navigator.pop(context);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to Prepare',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 19.5 /
                    13, // line-height divided by font-size to get height factor
                textBaseline: TextBaseline.alphabetic,
                // decoration: TextDecoration
                //     .underline, // Since CSS has underline, adding here
                decorationStyle: TextDecorationStyle
                    .solid, // Matches the CSS "none" skip-ink
                decorationThickness:
                    1.0, // Optional, adjusts underline thickness if needed
                decorationColor:
                    Color.fromRGBO(10, 15, 13, 1), // Customize as needed
              ),

              //TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              ' ', _preparationMethodController,
              // "Mix in a bowl all ingredients together except for the oil"
              //     "Once incorporated, add slowly the olive oil until combined"
              //     "Check seasoning"
              //     "Keep refrigerated",
              maxLines: 8,
              // onChanged: (value) {
              //   preparationMethod = value;
              // },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      //String hint,
      {int maxLines = 4}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              //hintText: hint,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            // onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// Main widget for EditWastage with IngredientTabs
class EditMethodTab extends StatelessWidget {
  final String recipeId;

  const EditMethodTab({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return RecipeTabs(
      initialIndex: 2, // Start with the 'Wastage' tab
      tabViews: [
        RecipeEditDetails(
          recipeId: recipeId,
        ), // Content for the 'Details' tab
        EditIngredientDetails(
          recipeId: recipeId,
        ), // Content for the 'intredient' tab
        EditMethod(
          recipeId: recipeId,
        ), // Content for the 'method' tab
      ],
    );
  }
}
