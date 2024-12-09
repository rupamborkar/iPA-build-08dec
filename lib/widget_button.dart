import 'package:flutter/material.dart';

Widget customButton(
    {required int currentStep,
    required VoidCallback nextStep,
    required VoidCallback saveForm}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: currentStep < 2 ? nextStep : saveForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(0, 128, 128, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        currentStep < 2 ? 'Next' : 'Save',
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),
  );
}
