import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_login/baseUrl.dart';
import 'package:http/http.dart' as http;

class CreateSupplierPage extends StatelessWidget {
  final String token;
  const CreateSupplierPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController commentsController = TextEditingController();

    Future<void> saveSupplier() async {
      // final String apiUrl =
      //     '$baseUrl/api/supplier/'; // Replace with your Flask backend URL

      final Map<String, dynamic> supplierData = {
        "name": nameController.text.trim(),
        "location": locationController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "comments": commentsController.text.trim(),
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/supplier/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          // headers: {'Content-Type': 'application/json'},
          body: jsonEncode(supplierData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Successfully saved
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Supplier saved successfully!')),
          );
          Navigator.pop(context, true); // Close the form
        } else {
          // Error response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save supplier. Try again.')),
          );
        }
      } catch (e) {
        // Exception occurred
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Center(
          child: Text(
            'Create Supplier',
            style: TextStyle(
              color: Color.fromRGBO(10, 15, 13, 8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close,
                color: Color.fromRGBO(101, 103, 104, 1)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      'Basic Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(10, 15, 13, 1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: nameController,
                      label: 'Supplier Name *',
                      hintText: 'Enter the name of the supplier',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: locationController,
                      label: 'Location',
                      hintText: 'Enter location',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      hintText: 'Enter email id',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone',
                      hintText: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: commentsController,
                      label: 'Comments',
                      hintText: 'Add comments',
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          saveSupplier();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(0, 128, 128, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(253, 253, 253, 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: const TextStyle(
                color: Color.fromRGBO(150, 152, 151, 1),
                fontSize: 13,
                height: 1.5,
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
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                  color: Color.fromRGBO(150, 152, 151, 1)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Color.fromRGBO(231, 231, 231, 1)),
              ),
            ),
            keyboardType: keyboardType ?? TextInputType.text,
            maxLines: maxLines,
            validator: (value) {
              if (label.contains('*') &&
                  (value == null || value.trim().isEmpty)) {
                return '${label.replaceAll('*', '').trim()} is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
