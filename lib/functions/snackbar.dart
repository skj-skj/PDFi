// 🐦 Flutter imports:
import 'package:flutter/material.dart';

/// 👁️ Show SnackBar with [text]
void showSnackBar(
    BuildContext context, String text) {
  // key.currentState!.showSnackBar(SnackBar(content: Text(text)));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
