import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:flutter_app_login/home_pages/supplier/supplier_edit_screen.dart';
import 'package:flutter_app_login/home_pages/supplier/supplier_ingredient_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupplierDetail extends StatefulWidget {
  final String supplierId;
  final Function(int) onTabChanged;

  const SupplierDetail(
      {required this.onTabChanged, super.key, required this.supplierId});

  @override
  _SupplierDetailState createState() => _SupplierDetailState();
}

class _SupplierDetailState extends State<SupplierDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage
  Map<String, dynamic>? supplierData;
  String? _jwtToken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      widget.onTabChanged(_tabController.index);
    });
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

      await fetchSupplierDetails();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchSupplierDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/supplier/${widget.supplierId}/full'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          supplierData = json.decode(response.body);
        });
      } else {
        print(
            'Failed to load supplier data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/supplier/$supplierId'),
        headers: {
          'Authorization': 'Bearer $_jwtToken', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier deleted successfully')),
        );
        Navigator.of(context).pop(true); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete supplier.')),
        );
      }
    } catch (e) {
      print('Error deleting supplier: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the supplier.')),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this supplier?'),
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
                deleteSupplier(widget
                    .supplierId); // Call deleteSupplier with the supplier ID
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context); // Action to go back
          },
        ),
        title: Text(
          supplierData?['name'] ?? ' ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              if (_tabController.index == 0) {
                // Navigate to edit details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SupplierEditScreen(supplierId: widget.supplierId)),
                );
              } else if (_tabController.index == 1) {
                // Navigate to edit ingredients page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SupplierEditScreen(supplierId: widget.supplierId)),
                  //SupplierEditIngredientScreen(
                  //  supplierId: widget.supplierId)),
                );
              }
            },
          )
        ],
        bottom: TabBar(
          labelColor: const Color.fromRGBO(0, 128, 128, 1),
          unselectedLabelColor: const Color.fromRGBO(16, 18, 17, 1),
          indicatorColor: const Color.fromRGBO(0, 128, 128, 1),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Ingredients'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          SupplierIngredientScreen(supplierId: widget.supplierId),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    if (supplierData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.white,
            elevation: 0,
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
                  _buildDetailRow(
                      'Supplier Name', supplierData?['name'] ?? 'N/A'),
                  _buildDetailRow(
                      'Location', supplierData?['location'] ?? 'N/A'),
                  _buildDetailRow('Phone', supplierData?['phone'] ?? 'N/A'),
                  _buildDetailRow('Email', supplierData?['email'] ?? 'N/A'),
                  _buildDetailRow(
                      'Last Update', supplierData?['last_update'] ?? 'N/A'),
                  _buildDetailRow(
                      'Comments', supplierData?['comments'] ?? 'N/A'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                confirmDelete(); // Show the delete confirmation dialog
              },
              child: const Text(
                'Delete Supplier',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value
      //String title, String value, Color titleColor, Color valueColor
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120, // Fixed width for the title to align all items
            child: Text(
              '$title:',
              // style: TextStyle(
              //   fontWeight: FontWeight.bold,
              //   color: Colors.grey,
              // ),
              style: const TextStyle(
                color: Color.fromRGBO(150, 152, 151, 1),
                fontSize: 13, //fontWeight: FontWeight.bold
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              //style: TextStyle(color: valueColor)
              style: const TextStyle(
                color: Color.fromRGBO(10, 15, 13, 1),
                fontSize: 13, //fontWeight: FontWeight.bold
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
