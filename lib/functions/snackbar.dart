// 🐦 Flutter imports:
import 'package:flutter/material.dart';

/// 👁️ Show SnackBar with [text]
void showSnackBar(
    BuildContext context, String text, GlobalKey<ScaffoldMessengerState> key) {
  key.currentState!.showSnackBar(SnackBar(content: Text(text)));
}
