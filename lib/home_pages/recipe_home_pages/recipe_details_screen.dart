import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_method.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_recipe_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeDetail extends StatefulWidget {
  // final String recipeId;
  final String recipeId;
  final String name;

  const RecipeDetail({super.key, required this.name, required this.recipeId});

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<Map<String, dynamic>?>? recipeData;
  String? _jwtToken; // Initialize as nullable.

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
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recipe data');
      }
    } catch (e) {
      throw Exception('Error fetching recipe data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: FutureBuilder<Map<String, dynamic>?>(
        future: recipeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Scaffold(
              body: Center(child: Text('No data available.')),
            );
          } else {
            final data = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 15,
                    color: Color.fromRGBO(101, 104, 103, 1),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text(data['name'] ?? 'Recipe'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      final currentTabIndex =
                          DefaultTabController.of(context)!.index;
                      if (currentTabIndex == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditDetailsTab(
                              recipeId: widget.recipeId,
                            ),
                          ),
                        );
                      } else if (currentTabIndex == 1) {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => EditIngredientsTab(
                        //       ingredients: data['ingredients'],
                        //     ),
                        //   ),
                        // );
                      } else if (currentTabIndex == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMethodTab(
                              recipeId: widget.recipeId,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
                bottom: const TabBar(
                  labelColor: Color.fromRGBO(0, 128, 128, 1),
                  unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
                  indicatorColor: Color.fromRGBO(0, 128, 128, 1),
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: 'Details'),
                    Tab(text: 'Ingredients'),
                    Tab(text: 'Method'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  DetailsTab(
                    data: data,
                    jwtToken: _jwtToken ?? '',
                  ),
                  IngredientsTab(
                    recipeId: widget.recipeId,
                    jwtToken: _jwtToken!,
                  ),
                  MethodTab(data: data),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class DetailsTab extends StatefulWidget {
  final Map<String, dynamic> data;
  final String jwtToken;

  const DetailsTab({super.key, required this.data, required this.jwtToken});

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  late BuildContext scaffoldContext;

  Future<void> deleteIngredient(String recipeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/recipes/$recipeId'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(content: Text('Recipe deleted successfully')),
        );
        Navigator.of(scaffoldContext)
            .pop(true); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(content: Text('Failed to delete recipe.')),
        );
      }
    } catch (e) {
      print('Error deleting recipe: $e');
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the recipe.')),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: scaffoldContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this recipe?'),
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
                deleteIngredient(widget.data['id']);
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

  @override
  // Widget build(BuildContext context) {
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext newContext) {
        // Save the context tied to the active Scaffold
        scaffoldContext = newContext;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: const Color.fromRGBO(253, 253, 253, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                      color: const Color.fromRGBO(231, 231, 231, 1), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow('Recipe Name:', widget.data['name'] ?? 'N/A'),
                      _buildRow('Category:', widget.data['category'] ?? 'N/A'),
                      _buildRow('Origin:', widget.data['origin'] ?? 'N/A'),
                      _buildRow('Tags:', widget.data['tags'] ?? 'N/A'),
                      //_buildRow('Tags:', data['tags']?.join(', ') ?? 'N/A'),
                      _buildRow('Cost:', '\$${widget.data['cost'] ?? 0.0}'),
                      _buildRow('Tax:', '${widget.data['tax'] ?? 0}%'),
                      _buildRow('Selling Price:',
                          '\$${widget.data['sellingPrice'] ?? 0.0}'),
                      _buildRow(
                          'Food Cost:', '${widget.data['foodCost'] ?? 0}%'),
                      _buildRow('Net Earning:',
                          '\$${widget.data['netEarning'] ?? 0.0}'),
                      _buildRow(
                          'Serving size:', widget.data['servingSize'] ?? 'N/A'),
                      _buildRow('Comments:',
                          widget.data['comments'] ?? 'No Comments'),
                      _buildRow(
                          'Last Update:', widget.data['lastUpdate'] ?? 'N/A'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    confirmDelete();
                    // Add delete functionality if needed.
                  },
                  child: const Text(
                    'Delete recipe',
                    style: TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(150, 152, 151, 1),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Color.fromRGBO(10, 15, 13, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IngredientsTab extends StatefulWidget {
  final String recipeId; // Updated to pass recipeId dynamically
  final String jwtToken;

  const IngredientsTab(
      {super.key, required this.recipeId, required this.jwtToken});

  @override
  _IngredientsTabState createState() => _IngredientsTabState();
}

class _IngredientsTabState extends State<IngredientsTab> {
  List<Map<String, dynamic>> ingredients = [];
  double scaleFactor = 1.0;
  String selectedScale = '1x scale';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  Future<void> _fetchIngredients() async {
    //const String baseUrl = "http://your-api-url.com"; // Replace with your actual base URL
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {
          'Authorization':
              'Bearer ${widget.jwtToken}', // Replace with your actual token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          ingredients = List<Map<String, dynamic>>.from(
            responseData['ingredients'].map((ingredient) => {
                  'name': ingredient['ingredient_name'],
                  'quantity': double.parse(ingredient['quantity']),
                }),
          );
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load ingredients. Status code: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching ingredients: $error');
    }
  }

  void _applyScale(String scale) {
    setState(() {
      switch (scale) {
        case '0.5x scale':
          scaleFactor = 0.5;
          break;
        case '1x scale':
          scaleFactor = 1.0;
          break;
        case '2x scale':
          scaleFactor = 2.0;
          break;
        default:
          scaleFactor = 1.0;
      }
    });
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Scale Quantities',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(10, 15, 13, 1),
                      ),
                    ),
                    DropdownButton<String>(
                      value: selectedScale,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _applyScale(newValue);
                          setState(() {
                            selectedScale = newValue;
                          });
                        }
                      },
                      items: <String>['0.5x scale', '1x scale', '2x scale']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: ingredients.map((ingredient) {
                    return Card(
                      color: const Color.fromRGBO(253, 253, 253, 1),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                            color: Color.fromRGBO(231, 231, 231, 1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRow('Ingredient Name:', ingredient['name']),
                            _buildRow(
                              'Quantity:',
                              '${(ingredient['quantity'] * scaleFactor).toStringAsFixed(1)} units',
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
  }
}

class MethodTab extends StatelessWidget {
  final Map<String, dynamic> data;

  MethodTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to prepare',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(10, 15, 13, 1),
            ),
          ),
          const SizedBox(height: 12, width: 101),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child:
                // Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                // children: preparationSteps.map((step) {
                Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(data['method'],
                        style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            // }
            // ),
            //),
          )
        ],
      ),
    );
  }
}

Widget _buildRow(String label, String value, {TextStyle? labelStyle}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(150, 152, 151, 1),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: labelStyle ??
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    ),
  );
}
