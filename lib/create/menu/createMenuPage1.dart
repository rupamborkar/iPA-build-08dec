import 'package:flutter/material.dart';
import 'package:flutter_app_login/create/menu/createMenuPage2.dart';

class CreateMenuPage1 extends StatefulWidget {
  final String token;
  const CreateMenuPage1({super.key, required this.token});

  @override
  _CreateMenuPage1State createState() => _CreateMenuPage1State();
}

class _CreateMenuPage1State extends State<CreateMenuPage1> {
  final TextEditingController menuNameController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController numberOfPeopleController =
      TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  DateTime? selectedDate;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic> menuData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Menu',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 18,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildStepProgressIndicator(0),
            const SizedBox(height: 15),
            const Text(
              'Basic Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextFields(
                        'Menu Name *',
                        menuNameController,
                        'Enter name of the recipe',
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          setState(() {});
                        },
                        child: AbsorbPointer(
                          child: _buildTextFields(
                            'Menu Date',
                            TextEditingController(
                                text: selectedDate != null
                                    ? selectedDate!
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0]
                                    : 'Select date'),
                            'Select date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextFields(
                          'Origin', originController, 'Enter the origin'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRowTextFields(
                              'Selling Price',
                              sellingPriceController,
                              'e.g. 12.00',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildRowTextFields(
                              'Number of People',
                              numberOfPeopleController,
                              'Enter number',
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildRowDisabledTextField('Menu Cost', 'N/A'),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildRowDisabledTextField(
                              'Food Cost',
                              'N/A',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDisabledTextField('Net Earnings', 'N/A'),
                      const SizedBox(height: 12),
                      _buildTextFields(
                        'Comments',
                        commentsController,
                        'Enter any additional notes',
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 353,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final menuData = {
                      "name": menuNameController.text,
                      "date":
                          selectedDate?.toLocal().toString().split(' ')[0] ??
                              '',
                      "origin": originController.text,
                      "selling_price": sellingPriceController.text,
                      "no_of_people": numberOfPeopleController.text,
                      "comments": commentsController.text,
                    };

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateMenuPage2(
                            menuData: menuData, token: widget.token),
                      ),
                    );
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
                  'Next',
                  style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color.fromRGBO(253, 253, 253, 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStepProgressIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildCircle(0, currentStep),
        buildLine(),
        buildCircle(1, currentStep),
      ],
    );
  }

  Widget buildCircle(int step, int currentStep) {
    bool isCompleted = currentStep >= step;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isCompleted ? const Color.fromRGBO(0, 128, 128, 1) : Colors.white,
        border: Border.all(
            color: isCompleted
                ? const Color.fromRGBO(0, 128, 128, 1)
                : Colors.grey,
            width: 2),
      ),
    );
  }

  Widget buildLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: const Color.fromRGBO(0, 128, 128, 1),
      ),
    );
  }

  Widget _buildTextFields(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                  color: Color.fromRGBO(10, 15, 13, 1)),
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
            width: 353,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(10, 15, 13, 1)),
                //const TextStyle(color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 1.0,
                      color: Colors.grey[300]!,
                      //color: Color.fromRGBO(231, 231, 231, 1)
                    )),
              ),
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
              validator: (value) {
                if (label.contains('*') &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Enter the ${label.replaceAll('*', '').trim()}';
                }
                return null;
              },
            ),
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
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Color.fromRGBO(150, 152, 151, 1),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 5.0), // Space between the label and text field
          SizedBox(
            width: 353,
            height: 40,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(10, 15, 13, 1)),
                //const TextStyle(color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromRGBO(240, 237, 237, 1),
                      width: 1), // Grey border
                  borderRadius: BorderRadius.circular(10),
                ),
                //),
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

  Widget _buildRowTextFields(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                  color: Color.fromRGBO(10, 15, 13, 1)),
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
            width: 165,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(10, 15, 13, 1)),
                //const TextStyle(color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 1.0,
                      color: Colors.grey[300]!,
                      //color: Color.fromRGBO(231, 231, 231, 1)
                    )),
              ),
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
              validator: (value) {
                if (label.contains('*') &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Enter the ${label.replaceAll('*', '').trim()}';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDisabledTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Color.fromRGBO(150, 152, 151, 1),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 5.0), // Space between the label and text field
          SizedBox(
            width: 165,
            height: 40,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(10, 15, 13, 1)),
                //const TextStyle(color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromRGBO(240, 237, 237, 1),
                      width: 1), // Grey border
                  borderRadius: BorderRadius.circular(10),
                ),
                //),
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
