import 'package:flutter/material.dart';

class ColorUtils {
  static Color randomColor() {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    colors.shuffle();
    return colors.first;
  }
}
