import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_app_login/create/recipe/step_indicator.dart';
import 'recipe_step1.dart';
import 'recipe_step2.dart';
import 'recipe_step3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeCreateForm extends StatefulWidget {
  final String token;
  const RecipeCreateForm({super.key, required this.token});

  @override
  _RecipeCreateFormState createState() => _RecipeCreateFormState();
}

class _RecipeCreateFormState extends State<RecipeCreateForm> {
  final Map<String, dynamic> recipeData = {
    "name": "",
    "category": "",
    "origin": "",
    "use_as_ingredeint": '',
    "tag": '',
    // "tags": [],
    "serving_quantity": 0,
    "serving_quantity_unit": "",
    "cost": 0.0,
    "tax": 0.0,
    "selling_price": 0.0,
    "food_cost": 0.0,
    "net_earnings": 0.0,
    "comments": "",
    "method": "",
    "ingredients": [],
  };

  //int currentStep = 0;

  int _currentStep = 0;
  final PageController _pageController = PageController();

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> saveRecipe() async {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      final url = Uri.parse('$baseUrl/api/recipes/add_recipe');
      try {
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            "Content-Type": "application/json"
          },
          body: jsonEncode(recipeData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe saved successfully!')),
          );
          Navigator.pop(context); // Navigate back after saving
        } else {
          throw Exception('Failed to save recipe');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  List<Widget> steps() {
    return [
      RecipeStep1(recipeData: recipeData),
      RecipeStep2(recipeData: recipeData),
      RecipeStep3(recipeData: recipeData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    //   return Scaffold(
    //     appBar: AppBar(title: const Text('Create Recipe')),
    //     body: Column(
    //       children: [
    //         Expanded(child: steps()[currentStep]),
    //         Padding(
    //           padding: const EdgeInsets.all(16.0),
    //           child: ElevatedButton(
    //             onPressed: saveRecipe,
    //             child: Text(currentStep < 2 ? 'Next' : 'Save'),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Recipe',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color.fromRGBO(10, 15, 13, 1)),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 15),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          StepIndicator(currentStep: _currentStep),
          Expanded(child: steps()[_currentStep]),
          Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveRecipe,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(0, 128, 128, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_currentStep < 2 ? 'Next' : 'Save',
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
