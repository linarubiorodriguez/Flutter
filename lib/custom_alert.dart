import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomAlert {
  static void showSuccess(BuildContext context, String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.green);
  }

  static void showError(BuildContext context, String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
  }
}
