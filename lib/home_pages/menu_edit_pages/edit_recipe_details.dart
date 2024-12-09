import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'details_recipe_tab_widget.dart';
import 'edit_menu_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditRecipeDetails extends StatelessWidget {
  final String menuId;
  const EditRecipeDetails({super.key, required this.menuId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close,
              size: 20, color: Color.fromRGBO(101, 104, 103, 1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.2,
            // decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: DetailsRecipeTabWidget(
        detailsContent: EditMenuDetailContent(
            menuId: menuId), //  Show EditMenuDetail in Details tab
        recipeContent: EditRecipeDetailsContent(menuId: menuId),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Handle update action
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Color.fromRGBO(0, 128, 128, 1),
          ),
          child: Text(
            'Update',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class EditRecipeDetailsContent extends StatefulWidget {
  final String menuId;
  const EditRecipeDetailsContent({super.key, required this.menuId});

  @override
  _EditRecipeDetailsContentState createState() =>
      _EditRecipeDetailsContentState();
}

class _EditRecipeDetailsContentState extends State<EditRecipeDetailsContent> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  String? selectedUnit;
  final List<String> massUnits = ['kg', 'g', 'lbs', 'oz'];
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, TextEditingController>> recipeControllers = [];

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
  }

  // @override
  // void dispose() {
  //   for (var controllerMap in recipeControllers) {
  //     for (var controller in controllerMap.values) {
  //       controller.dispose();
  //     }
  //   }
  //   super.dispose();
  // }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });

      await fetchMenuDetails();
    } catch (e) {
      print("Error loading token or fetching menu details: $e");
    }
  }

  Future<void> fetchMenuDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/menu/${widget.menuId}'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipes = List<Map<String, dynamic>>.from(data['recipes'] ?? []);
          recipeControllers = recipes.map((recipe) {
            return {
              'name': TextEditingController(text: recipe['name']),
              'measurement':
                  TextEditingController(text: recipe['measurement'].toString()),
              'cost': TextEditingController(text: recipe['cost']),
              'food_cost': TextEditingController(text: recipe['food_cost']),
              'net_earnings':
                  TextEditingController(text: recipe['net_earnings']),
            };
          }).toList();
        });
      } else {
        print(
            'Failed to load menu details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu details: $e');
    }
  }

  Future<void> _updateMenuDetails() async {
    if (_jwtToken == null) return;

    final updatedRecipes = recipes.asMap().entries.map((entry) {
      final index = entry.key;
      final recipe = entry.value;

      return {
        'name': recipeControllers[index]['name']!.text,
        'measurement': recipeControllers[index]['measurement']!.text,
        'cost': recipeControllers[index]['cost']!.text,
        'food_cost': recipeControllers[index]['food_cost']!.text,
        'net_earnings': recipeControllers[index]['net_earnings']!.text,
      };
    }).toList();

    final updatedMenuData = {
      'recipes': updatedRecipes,
      // Add other menu fields here if needed.
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/menu/${widget.menuId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedMenuData),
      );

      if (response.statusCode == 200) {
        print('Menu details updated successfully!');
      } else {
        print(
            'Failed to update menu details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating menu details: $e');
    }
  }

  void _addRecipe() {
    setState(() {
      recipes.add({
        'name': '',
        'quantity': '',
        'unit': '',
        'cost': '',
        'foodCost': '',
        'netEarnings': ''
      });
    });
  }

  void _removeRecipe(int index) {
    setState(() {
      recipes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Recipe',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: Color.fromRGBO(10, 15, 13, 1)),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 20,
                  color: Color.fromRGBO(101, 104, 103, 1),
                ),
                onPressed: _addRecipe,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return Card(
                color: const Color.fromRGBO(253, 253, 253, 1),
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Adjust radius for roundness
                  side: BorderSide(
                      color: const Color.fromRGBO(231, 231, 231, 1),
                      width: 1), // Border color and width
                ),
                //margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            recipes[index]['name'] ?? 'New Recipe',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                height: 1.5),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.expand_more,
                              size: 18,
                              color: Color.fromRGBO(101, 104, 103, 1),
                            ),
                            onPressed: () {
                              setState(() {
                                recipes[index]['expanded'] =
                                    !(recipes[index]['expanded'] ?? false);
                              });
                            },
                          ),
                        ],
                      ),
                      if (recipes[index]['expanded'] ?? false)
                        Column(
                          children: [
                            _buildQuantityAndUnitFields(index),
                            const SizedBox(height: 10),
                            _buildDisabledTextField('Cost', '\$15.00'),
                            const SizedBox(height: 10),
                            _buildDisabledTextField('Selling Price', '25%'),
                            const SizedBox(height: 15),
                            _buildDisabledTextField('Food Cost', '20%'),
                            const SizedBox(height: 15),
                            _buildDisabledTextField('Net Earnings', '\$5.00'),
                          ],
                        ),
                      TextButton(
                        onPressed: () => _removeRecipe(index),
                        child: const Text(
                          'Delete Recipe',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(244, 67, 54, 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityAndUnitFields(int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qty Purchased',
            style: TextStyle(
              color: Color.fromRGBO(150, 152, 151, 1),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 120, // Adjust width for alignment
                height: 40,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '20',
                    hintStyle: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(10, 15, 13, 1)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 190, // Adjust width for alignment
                height: 40,
                child: DropdownButtonFormField<String>(
                  value: selectedUnit,
                  hint: const Text(
                    'Serving',
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(10, 15, 13, 1)),
                  ),
                  items: massUnits.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUnit = newValue;
                    });
                  },
                  validator: (value) {
                    if (selectedUnit == null) {
                      return 'Unit is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color.fromRGBO(150, 152, 151, 1),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 329, // Same width for alignment
            height: 40, // Same height for alignment
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(10, 15, 13, 1)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      const BorderSide(width: 1.0, style: BorderStyle.solid),
                ),
                fillColor: const Color.fromRGBO(
                    231, 231, 231, 1), // Grey background color
                filled: true, // To make the fill color visible
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}










// /**Delete recipe endpoint:  DELETE   /api/menu/<int:menu_id>/<int:menu_recipe_id> */

// import 'package:flutter/material.dart';
// import 'package:flutter_app_login/baseUrl.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'details_recipe_tab_widget.dart';
// import 'edit_menu_detail.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class EditRecipeDetails extends StatelessWidget {
//   final String menuId;

//   const EditRecipeDetails({super.key, required this.menuId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.close,
//               size: 20, color: Color.fromRGBO(101, 104, 103, 1)),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           'Edit',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             height: 1.2,
//             // decorationStyle: TextDecorationStyle.solid,
//             decorationThickness: 1.5,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: DetailsRecipeTabWidget(
//         detailsContent: EditMenuDetailContent(menuId: menuId),
//         //EditMenuDetailContent(), //  Show EditMenuDetail in Details tab
//         recipeContent: EditRecipeDetailsContent(menuId: menuId),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           onPressed: () {
//             // Handle update action
//             final contentState = context
//                 .findAncestorStateOfType<_EditRecipeDetailsContentState>();
//             contentState?._updateMenuDetails();
//             // _updateMenuDetails();
//           },
//           child: Text(
//             'Update',
//             style: TextStyle(fontSize: 18, color: Colors.white),
//           ),
//           style: ElevatedButton.styleFrom(
//             minimumSize: Size(double.infinity, 50),
//             backgroundColor: Colors.teal,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class EditRecipeDetailsContent extends StatefulWidget {
//   final String menuId;

//   const EditRecipeDetailsContent({super.key, required this.menuId});

//   @override
//   _EditRecipeDetailsContentState createState() =>
//       _EditRecipeDetailsContentState();
// }

// class _EditRecipeDetailsContentState extends State<EditRecipeDetailsContent> {
//   final FlutterSecureStorage _storage = FlutterSecureStorage();
//   String? _jwtToken;
//   String? selectedUnit;
//   final List<String> massUnits = [
//     'gm',
//     'kg',
//     'oz',
//     'lbs',
//     'tonne',
//     'ml',
//     'cl',
//     'dl',
//     'L',
//     'Pint',
//     'Quart',
//     'fl oz',
//     'gallon',
//     'Each',
//     'Serving',
//     'Box',
//     'bag',
//     'Can',
//     'Carton',
//     'Jar',
//     'Punnet',
//     'Container',
//     'Packet',
//     'Roll',
//     'Bunch',
//     'Bottle',
//     'Tin',
//     'tub',
//     'Piece',
//     'Block',
//     'Portion',
//     'Dozen',
//     'Bucket',
//     'Slice',
//     'Pinch',
//     'Tray',
//     'Teaspoon',
//     'Tablespoon',
//     'Cup'
//   ];
//   List<Map<String, dynamic>> recipes = [];
//   List<Map<String, TextEditingController>> recipeControllers = [];

//   //List<TextEditingController> recipeControllers = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadTokenAndFetchDetails();
//   }

//   @override
//   void dispose() {
//     for (var controllerMap in recipeControllers) {
//       for (var controller in controllerMap.values) {
//         controller.dispose();
//       }
//     }
//     super.dispose();
//   }

//   Future<void> _loadTokenAndFetchDetails() async {
//     try {
//       final token = await _storage.read(key: 'jwt_token');
//       if (token == null) {
//         throw Exception("JWT token not found. Please log in again.");
//       }
//       setState(() {
//         _jwtToken = token;
//       });

//       await fetchMenuDetails();
//     } catch (e) {
//       print("Error loading token or fetching menu details: $e");
//     }
//   }

//   Future<void> fetchMenuDetails() async {
//     if (_jwtToken == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/menu/${widget.menuId}'),
//         headers: {'Authorization': 'Bearer $_jwtToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           recipes = List<Map<String, dynamic>>.from(data['recipes'] ?? []);
//           recipeControllers = recipes.map((recipe) {
//             return {
//               'name': TextEditingController(text: recipe['name']),
//               'measurement':
//                   TextEditingController(text: recipe['measurement'].toString()),
//               'cost': TextEditingController(text: recipe['cost']),
//               'food_cost': TextEditingController(text: recipe['food_cost']),
//               'net_earnings':
//                   TextEditingController(text: recipe['net_earnings']),
//             };
//           }).toList();
//         });
//       } else {
//         print(
//             'Failed to load menu details. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching menu details: $e');
//     }
//   }

//   Future<void> _updateMenuDetails() async {
//     if (_jwtToken == null) return;

//     final updatedRecipes = recipes.asMap().entries.map((entry) {
//       final index = entry.key;
//       final recipe = entry.value;

//       return {
//         'name': recipeControllers[index]['name']!.text,
//         'measurement': recipeControllers[index]['measurement']!.text,
//         'cost': recipeControllers[index]['cost']!.text,
//         'food_cost': recipeControllers[index]['food_cost']!.text,
//         'net_earnings': recipeControllers[index]['net_earnings']!.text,
//       };
//     }).toList();

//     final updatedMenuData = {
//       'recipes': updatedRecipes,
//       // Add other menu fields here if needed.
//     };

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/menu/${widget.menuId}'),
//         headers: {
//           'Authorization': 'Bearer $_jwtToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(updatedMenuData),
//       );

//       if (response.statusCode == 200) {
//         print('Menu details updated successfully!');
//       } else {
//         print(
//             'Failed to update menu details. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error updating menu details: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Add Recipe',
//                 style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                     height: 1.5,
//                     color: Color.fromRGBO(10, 15, 13, 1)),
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.add,
//                   size: 20,
//                   color: Color.fromRGBO(101, 104, 103, 1),
//                 ),
//                 onPressed: _addRecipe,
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             itemCount: recipes.length,
//             itemBuilder: (context, index) {
//               return Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     children: [
//                       // _buildQuantityAndUnitFields(index),
//                       // const SizedBox(height: 10),
//                       // _buildDisabledTextField(
//                       //     'Cost', recipeControllers[index]['cost']! as String),
//                       // const SizedBox(height: 10),
//                       // _buildDisabledTextField('Selling Price',
//                       //     recipeControllers[index]['selling_price']! as String),
//                       // const SizedBox(height: 15),
//                       // _buildDisabledTextField('Food Cost',
//                       //     recipeControllers[index]['food_ost']! as String),
//                       // const SizedBox(height: 15),
//                       // _buildDisabledTextField('Net Earnings',
//                       //     recipeControllers[index]['net_earnings']! as String),
//                       _buildEditableTextField(
//                           'Recipe Name', recipeControllers[index]['name']!),
//                       _buildEditableTextField(
//                           'serving_ize', recipeControllers[index]['quantity']!),
//                       _buildEditableTextField(
//                           'Cost', recipeControllers[index]['cost']!),
//                       _buildEditableTextField(
//                           'Food Cost', recipeControllers[index]['food_ost']!),
//                       _buildEditableTextField('Net Earnings',
//                           recipeControllers[index]['net_earnings']!),
//                       TextButton(
//                         onPressed: () => _removeRecipe(index),
//                         child: Text('Delete Recipe'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         // Padding(
//         //   padding: const EdgeInsets.all(16.0),
//         //   child: ElevatedButton(
//         //     onPressed: _updateMenuDetails,
//         //     child: Text('Update'),
//         //   ),
//         // ),
//       ],
//     );
//   }

//   Widget _buildEditableTextField(
//       String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   void _addRecipe() {
//     setState(() {
//       recipes.add({
//         'recipe_name': '',
//         'serving_size': '',
//         'cost': '',
//         'food_cost': '',
//         'net_earning': '',
//       });
//       recipeControllers.add({
//         'name': TextEditingController(),
//         'quantity': TextEditingController(),
//         'cost': TextEditingController(),
//         'foodCost': TextEditingController(),
//         'netEarnings': TextEditingController(),
//       });
//     });
//   }

//   void _removeRecipe(int index) {
//     setState(() {
//       recipes.removeAt(index);
//       recipeControllers.removeAt(index);
//     });
//   }

//   Widget _buildQuantityAndUnitFields(int index) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Qty Purchased',
//             style: TextStyle(
//               color: Color.fromRGBO(150, 152, 151, 1),
//               fontSize: 13,
//               height: 1.5,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               SizedBox(
//                 width: 120, // Adjust width for alignment
//                 height: 40,
//                 child: TextFormField(
//                   // initialValue: recipeControllers[index]['quantity'],
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: '20',
//                     hintStyle: const TextStyle(
//                         fontSize: 13,
//                         height: 1.5,
//                         fontWeight: FontWeight.w300,
//                         color: Color.fromRGBO(10, 15, 13, 1)),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 4.0, horizontal: 8.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               SizedBox(
//                 width: 190, // Adjust width for alignment
//                 height: 40,
//                 child: DropdownButtonFormField<String>(
//                   value: selectedUnit,
//                   hint: const Text(
//                     'Serving',
//                     style: TextStyle(
//                         fontSize: 13,
//                         height: 1.5,
//                         fontWeight: FontWeight.w300,
//                         color: Color.fromRGBO(10, 15, 13, 1)),
//                   ),
//                   items: massUnits.map((String unit) {
//                     return DropdownMenuItem<String>(
//                       value: unit,
//                       child: Text(unit),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedUnit = newValue;
//                     });
//                   },
//                   validator: (value) {
//                     if (selectedUnit == null) {
//                       return 'Unit is required';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 4.0, horizontal: 8.0),
//                   ),
//                   dropdownColor: Color.fromRGBO(253, 253, 253, 1),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDisabledTextField(String label, String hint) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color.fromRGBO(150, 152, 151, 1),
//               fontSize: 13,
//               height: 1.5,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             width: 329, // Same width for alignment
//             height: 40, // Same height for alignment
//             child: TextFormField(
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle: const TextStyle(
//                     fontSize: 13,
//                     height: 1.5,
//                     fontWeight: FontWeight.w300,
//                     color: Color.fromRGBO(10, 15, 13, 1)),
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                   borderSide:
//                       const BorderSide(width: 1.0, style: BorderStyle.solid),
//                 ),
//                 fillColor: const Color.fromRGBO(
//                     231, 231, 231, 1), // Grey background color
//                 filled: true, // To make the fill color visible
//               ),
//               enabled: false,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }