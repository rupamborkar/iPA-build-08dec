//working when click on ingredient like honey
import 'package:flutter/material.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/ingredients_edit_ingredient.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/ingredients_edit_measurements.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/ingredients_edit_wastage.dart';

class IngredientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ingredientData;

  const IngredientDetailScreen({super.key, required this.ingredientData});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          //automaticallyImplyLeading: false, // This removes the back arrow
          //title: Text('Edit', ingredientData['ingredient name']),
          // title: Text('Edit ${ingredientData['ingredient name']}'),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color.fromRGBO(0, 128, 128, 1),
            unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
            indicatorColor: Color.fromRGBO(0, 128, 128, 1),
            labelStyle: TextStyle(
              fontSize: 14, //fontWeight: FontWeight.bold
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Measurements'),
              Tab(text: 'Wastage'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            IngredientEditDetails(), //it will open  ingredient detail form
            IngredientsEditMeasurements(), // it will open measurment form
            IngredientsEditWastage(), // it will open wastage form
          ],
        ),
      ),
    );
  }
}
