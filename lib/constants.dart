// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class MyColors {
  static Color red = Colors.red;
  static Color yellow = Colors.yellow;
  static Color green = Colors.green;
  static Color brown = Colors.brown;
  static Color purple = Colors.purple;

  static final List<Color> colorList = [red, yellow, green, brown, purple];
  static final lenght = colorList.length;
}

class Constants {
  static int rowCount = 6;
  static int columnCount = 6;
  static int spaceBetweenTiles = 10;
  static double fieldPadding = 10;
  static double switchDuration = 0.4;
  static double resizeDuration = 0.4;
}
