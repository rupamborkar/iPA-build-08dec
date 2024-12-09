import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StocktakeTabsWidget extends StatefulWidget {
  final bool isEditing;
  final Function onSave;
  final String stocktakeId;
  final int ingredientId;

  const StocktakeTabsWidget(
      {Key? key,
      required this.isEditing,
      required this.onSave,
      required this.stocktakeId,
      required this.ingredientId})
      : super(key: key);

  @override
  State<StocktakeTabsWidget> createState() => _StocktakeTabsWidgetState();
}

class _StocktakeTabsWidgetState extends State<StocktakeTabsWidget> {
  String? selectedUnit;
  final List<String> massUnits = ['kg', 'g', 'lbs', 'oz'];

  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage
  Map<String, dynamic>? stocktakeData;
  String? _jwtToken;

  // Controllers for the text fields
  TextEditingController stocktakeNameController = TextEditingController();
  TextEditingController originController = TextEditingController();
  TextEditingController totalItemsController = TextEditingController();
  TextEditingController totalValueController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  List<Map<String, dynamic>> ingredients = [];

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
      });

      await fetchStocktakeDetails();
      await fetchIngredientsDetails();
    } catch (e) {
      print("Error loading token or fetching stocktake details: $e");
    }
  }

  Future<void> fetchStocktakeDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stocktake/${widget.stocktakeId}/full'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stocktakeData = data;
          stocktakeNameController.text = data['name'];
          originController.text = data['origin'];
          totalItemsController.text = data['total_items'].toString();
          totalValueController.text = data['total_value'].toString();
          commentsController.text = data['comments'];

          //  ingredients = List<Map<String, dynamic>>.from(data['ingredients']);
        });
      } else {
        print(
            'Failed to load stocktake data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stocktake data: $e');
    }
  }

  Future<void> fetchIngredientsDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/stocktake/${widget.stocktakeId}/stocktake_ingredients'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          ingredients = json.decode(response.body);
        });
      } else {
        print(
            'Failed to load stocktake data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stocktake data: $e');
    }
  }

  Future<void> deleteStocktakeIngredient(
      int stocktakeId, int ingredientId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/stocktake/$stocktakeId/stocktake_ingredients/$ingredientId'),
        headers: {
          'Authorization': 'Bearer $_jwtToken', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stocktake deleted successfully')),
        );
        Navigator.of(context).pop(); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete sstocktaker.')),
        );
      }
    } catch (e) {
      print('Error deleting stocktake: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the stocktake.')),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this stocktake?'),
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
                deleteStocktakeIngredient(
                    widget.stocktakeId as int,
                    widget
                        .ingredientId); // Call deleteStocktakeIngredient with the supplier ID
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

  Future<void> updateStocktake() async {
    if (_jwtToken == null) return;

    final updatedData = {
      "stocktake_name": stocktakeNameController.text,
      "origin": originController.text,
      // "total_items": int.parse(totalItemsController.text),
      // "total_value": double.parse(totalValueController.text),
      "comments": commentsController.text,
      // "ingredients": ingredients.map((ingredient) {
      //   return {
      //     "ingredient_name": ingredient['ingredient_name'],
      //     "quantity_purchased": ingredient['quantity_purchased'],
      //     "wastage_type": ingredient['wastage_type'],
      //     "wastage_percent": ingredient['wastage_percent'],
      //     "cost": ingredient['cost'],
      //   };
      // }).toList(),
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/stocktake/${widget.stocktakeId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Stocktake updated successfully');
        widget.onSave();
      } else {
        print(
            'Failed to update stocktake. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating stocktake: $e');
    }
  }

  Future<void> updateStocktakeIngredients() async {
    if (_jwtToken == null) return;

    final updatedData = {
      "ingredients": ingredients.map((ingredient) {
        return {
          "ingredient_name": ingredient['ingredient_name'],
          "quantity_purchased": ingredient['quantity_purchased'],
          "wastage_type": ingredient['wastage_type'],
          "wastage_percent": ingredient['wastage_percent'],
          "cost": ingredient['cost'],
        };
      }).toList(),
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/stocktake/${widget.stocktakeId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Stocktake updated successfully');
        widget.onSave();
      } else {
        print(
            'Failed to update stocktake. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating stocktake: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Color.fromRGBO(0, 128, 128, 1),
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: 'Details'),
            Tab(text: 'Ingredients'),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDetailsTab(),
            _buildIngredientsTab(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: updateStocktake,
            child: Text(
              widget.isEditing ? 'Update' : 'Save',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(0, 128, 128, 1),
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildTextFieldWithLabel('Stocktake Name', stocktakeNameController,
              stocktakeData?['name']),
          _buildTextFieldWithLabel(
              'Origin', originController, stocktakeData?['origin']),
          _buildDisabledTextField('Total Items', totalItemsController.text,
              stocktakeData?['total_items']),
          _buildDisabledTextField('Total Value', totalValueController.text,
              stocktakeData?['total_values']),
          _buildTextFieldWithLabel(
              'Comments', commentsController, stocktakeData?['comments']),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel(
      String label, TextEditingController controller, initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color.fromRGBO(150, 152, 151, 1),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: 353,
            height: 40,
            child: TextFormField(
              //initialValue: initialValue,
              controller: controller,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledTextField(String label, String hint, initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: Color.fromRGBO(150, 152, 151, 1),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          SizedBox(
            width: 353, // Fixed width of 353px
            height: 40,
            child: TextFormField(
              initialValue: initialValue,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(10, 15, 13, 1)),
                //const TextStyle(color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(231, 231, 231, 1)!,
                      width: 1), // Grey border
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor:
                    Color.fromRGBO(231, 231, 231, 1), // Grey background color
                filled: true, // To make the fill color visible
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add ingredient',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: Color.fromRGBO(10, 15, 13, 1)),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Color.fromRGBO(101, 104, 103, 1),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ...ingredients.map<Widget>((ingredient) {
          //...ingredients.map((ingredient) {
          return Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            child: Column(
              children: [
                ExpansionTile(
                  title: Text(
                    ingredient['ingredient_name'] ?? 'Unknown Ingredient',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  children: [
                    _buildQuantityAndUnitFields(),
                    _buildTextFieldWithLabel(
                        'Wastage Type',
                        TextEditingController(text: ingredient['wastage_type']),
                        ingredient['wastage_type']),
                    _buildTextFieldWithLabel(
                        'Wastage Percent',
                        TextEditingController(
                            text: ingredient['wastage_percent'].toString()),
                        ingredient['wastage_percent']),
                    _buildDisabledTextField(
                        'Cost',
                        TextEditingController(
                            text: ingredient['cost'].toString()) as String,
                        ingredient['cost']),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // delete logic here
                      confirmDelete();
                    },
                    child: const Text(
                      'Delete Ingredient',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuantityAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity Required',
          style: TextStyle(
            color: Color.fromRGBO(150, 152, 151, 1),
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0), // Space between label and fields
        Row(
          children: [
            SizedBox(
              width: 120.0, // Adjust the width as needed
              height: 40,
              child: TextFormField(
                // controller:  TextEditingController(text: ingredient['quantity_']),
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
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 8.0),
                ),
              ),
            ),
            const SizedBox(width: 10), // Space between text field and dropdown
            SizedBox(
              width:
                  210.0, // Adjust the width as needed to match the text field
              height: 40,
              child: DropdownButtonFormField<String>(
                value: selectedUnit,
                hint: const Text(
                  'kg',
                  style: TextStyle(color: Colors.grey),
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 8.0),
                ),
                dropdownColor: Color.fromRGBO(253, 253, 253, 1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
