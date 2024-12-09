import 'package:flutter/material.dart';
import 'recipe_ingredient_form.dart';

class RecipeStep2 extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const RecipeStep2({super.key, required this.recipeData});

  @override
  _RecipeStep2State createState() => _RecipeStep2State();
}

class _RecipeStep2State extends State<RecipeStep2> {
  List<Map<String, dynamic>> ingredients = []; // Stores actual ingredient data
  List<int> ingredientForms = [0]; // Tracks form instances
  int formCounter = 1;

  @override
  void initState() {
    super.initState();
    widget.recipeData['ingredients'] ??= [];
  }

  void _addIngredientForm() {
    setState(() {
      ingredientForms.add(formCounter++);
      ingredients.add({}); // Add placeholder data for the new ingredient
    });
  }

  void _removeIngredientForm(int index) {
    setState(() {
      ingredientForms.removeAt(index);
      if (index < ingredients.length) {
        ingredients.removeAt(index); // Remove corresponding ingredient data
      }
    });
  }

  void _saveIngredient(int index, Map<String, dynamic> data) {
    setState(() {
      if (index < ingredients.length) {
        ingredients[index] = data; // Update the specific ingredient data
      } else {
        ingredients.add(data);
      }
      widget.recipeData['ingredients'] = ingredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Add Ingredients',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addIngredientForm,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (ingredientForms.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: const Center(
                    child: Text(
                      'Tap the add icon to enter an ingredient.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ingredientForms.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RecipeIngredientForm(
                              onSave: (data) => _saveIngredient(index, data as Map<String, dynamic>),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _removeIngredientForm(index),
                                child: const Text(
                                  'Delete Ingredient',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
