// ignore_for_file: avoid_print

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/rendering.dart';
import 'package:platformer/my_game.dart';

class MyMenu extends Component with HasGameRef<MyGame> {
  MyMenu() {
    addAll([
      _title = TextComponent(
        text: 'Match 3',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 64,
            color: Color(0xFFC8FFF5),
            fontWeight: FontWeight.w800,
          ),
        ),
        anchor: Anchor.center,
      ),
      _startButton = PushButton(
        text: "ИГРАТЬ",
        action: () => game.router.pushNamed("world"),
        color: const Color.fromARGB(255, 32, 77, 202),
        pushColor: const Color.fromARGB(255, 72, 110, 213),
      ),
      _settingsButton = PushButton(
        text: "НАСТРОЙКИ",
        action: () => game.router.pushNamed("settings"),
        color: const Color.fromARGB(255, 32, 202, 91),
        pushColor: const Color.fromARGB(255, 62, 202, 111),
      ),
    ]);
  }

  late final TextComponent _title;
  late final PushButton _startButton;
  late final PushButton _settingsButton;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _title.position = Vector2(size.x / 2, size.y / 3);
    _startButton.position = Vector2(size.x / 2, _title.y + 80);
    _settingsButton.position = Vector2(size.x / 2, _title.y + 140);
  }
}

class PushButton extends PositionComponent with TapCallbacks {
  PushButton({
    required this.text,
    required this.action,
    required this.color,
    required this.pushColor,
    super.position,
    super.anchor = Anchor.center,
  }) : _textDrawable = TextPaint(
         style: const TextStyle(
           fontSize: 20,
           color: Color(0xFF000000),
           fontWeight: FontWeight.w800,
         ),
       ).toTextPainter(text) {
    size = Vector2(150, 40);
    _textOffset = Offset(
      (size.x - _textDrawable.width) / 2,
      (size.y - _textDrawable.height) / 2,
    );
    _rrect = RRect.fromLTRBR(0, 0, size.x, size.y, Radius.circular(size.y / 2));
    _bgPaint = Paint()..color = color;
  }

  final String text;
  final void Function() action;
  final TextPainter _textDrawable;
  late final Offset _textOffset;
  late final RRect _rrect;
  late final Paint _bgPaint;
  late final Color color;
  late final Color pushColor;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_rrect, _bgPaint);
    _textDrawable.paint(canvas, _textOffset);
  }

  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(1.05);
    _bgPaint.color = pushColor;
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
    _bgPaint.color = color;
    action();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _bgPaint.color = color;
    scale = Vector2.all(1.0);
  }
}

class Background extends Component {}
