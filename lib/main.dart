// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:platformer/constants.dart';
import 'package:platformer/grid_component.dart';
import 'package:platformer/my_world.dart';
import 'package:platformer/tile_component.dart';

class MyGame extends FlameGame {
  MyGame(World world) : super(world: world);

  late GridComponent grid;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    grid = world.children.whereType<GridComponent>().first;
  }

  var pair = [];
  void addTileToPair(int row, int column) {
    pair.add([row, column]);
    if (pair.length == 2) {
      switchPair();
    }
  }

  void switchPair() {
    var first = pair[0];
    var second = pair[1];

    var tile1 = grid.tiles[first[0]][first[1]];
    var tile2 = grid.tiles[second[0]][second[1]];

    // Запоминаем их абсолютные позиции
    Vector2 pos1 = tile1.getPosition();
    Vector2 pos2 = tile2.getPosition();

    List<List<int>> filledBlocks = getFilledBlocks();
    print("empty list: ${filledBlocks.isEmpty}");

    // Перемещаем тайлы
    tile1.add(
      SequenceEffect([
        MoveToEffect(
          pos2,
          EffectController(
            duration: Constants.switchDuration,
            alternate: filledBlocks.isEmpty ? true : false,
          ),
        ),
        SizeEffect.to(
          Vector2.all(tile2.tileSize),
          EffectController(duration: Constants.resizeDuration),
        ),
      ]),
    );

    tile2.add(
      SequenceEffect([
        MoveToEffect(
          pos1,
          EffectController(
            duration: Constants.switchDuration,
            alternate: filledBlocks.isEmpty ? true : false,
          ),
        ),
        SizeEffect.to(
          Vector2.all(tile2.tileSize),
          EffectController(duration: Constants.resizeDuration),
        ),
      ]),
    );

    pair = [];
  }

  void resetPair() {
    if (pair.isNotEmpty) {
      var cords = pair[0];
      var tile = grid.tiles[cords[0]][cords[1]];
      tile.add(
        SizeEffect.to(
          Vector2.all(tile.tileSize),
          EffectController(duration: Constants.resizeDuration),
        ),
      );
    }
    pair = [];
  }

  // Возвращает список удаляемых блоков
  List<List<int>> getFilledBlocks() {
    return [];
  }
}

void main() {
  final myGame = MyGame(MyWorld());
  runApp(GameWidget(game: myGame));
}
