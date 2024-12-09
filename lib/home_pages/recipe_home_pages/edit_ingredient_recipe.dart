// //working code with navigating through edit tabs
// import 'package:flutter/material.dart';
// import 'package:flutter_app_login/baseUrl.dart';
// import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_ingredient_detail_screen.dart';
// import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_method.dart';
// import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_recipe_details.dart';
// import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_tabs.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class EditIngredientDetails extends StatefulWidget {
//   final String recipeId;
//   const EditIngredientDetails({super.key, required this.recipeId});

//   @override
//   _EditIngredientDetailsState createState() => _EditIngredientDetailsState();
// }

// class _EditIngredientDetailsState extends State<EditIngredientDetails> {
//   final FlutterSecureStorage _storage = FlutterSecureStorage();
//   Future<Map<String, dynamic>?>? recipeData;
//   String? _jwtToken; // Initialize as nullable.
//   String? selectedUnit; // Variable to hold selected unit
//   final List<String> massUnits = ['kg', 'g', 'lbs', 'oz'];

//   final List<Map<String, dynamic>> ingredient = [
//     {
//       'ingredient name': 'Honey',
//       'quantity': '50 gm',
//       'expanded': false,
//       'wastage': '',
//       'cost': '1.08',
//       'unit': null,
//     },
//     {
//       'ingredient name': 'Lemon(Juice)',
//       'quantity': '75 gm',
//       'expanded': false,
//       'wastage': '',
//       'cost': '',
//       'unit': null,
//     },
//     {
//       'ingredient name': 'Dijon mustard',
//       'quantity': '100 gm',
//       'expanded': false,
//       'wastage': '',
//       'cost': '',
//       'unit': null,
//     },
//   ];

//   void _addIngredient() {
//     setState(() {
//       ingredient.add({
//         'ingredient name': 'New Ingredient',
//         'quantity': '',
//         'expanded': true,
//         'wastage': '',
//         'cost': '',
//         'unit': null,
//       });
//     });
//   }

//   void _removeIngredient(int index) {
//     setState(() {
//       ingredient.removeAt(index);
//     });
//   }

//   Future<void> _loadTokenAndFetchDetails() async {
//     try {
//       // Retrieve JWT token from secure storage
//       final token = await _storage.read(key: 'jwt_token');
//       if (token == null) {
//         throw Exception("JWT token not found. Please log in again.");
//       }
//       setState(() {
//         _jwtToken = token;
//         recipeData = fetchRecipeDetails(); // Fetch details once token is set.
//       });
//     } catch (e) {
//       print("Error loading token or fetching recipe details: $e");
//     }
//   }

//   Future<Map<String, dynamic>> fetchRecipeDetails() async {
//     if (_jwtToken == null) {
//       throw Exception('JWT token is null');
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
//         headers: {
//           'Authorization': 'Bearer $_jwtToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception('Failed to load recipe data');
//       }
//     } catch (e) {
//       throw Exception('Error fetching recipe data: $e');
//     }
//   }

//   Widget _buildTextField(
//     String label,
//     String hint, {
//     bool isNumber = false,
//     int maxLines = 1,
//     int index = -1, // New parameter to track index
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           RichText(
//             text: TextSpan(
//               text: label.replaceAll('*', ''),
//               style: const TextStyle(
//                 color: Colors.black,
//                 fontSize: 16.0,
//               ),
//               children: [
//                 if (label.contains('*'))
//                   const TextSpan(
//                     text: ' *',
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 16.0,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8.0),
//           TextFormField(
//             initialValue: index >= 0 ? ingredient[index]['quantity'] : '',
//             decoration: InputDecoration(
//               hintText: hint,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//             maxLines: maxLines,
//             validator: (value) {
//               if (label.contains('*') &&
//                   (value == null || value.trim().isEmpty)) {
//                 return 'Enter the ${label.replaceAll('*', '').trim()}';
//               }
//               return null;
//             },
//             onChanged: (value) {
//               if (index >= 0) {
//                 setState(() {
//                   if (label == 'Quantity Required') {
//                     ingredient[index]['quantity'] = value;
//                   } else if (label == 'Wastage') {
//                     ingredient[index]['wastage'] = value;
//                   } else if (label == 'Cost') {
//                     ingredient[index]['cost'] = value;
//                   }
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Add Ingredient',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: _addIngredient,
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: ingredient.length,
//               itemBuilder: (context, index) {
//                 return Card(
//                   color: const Color.fromRGBO(253, 253, 253, 1),
//                   margin: const EdgeInsets.only(bottom: 16),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Ingredient Name',
//                           style: TextStyle(fontSize: 16.0),
//                         ),
//                         const SizedBox(height: 4.0),
//                         GestureDetector(
//                           onTap: () {
//                             // Navigate to the ingredient detail screen with tabs
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => IngredientDetailScreen(
//                                   ingredientData: ingredient[index],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Text(
//                             ingredient[index]['ingredient name'] ??
//                                 'New Ingredient',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.teal,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         Text('Qty Purchased',
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             )),
//                         const SizedBox(height: 8),
//                         const SizedBox(height: 8.0),
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: 120.0,
//                               child: TextFormField(
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   hintText: '1',
//                                   hintStyle:
//                                       const TextStyle(color: Colors.grey),
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10)),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             SizedBox(
//                               width: 160.0,
//                               child: DropdownButtonFormField<String>(
//                                 value: selectedUnit,
//                                 hint: const Text(
//                                   'gm',
//                                   style: TextStyle(color: Colors.grey),
//                                 ),
//                                 items: massUnits.map((String unit) {
//                                   return DropdownMenuItem<String>(
//                                     value: unit,
//                                     child: Text(unit),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     selectedUnit = newValue;
//                                   });
//                                 },
//                                 decoration: InputDecoration(
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10)),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         _buildTextField(
//                           'Wastage',
//                           'Enter wastage',
//                           index: index,
//                         ),
//                         buildDisabledTextField('Cost', 'N/A'),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'Delete ingredient',
//                           style:
//                               TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_method.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_recipe_details.dart';
import 'package:flutter_app_login/home_pages/recipe_home_pages/edit_tabs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditIngredientDetails extends StatefulWidget {
  final String recipeId;
  const EditIngredientDetails({Key? key, required this.recipeId})
      : super(key: key);

  @override
  _EditIngredientDetailsState createState() => _EditIngredientDetailsState();
}

class _EditIngredientDetailsState extends State<EditIngredientDetails> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  Future<Map<String, dynamic>?>? recipeData;
  List<Map<String, dynamic>> ingredients = [];
  String? selectedUnit;
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
        recipeData = fetchRecipeDetails();
      });
    } catch (e) {
      print("Error loading token or fetching recipe details: $e");
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    if (_jwtToken == null) throw Exception('JWT token is null');
    try {
      final response = await http.get(
        Uri.parse('https://your-backend-url/api/recipes/${widget.recipeId}'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ingredients = List<Map<String, dynamic>>.from(data['ingredients']);
        });
        return data;
      } else {
        throw Exception('Failed to load recipe data');
      }
    } catch (e) {
      throw Exception('Error fetching recipe data: $e');
    }
  }

  void _toggleExpand(int index) {
    setState(() {
      ingredients[index]['expanded'] =
          !(ingredients[index]['expanded'] ?? false);
    });
  }

  Widget _buildTextField(String label, String hint,
      {bool isNumber = false, int index = -1, String? field}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16.0)),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: index >= 0 ? ingredients[index][field] ?? '' : '',
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            onChanged: (value) {
              if (index >= 0 && field != null) {
                setState(() {
                  ingredients[index][field] = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Ingredients'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: recipeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(
                      ingredient['ingredient_name'] ?? 'Ingredient',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Quantity: ${ingredient['quantity']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              'Quantity',
                              'Enter quantity',
                              isNumber: true,
                              index: index,
                              field: 'quantity',
                            ),
                            DropdownButtonFormField<String>(
                              value: selectedUnit,
                              hint: const Text('Select unit'),
                              items: massUnits.map((String unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  ingredients[index]['unit'] = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            buildDisabledTextField(
                              'Cost',
                              'Enter cost',
                              // isNumber: true,
                              // index: index,
                              // field: 'cost',
                            ),
                            ElevatedButton.icon(
                              onPressed: () => setState(() {
                                ingredients.removeAt(index);
                              }),
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete Ingredient'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

Widget buildDisabledTextField(String label, String hint) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            disabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey[300]!, width: 1), // Grey border
              borderRadius: BorderRadius.circular(10),
            ),

            fillColor: Colors.grey[200], // Grey background color
            filled: true, // To make the fill color visible
          ),
          enabled: false,
        ),
      ],
    ),
  );
}

// Main widget for EditRecipe with Tabs
class EditIngredientsTab extends StatelessWidget {
  final String recipeId;

  const EditIngredientsTab({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return RecipeTabs(
      initialIndex: 0, // Start with the 'Details' tab
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
