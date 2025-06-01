import 'package:flutter/material.dart';

class SharedLayout {
  static EdgeInsets getScreenPadding(BuildContext context) {
    return MediaQuery.of(context).size.width > 600
        ? const EdgeInsets.symmetric(horizontal: 150) // Web padding
        : EdgeInsets.zero; // Mobile padding
  }
}