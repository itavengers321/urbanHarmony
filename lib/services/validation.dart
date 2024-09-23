import 'package:flutter/material.dart';

String? validateEmail(String? value) {
  Pattern pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  RegExp regExp = RegExp(pattern.toString());

  if (!regExp.hasMatch(value.toString())) {
    return "Enter valid email";
  } else {
    return null;
  }
}

String? validateText(String? value, FocusNode focusNode) {
  if (value.toString().isEmpty) {
    focusNode.requestFocus();
    return "Enter Text";
  }
  if (value.toString().length < 3) {
    focusNode.requestFocus();
    return "Minimum 3 char. required";
  }

  focusNode.unfocus();
  return null;
}

String? validateName(String? value, FocusNode focusNode) {
  if (value == null && value.toString().isEmpty) {
    focusNode.requestFocus();
    return "Value is required";
  }
  if (value.toString().length < 3) {
    focusNode.requestFocus();
    return "Value must be greater than 3 chars";
  }
  Pattern pattern = r'^[a-zA-Z ]*$';
  RegExp regExp = RegExp(pattern.toString());

  if (!regExp.hasMatch(value.toString())) {
    focusNode.requestFocus();
    return "Name should contain only char or one space";
  }
  focusNode.unfocus();
  return null;
}



String? validateMobile(String? value, FocusNode focusNode) {
  if (value == null && value.toString().isEmpty) {
    focusNode.requestFocus();
    return "Value is required";
  }
  if (value.toString().length < 11) {
    focusNode.requestFocus();
    return "Value must be greater than 11 chars";
  }
  Pattern pattern = r'^03\d{9}$';
  RegExp regExp = RegExp(pattern.toString());

  if (!regExp.hasMatch(value.toString())) {
    focusNode.requestFocus();
    return "Name should of pattern 03XXXXXXXXX";
  }
  focusNode.unfocus();
  return null;
}


String? validatePass(String? value) {
  Pattern pattern = r'^\d{8}$';
  RegExp regExp = RegExp(pattern.toString());

  if (!regExp.hasMatch(value.toString())) {
    return "only 8 chars. digit XXXXXXXX required";
  } else {
    return null;
  }
}
