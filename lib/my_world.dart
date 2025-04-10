// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flame/components.dart';
import 'package:platformer/constants.dart';
import 'package:platformer/grid_component.dart';
import 'package:platformer/main.dart';

class MyWorld extends World with HasGameRef<MyGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    double tileSize =
        (min(gameRef.size.x, gameRef.size.y) -
            Constants.fieldPadding * 2 -
            (Constants.columnCount - 1) * Constants.spaceBetweenTiles) /
        Constants.columnCount;
    double fieldSize =
        tileSize * Constants.columnCount +
        (Constants.columnCount - 1) * Constants.fieldPadding;
    add(
      GridComponent(
          columnCount: Constants.columnCount,
          rowCount: Constants.rowCount,
          tileSize: tileSize,
        )
        ..position = Vector2(
          Constants.fieldPadding,
          (gameRef.size.y - fieldSize) / 2,
        ),
    );
  }
}
