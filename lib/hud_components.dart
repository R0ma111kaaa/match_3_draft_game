// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:platformer/main.dart';
import 'package:platformer/my_game.dart';
import 'package:platformer/my_world.dart';

abstract class SimpleButton extends PositionComponent with TapCallbacks {
  SimpleButton(this._iconPath, {super.position})
    : super(size: Vector2.all(Constants.worldButtonsSize));

  final Paint _borderPaint =
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x66ffffff);

  final String _iconPath;
  late Image _iconImage;
  bool _isImageLoaded = false;

  void action();

  @override
  Future<void> onLoad() async {
    _iconImage = await Flame.images.load(_iconPath);
    _isImageLoaded = true;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      _borderPaint,
    );

    if (_isImageLoaded) {
      final src = Rect.fromLTWH(
        0,
        0,
        _iconImage.width.toDouble(),
        _iconImage.height.toDouble(),
      );
      final dst = Rect.fromLTWH(3, 3, size.x - 5, size.y - 5);
      canvas.drawImageRect(_iconImage, src, dst, Paint());
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _borderPaint.color = const Color(0xffffffff);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _borderPaint.color = const Color(0x66ffffff);
    action();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _borderPaint.color = const Color(0x66ffffff);
  }
}

class BackButton extends SimpleButton with HasGameRef<MyGame> {
  BackButton(super._iconPath, {super.position});

  @override
  void action() => gameRef.router.pop();
}

class RestartButton extends SimpleButton with HasGameRef<MyGame> {
  late MyWorld world;
  RestartButton(super._iconPath, {super.position, required this.world});

  @override
  void action() {
    world.resetLevel();
  }
}

class Background extends Component {
  Background(this.size);
  final Vector2 size;
  late final Sprite _sprite;

  @override
  Future<void> onLoad() async {
    priority = -10;
    _sprite = await Sprite.load(MySprites.background);
    add(SpriteComponent(sprite: _sprite, size: size, position: Vector2.zero()));
  }
}

class ScoreComponent extends TextComponent with HasGameRef<MyGame> {}
