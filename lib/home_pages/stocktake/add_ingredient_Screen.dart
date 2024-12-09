import 'package:flutter/material.dart';
import 'package:flutter_app_login/home_pages/stocktake/stocktake_tab_widget.dart';

class AddIngredientScreen extends StatelessWidget {
  final String stocktakeId;
  final int ingredientId;

  const AddIngredientScreen(
      {super.key, required this.stocktakeId, required this.ingredientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: Color.fromRGBO(101, 104, 103, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.2,
            // decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 1.5,
          ),
          //TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StocktakeTabsWidget(
        stocktakeId: stocktakeId,
        ingredientId: ingredientId,
        isEditing: true,
        onSave: () {
          // Handle the save action for adding a new ingredient
          Navigator.pop(context);
          print('Saved new ingredient');
        },
      ),
    );
  }
}
