import 'package:flutter/material.dart';

void showSnackBar(
    BuildContext context, String text, GlobalKey<ScaffoldMessengerState> key) {
  key.currentState!.showSnackBar(SnackBar(content: Text(text)));
}
