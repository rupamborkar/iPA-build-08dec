import 'package:flutter/material.dart';
import 'package:flutter_app_login/create/ingredients/form_fields.dart';

class IngredientFormStep3 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> data;

  IngredientFormStep3({
    required this.formKey,
    required this.data,
    super.key,
  });

  @override
  State<IngredientFormStep3> createState() => _IngredientFormStep3State();
}

class _IngredientFormStep3State extends State<IngredientFormStep3> {
  bool _showWastageForm = false;
  final TextEditingController _wastagePercentageController =
      TextEditingController();

  @override
  void dispose() {
    _wastagePercentageController.dispose();
    super.dispose();
  }

  void calculateWastagePercentage() {
    // Parse the values
    int wastage =
        int.tryParse(widget.data['wastage_quantity']?.toString() ?? '0') ?? 0;
    int totalQuantity =
        int.tryParse(widget.data['quantity']?.toString() ?? '1') ?? 1;

    if (totalQuantity > 0) {
      double wastagePercentage = (wastage / totalQuantity) * 100;

      setState(() {
        widget.data['wastage_percentage'] = wastagePercentage;
        _wastagePercentageController.text =
            wastagePercentage.toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Wastage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _showWastageForm = true;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_showWastageForm)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: const Center(
                child: Text(
                  'Tap the add icon to enter wastage details.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (_showWastageForm) _buildWastageForm(),
        ],
      ),
    );
  }

  Widget _buildWastageForm() {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDisabledQuantTextField(
              'Quantity Purchased',
              onSaved: (value) {
                widget.data['quantity'] = value;
              },
            ),
            const SizedBox(height: 16),
            buildTextField(
              'Wastage Type',
              'e.g. Peel',
              onSaved: (value) {
                widget.data['wastage_type'] = value;
              },
              onChanged: (value) {
                widget.data['wastage_type'] = value;
              },
            ),
            const SizedBox(height: 16),
            buildTextField(
              'Wastage Quantity',
              'Enter wastage quantity',
              onSaved: (value) {
                int wastageValue = int.tryParse(value ?? '0') ?? 0;
                int quantityPurchased =
                    int.tryParse(widget.data['quantity']?.toString() ?? '0') ??
                        0;

                if (wastageValue > quantityPurchased) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Wastage cannot be more than Quantity Purchased ($quantityPurchased)."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  throw Exception("Invalid wastage quantity.");
                }
                widget.data['wastage_quantity'] = wastageValue;
                calculateWastagePercentage();
              },
              onChanged: (value) {
                int wastageValue = int.tryParse(value) ?? 0;
                int quantityPurchased =
                    int.tryParse(widget.data['quantity']?.toString() ?? '0') ??
                        0;

                if (wastageValue > quantityPurchased) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Wastage cannot be more than Quantity Purchased ($quantityPurchased)."),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  setState(() {
                    widget.data['wastage_quantity'] = wastageValue;
                  });
                  calculateWastagePercentage();
                }
              },
            ),
            const SizedBox(height: 16),
            buildDisabledWPTextField(
              'Wastage %',
              controller: _wastagePercentageController,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget buildDisabledQuantTextField(String label,
      {required Null Function(dynamic value) onSaved}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5.0),
        TextFormField(
          initialValue: widget.data['quantity']?.toString() ?? '0',
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            fillColor: Colors.grey[200],
            filled: true,
          ),
          enabled: false,
        ),
      ],
    );
  }

  Widget buildDisabledWPTextField(String label,
      {required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5.0),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            fillColor: Colors.grey[200],
            filled: true,
          ),
          enabled: false,
        ),
      ],
    );
  }
}
