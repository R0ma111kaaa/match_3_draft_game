// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:platformer/constants.dart';
import 'package:platformer/main.dart';

class TileComponent extends RectangleComponent
    with TapCallbacks, HasGameRef<MyGame> {
  int row;
  int column;
  double tileSize;
  Random random;
  bool isTapped = false;

  TileComponent({
    required this.row,
    required this.column,
    required this.tileSize,
    required this.random,
  });

  Vector2 getPosition() => position;

  @override
  void onLoad() {
    anchor = Anchor.center;
    size = Vector2.all(tileSize);
    position = Vector2(
      column * (tileSize + Constants.spaceBetweenTiles) + tileSize / 2,
      row * (tileSize + Constants.spaceBetweenTiles) + tileSize / 2,
    );
    paint =
        Paint()..color = MyColors.colorList[random.nextInt(MyColors.lenght)];
  }

  @override
  void onTapDown(TapDownEvent event) {
    var pair = gameRef.pair;
    if (!isTapped) {
      if (pair.isNotEmpty) {
        int verticalDistance = (pair[0][0] - row).abs();
        int horisontalDistance = (pair[0][1] - column).abs();
        if (!(horisontalDistance == 0 && verticalDistance == 1 ||
                verticalDistance == 0 && horisontalDistance == 1) ||
            pair[0] == [row, column]) {
          gameRef.resetPair();
          return;
        }
      }
      isTapped = true;
      add(
        SizeEffect.to(
          Vector2.all(tileSize * 0.9),
          EffectController(
            duration:
                gameRef.pair.isNotEmpty
                    ? Constants.resizeDuration / 2
                    : Constants.resizeDuration,
            onMax: () => isTapped = false,
          ),
        ),
      );
      gameRef.addTileToPair(row, column);
    }
  }
}
