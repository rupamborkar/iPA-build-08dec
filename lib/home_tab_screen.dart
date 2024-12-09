import 'package:flutter/material.dart';
import 'package:flutter_app_login/home_pages/ingredient_edit_pages/home_ingredient.dart';
import 'package:flutter_app_login/home_pages/menu_edit_pages/home_menu.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/home_recipe.dart';

//import 'package:flutter_app_login/recipe_home_pages/home_recipe.dart';

class HomeTabScreen extends StatelessWidget {
  final String token; // Token passed from HomeScreen

  const HomeTabScreen({super.key, required this.token}); // Constructor

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hide the back button
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Home',
                style: TextStyle(
                  fontSize: 20,
                  height: 24,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(10, 15, 13, 1),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Color.fromRGBO(101, 104, 103, 1),
                ),
                onPressed: () {
                  // You can implement your action here (e.g., navigate to a notifications screen)
                  print("Notifications clicked");
                },
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: Color.fromRGBO(0, 128, 128, 1),
            unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
            indicatorColor: Color.fromRGBO(0, 128, 128, 1),
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: 'Ingredients'),
              Tab(text: 'Recipes'),
              Tab(text: 'Menus'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Ingredients tab
            HomePage(
              jwtToken: token, // Pass the token for the Ingredients page
            ),

            RecipeHomePage(
              jwtToken: token,
            ),
            // Menus tab
            HomeMenuPage(
              jwtToken: token,
            ),
            //const Center(child: Text('Menus Tab')),

            // Recipes tab
            //const Center(child: Text('Recipes Tab')),
          ],
        ),
      ),
    );
  }
}
