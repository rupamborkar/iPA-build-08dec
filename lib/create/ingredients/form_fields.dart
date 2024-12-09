import 'package:flutter/material.dart';

Widget buildTextField(String label, String hint,
    //TextEditingController controller,
    {int maxLines = 1,
    //Function(String)? onChanged,
    required void Function(dynamic value) onSaved,
    required Null Function(dynamic value) onChanged}) {
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
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40,
          child: TextFormField(
            //controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
            onSaved: onSaved,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

Widget buildDisabledTextField(String label,
//String hint,
    {required Null Function(dynamic value) onSaved}) {
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
          width: 353, // Fixed width of 353px
          height: 40,
          child: TextFormField(
            decoration: InputDecoration(
              //hintText: hint,
              //  hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
            //onChanged: value,
          ),
        ),
      ],
    ),
  );
}

Widget buildDropdownField(
  String label,
  List<String> items,
  //TextEditingController controller,
  {
  required Function(String?) onSaved,
  Function(String?)? onChanged,
  // required void Function(String?) onChanged,
  // required void Function(String?) onSaved,
}) {
  return Column(
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
      SizedBox(
        width: 353, // Fixed width of 353px
        height: 40,

        child: DropdownButtonFormField<String>(
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: SizedBox(
                width: 150, // Set the width of the dropdown item
                height: 40,
                child: Text(item),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          onSaved: onSaved,
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          dropdownColor: Color.fromRGBO(253, 253, 253, 1),
        ),
      ),
    ],
  );
}
