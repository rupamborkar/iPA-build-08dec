import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientForms extends StatefulWidget {
  final bool showIngredientForm;
  final VoidCallback toggleIngredientForm;

  final Function(Map<String, dynamic>) onAddIngredient;

  const IngredientForms(
      {super.key,
      required this.showIngredientForm,
      required this.toggleIngredientForm,
      required this.onAddIngredient});

  @override
  State<IngredientForms> createState() => _IngredientFormsState();
}

class _IngredientFormsState extends State<IngredientForms> {
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

  List<Map<String, dynamic>> ingredientList = [];
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  final TextEditingController ingredientNameController =
      TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController quantityUnitController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  String? _selectedIngredientId;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
  }

  void addIngredeintCard() {
    setState(() {
      ingredientList
          .add({'name': null, 'quantity': null, 'quantity_unit': null});
    });
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });

      await fetchIngredientList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchIngredientList() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients/ingredients_list'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        log('check_Data $fetchedData');
        setState(() {
          ingredientList = fetchedData.map((item) {
            return {
              'ingredient_id': item['ingredient_id'] ?? '',
              'name': item['name'] ?? 'Unknown', // Provide a default value
              'cost': item['ingredient_cost'] ?? 0.0,
              'quantity_unit': item['quantity_unit'] ?? '',
            };
          }).toList();
        });

        // setState(() {
        //   ingredientList = fetchedData.map((item) {
        //     return {
        //       'ingredient_id': item['ingredient_id'] ?? '',
        //       'name': item['name'] ?? 'Unknown', // Handle null names
        //       "cost": item['ingredient_cost'] ?? 0,
        //       "quantity_unit": item['quantity_unit'] ?? '',
        //     };
        //   }).toList();
        //});
      } else {
        print('Failed to fetch ingredients');
      }
    } catch (e) {
      print('Error fetching ingredients: $e');
    }
  }

  void addIngredientToList() {
    if (_selectedIngredientId == null ||
        quantityController.text.isEmpty ||
        selectedUnit == null) {
      return;
    }

    final selectedIngredient = ingredientList.firstWhere(
      (ingredient) => ingredient['ingredient_id'] == _selectedIngredientId,
    );

    final newIngredient = {
      'ingredient_id': selectedIngredient['ingredient_id'],
      'name': selectedIngredient['name'],
      'quantity': double.tryParse(quantityController.text) ?? 0,
      'quantity_unit': selectedUnit,
      'cost': selectedIngredient['cost'],
      'wastage': selectedIngredient['wastage'] ?? 0,
    };

    log('check_obj $newIngredient');

    setState(() {
      ingredientList.add(newIngredient);
    });

    //widget.onAddIngredient(newIngredient);
    widget.onAddIngredient(ingredientList as Map<String, dynamic>);
    widget.toggleIngredientForm();
  }

  Widget buildIngredientCard(int index) {
    return Card(
      color: const Color.fromRGBO(253, 253, 253, 1),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side:
            const BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDropdownField(
              'Ingredient *',
              ingredientList
                  .map((e) => e['name'] as String? ?? 'Unknown')
                  .toList(),
              onChanged: (value) {
                final selectedIngredient = ingredientList.firstWhere(
                  (ingredient) => ingredient['name'] == value,
                  orElse: () =>
                      {'ingredient_id': '', 'name': ''}, // Default if not found
                );
                setState(() {
                  _selectedIngredientId = selectedIngredient['ingredient_id'];
                });
              },
            ),
            // buildDropdownField(
            //   'Ingredient *',
            //   ingredientList.map((e) => e['name'] as String).toList(),
            //   //  ingredientList.map((e) => e['name'] ?? 'Unknown').toList(),
            //   onChanged: (value) {
            //     final selectedIngredient = ingredientList.firstWhere(
            //       (ingredient) => ingredient['name'] == value,
            //     );
            //     setState(() {
            //       _selectedIngredientId = selectedIngredient['ingredient_id'];
            //       log('check_selectedIngredientId $_selectedIngredientId');
            //     });
            //   },
            // ),
            const SizedBox(height: 16),
            _buildQuantityAndUnitFields(),
            const SizedBox(height: 16),
            _buildDisabledField("Wastage", "None"),
            const SizedBox(height: 16),
            _buildDisabledField("Cost", "N/A"),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text(
                  'Delete Recipe',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          // onTap: widget.toggleIngredientForm,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Ingredient',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                    color: Color.fromRGBO(101, 104, 103, 1),
                  ),
                  onPressed: addIngredeintCard,
                ),
              ],
            ),
          ),
        ),
        // if (widget.showIngredientForm)
        Card(
          elevation: 0,
          color: const Color.fromRGBO(255, 255, 255, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                color: const Color.fromRGBO(231, 231, 231, 1), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // for (int i = 0; i < ingredientList.length; i++)
                  //   buildIngredientCard(i),
                  for (int i = 0; i < ingredientList.length; i++)
                    //{
                    if (ingredientList[i]['name'] == null)
                      // continue; // Skip invalid entries
                      buildIngredientCard(i),
                  //}
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.0,
            color: Color.fromRGBO(150, 152, 151, 1),
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 40,
          width: 329,
          child: TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              hintText: value,
              hintStyle: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                  color: Color.fromRGBO(150, 152, 151, 1)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              fillColor: const Color.fromRGBO(231, 231, 231, 1),
              filled: true,
            ),
            style: const TextStyle(color: Colors.grey),
            enabled: false,
          ),
        )
      ],
    );
  }

  Widget _buildQuantityAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            color: Color.fromRGBO(150, 152, 151, 1),
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            SizedBox(
              height: 40,
              width: 120,
              child: TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  hintStyle: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(150, 153, 151, 1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        width: 1.0,
                        style: BorderStyle.solid,
                        color: Color.fromRGBO(231, 231, 231, 1)),
                  ),
                  //border: OutlineInputBorder(),
                  //isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 40,
              width: 190,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedUnit,
                hint: const Text('Select mass unit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    )),
                items: massUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                //onChanged: on
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        width: 1.0,
                        //style: BorderStyle.solid,
                        color: Color.fromRGBO(231, 231, 231, 1)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                onChanged: (String? value) {
                  selectedUnit = value;
                  //addIngredientToList();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDropdownField(
    String label,
    List<String> items, {
    Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 329, // Fixed width of 353px
          height: 40,

          child: DropdownButtonFormField<String>(
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            //  onSaved: onSaved,
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle:
                  const TextStyle(color: Color.fromRGBO(101, 104, 103, 1)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_app_login/baseUrl.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class IngredientForms extends StatefulWidget {
//   final Function(Map<String, dynamic>) onAddIngredient;

//   const IngredientForms({
//     Key? key,
//     required this.onAddIngredient,
//   }) : super(key: key);

//   @override
//   State<IngredientForms> createState() => _IngredientFormsState();
// }

// class _IngredientFormsState extends State<IngredientForms> {
//   final FlutterSecureStorage _storage = FlutterSecureStorage();
//   String? _jwtToken;
//   List<Map<String, dynamic>> ingredientList = [];
//   final List<IngredientForm> forms = [];
//   final TextEditingController ingredientNameController =
//       TextEditingController();
//   final TextEditingController quantityController = TextEditingController();
//   final TextEditingController quantityUnitController = TextEditingController();
//   final TextEditingController costController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadTokenAndFetchDetails();
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
//       await fetchIngredientList();
//     } catch (e) {
//       print("Error loading token or fetching ingredient details: $e");
//     }
//   }

//   Future<void> fetchIngredientList() async {
//     if (_jwtToken == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/ingredients/ingredients_list'),
//         headers: {'Authorization': 'Bearer $_jwtToken'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> fetchedData = json.decode(response.body);
//         setState(() {
//           ingredientList = fetchedData.map((item) {
//             return {
//               'ingredient_id': item['ingredient_id'],
//               'name': item['name'],
//               "cost": item['ingredient_cost'],
//               "quantity_unit": item['quantity_unit']
//             };
//           }).toList();
//         });
//       } else {
//         print('Failed to fetch ingredients');
//       }
//     } catch (e) {
//       print('Error fetching ingredients: $e');
//     }
//   }

//   void _addNewForm() {
//     setState(() {
//       forms.add(IngredientForm(
//         ingredientList: ingredientList,
//         onRemove: () {
//           setState(() {
//             forms.removeLast();
//           });
//         },
//         onSave: (ingredientData) {
//           widget.onAddIngredient(ingredientData);
//         },
//       ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: _addNewForm,
//           child: Container(
//             padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Add Ingredient',
//                     style:
//                         TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                 const Icon(Icons.add, color: Colors.grey),
//               ],
//             ),
//           ),
//         ),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: forms.length,
//           itemBuilder: (context, index) => forms[index],
//         ),
//       ],
//     );
//   }
// }

// class IngredientForm extends StatefulWidget {
//   final List<Map<String, dynamic>> ingredientList;
//   final VoidCallback onRemove;
//   final Function(Map<String, dynamic>) onSave;

//   const IngredientForm({
//     Key? key,
//     required this.ingredientList,
//     required this.onRemove,
//     required this.onSave,
//   }) : super(key: key);

//   @override
//   State<IngredientForm> createState() => _IngredientFormState();
// }

// class _IngredientFormState extends State<IngredientForm> {
//   final TextEditingController quantityController = TextEditingController();
//   String? selectedIngredientId;
//   String? selectedUnit;

//   final List<String> massUnits = [
//     'Gram(g)',
//     'Kilogram(kg)',
//     'Ounce(oz)',
//     'Pound(lbs)',
//     'Liter(L)',
//     'Each(ea)',
//     'Box(box)',
//     'Bag(bag)',
//     'Piece(piece)',
//     'Dozen(dozen)',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side:
//             const BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             DropdownButtonFormField<String>(
//               isExpanded: true,
//               hint: const Text('Select Ingredient *'),
//               value: selectedIngredientId,
//               items: widget.ingredientList.map((ingredient) {
//                 return DropdownMenuItem<String>(
//                   value: ingredient['id'].toString(),
//                   child: Text(ingredient['name']),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedIngredientId = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: TextFormField(
//                     controller: quantityController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(
//                       hintText: 'Quantity',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   flex: 3,
//                   child: DropdownButtonFormField<String>(
//                     isExpanded: true,
//                     hint: const Text('Unit'),
//                     value: selectedUnit,
//                     items: massUnits.map((unit) {
//                       return DropdownMenuItem<String>(
//                         value: unit,
//                         child: Text(unit),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedUnit = value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: widget.onRemove,
//                   child:
//                       const Text('Remove', style: TextStyle(color: Colors.red)),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (selectedIngredientId != null &&
//                         quantityController.text.isNotEmpty &&
//                         selectedUnit != null) {
//                       final ingredientData = {
//                         'id': selectedIngredientId,
//                         'quantity':
//                             double.tryParse(quantityController.text) ?? 0,
//                         'unit': selectedUnit,
//                       };
//                       widget.onSave(ingredientData);
//                     }
//                   },
//                   child: const Text('Save'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
