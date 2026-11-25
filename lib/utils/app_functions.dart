import 'package:flutter/material.dart';

class AppFunctions {

  /// Closes the soft keyboard if open
  static void closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }


}
