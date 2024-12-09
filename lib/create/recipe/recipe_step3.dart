import 'package:flutter/material.dart';

class RecipeStep3 extends StatelessWidget {
  final Map<String, dynamic> recipeData;

  const RecipeStep3({super.key, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to Prepare',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          buildTextField(
            '',
            'Enter the method or preparation',
            maxLines: 8,
            onChanged: (value) => recipeData['method'] = value,
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, String hint,
      {int maxLines = 1, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
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
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: maxLines,
            validator: (value) {
              if (label.contains('*') &&
                  (value == null || value.trim().isEmpty)) {
                return '${label.replaceAll('*', '').trim()} is required';
              }
              return null;
            },
            onChanged: onChanged,
          ),
        ],
      ),
    );
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
          SizedBox(
            width: 353,
            height: 100,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey[300]!, width: 1), // Grey border
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Colors.grey[200], // Grey background color
                filled: true, // To make the fill color visible
              ),
              // TextFormField(
              //   decoration: InputDecoration(
              //     hintText: hint,
              //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //   ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}
