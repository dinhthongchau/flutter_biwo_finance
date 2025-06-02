import 'package:flutter/material.dart';

class SharedLayout {
  static EdgeInsets getScreenPadding(BuildContext context) {
    return MediaQuery.of(context).size.width > 900
        ? const EdgeInsets.symmetric(horizontal: 160) // Web padding
        : MediaQuery.of(context).size.width > 600
        ? const EdgeInsets.symmetric(horizontal: 150) // Tablet padding
        : EdgeInsets.zero; // Mobile padding// Mobile padding
  }
}