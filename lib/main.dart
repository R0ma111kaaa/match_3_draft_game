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
  static Color white = Colors.white;
  static Color backgroundColor = Colors.blue;

  static final List<Color> colorList = [red, yellow, green, pink, purple];
  static final lenght = colorList.length;
}

class MySprites {
  static String casino = "casino.png";
  static String burger = "burger.png";
  static String duckMrBim = "duck_mr_bim.png";
  static String gift = "gift.png";
  static String skeleton = "skeleton.png";

  static String background = "background.jpg";

  static final List<String> sprites = [
    casino,
    burger,
    duckMrBim,
    gift,
    skeleton,
  ];
  static final lenght = sprites.length;
}

class ButtonSprites {
  static String back = "back.png";
  static String reload = "reload.png";
}

class Constants {
  static int rowCount = 6;
  static int columnCount = 6;
  static int spaceBetweenTiles = 0;
  static double fieldPadding = 10;
  static double switchDuration = 0.4;
  static double resizeDuration = 0.4;

  static double acceleration = 1;
  static double droppingTilesStartSpeed = -20;
  static int droppingTilesPriority = 10;
  static int droppingTilesXRange = 1000;
  static double droppingAnimationTime = 2;
  static double slideAnimationTime = 0.5;

  static double menuFallingSpritesSpeed = 2;
  static double menuFallingSpritesSize = 60;

  static double worldButtonsPaddinY = 50;
  static double worldButtonsPaddinX = 30;
  static double worldButtonsSize = 40;
}

void main() {
  final myGame = MyGame();
  runApp(GameWidget(game: myGame));
}
