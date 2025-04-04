// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:platformer/main.dart';
import 'package:platformer/my_game.dart';

class TileComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<MyGame> {
  int row;
  int column;
  double tileSize;
  Random random;
  bool isTapped = false;
  late String spriteName;

  double asseleration = 0;
  double speed = 0;
  late double targetYPosition = gameRef.size.y;

  TileComponent({
    required this.row,
    required this.column,
    required this.tileSize,
    required this.random,
    required super.position,
  });

  Vector2? getPosition() => position;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    size = Vector2.all(tileSize);
    changeSprite();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += Vector2(0, speed);
    speed += asseleration;
    if (position.y > targetYPosition && speed != 0) {
      asseleration = 0;
      speed = 0;
      position = Vector2(position.x, targetYPosition);
    }
  }

  @override
  void onRemove() {
    speed = 0;
    asseleration = 0;
  }

  void changeSprite() async {
    spriteName = MySprites.sprites[random.nextInt(MySprites.lenght)];
    sprite = await Sprite.load(spriteName);
  }

  void dropFromTheGrid() {
    priority = Constants.droppingTilesPriority;
    int xOffcet =
        -(Constants.droppingTilesXRange / 2).toInt() +
        random.nextInt(Constants.droppingTilesXRange);
    addAll([
      MoveByEffect(
        Vector2(xOffcet.toDouble(), 0),
        EffectController(duration: 2),
        onComplete: () => removeFromParent(),
      ),
      SizeEffect.by(
        Vector2.all(random.nextDouble() * size.x * 2),
        EffectController(duration: Constants.droppingAnimationTime),
      ),
    ]);
    speed = Constants.droppingAnimationTime;
    asseleration = Constants.acceleration;
    this.targetYPosition = gameRef.size.y * 2;
  }

  @override
  void onTapDown(TapDownEvent event) {
    var pair = gameRef.pair;
    if (!isTapped && gameRef.tapIsAvailible) {
      if (pair.isNotEmpty) {
        dynamic firstElement = pair[0];
        int verticalDistance = (firstElement[0] - row).abs();
        int horisontalDistance = (firstElement[1] - column).abs();
        if (!(horisontalDistance == 0 && verticalDistance == 1 ||
                verticalDistance == 0 && horisontalDistance == 1) ||
            listEquals(firstElement, [row, column])) {
          gameRef.resetPair();
          if (listEquals(firstElement, [row, column])) {
            return;
          }
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
