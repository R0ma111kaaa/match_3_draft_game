// ignore_for_file: avoid_print

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:platformer/my_game.dart';
import 'package:platformer/my_world.dart';

class MyColors {
  static Color red = Colors.red;
  static Color yellow = Colors.yellow;
  static Color green = Colors.green;
  static Color pink = Colors.pink;
  static Color purple = Colors.purple;

  static final List<Color> colorList = [red, yellow, green, pink, purple];
  static final lenght = colorList.length;
}

class MySprites {
  static String box = "box.png";
  static String burger = "burger.png";
  static String coldFace = "cold_face.png";
  static String duckMrBim = "duck_mr_bim.png";
  static String gift = "gift.png";
  static String grandpa = "grandpa.png";
  static String skeleton = "skeleton.png";

  static final List<String> sprites = [
    box,
    burger,
    coldFace,
    duckMrBim,
    gift,
    skeleton,
  ];
  static final lenght = sprites.length;
}

class Constants {
  static int rowCount = 5;
  static int columnCount = 5;
  static int spaceBetweenTiles = 10;
  static double fieldPadding = 10;
  static double switchDuration = 0.4;
  static double resizeDuration = 0.4;

  static double acceleration = 1;
  static double droppingTilesStartSpeed = -25;
  static int droppingTilesPriority = 10;
  static int droppingTilesXRange = 1000;
  static double droppingAnimationTime = 2;
  static double slideAnimationTime = 1;
}

void main() {
  final myGame = MyGame(MyWorld());
  runApp(GameWidget(game: myGame));
}
