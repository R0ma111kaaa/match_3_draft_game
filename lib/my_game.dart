// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:platformer/menu.dart';
import 'package:platformer/my_world.dart';

class MyGame extends FlameGame {
  late final RouterComponent router;
  Random random = Random();

  // @override
  // bool debugMode = true;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    add(
      router = RouterComponent(
        routes: {
          "menu": Route(MyMenu.new),
          "world": WorldRoute(MyWorld.new),
          // "pause": Route(),
          // "settings": Route()
        },
        initialRoute: "menu",
      ),
    );
  }
}
