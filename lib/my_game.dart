// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:platformer/grid_component.dart';
import 'package:platformer/main.dart';
import 'package:platformer/my_world.dart';
import 'package:platformer/tile_component.dart';

class MyGame extends FlameGame {
  MyGame(World world) : super(world: world);

  bool tapIsAvailible = true;
  Random random = Random();

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
  }

  var pair = [];
  void addTileToPair(int row, int column) {
    pair.add([row, column]);
    if (pair.length == 2) {
      switchPair();
    }
  }

  void switchPair() async {
    tapIsAvailible = false;

    final grid = world.children.whereType<GridComponent>().first;
    switchPairInTheGrid(grid);

    var first = pair[0];
    var second = pair[1];

    var tile1 = grid.tiles[first[0]][first[1]];
    var tile2 = grid.tiles[second[0]][second[1]];

    // Запоминаем их абсолютные позиции
    Vector2? pos1 = tile1?.getPosition();
    Vector2? pos2 = tile2?.getPosition();

    List<List<TileComponent>> combinations = getFilledTilesCombinations(grid);

    // меняем 2 тайла между собой
    tile1!.addAll([
      SizeEffect.to(
        Vector2.all((world as MyWorld).tileSize),
        EffectController(duration: Constants.resizeDuration),
      ),
      MoveToEffect(
        pos2!,
        EffectController(
          duration: Constants.switchDuration,
          alternate: combinations.isEmpty ? true : false,
          curve: Curves.easeInOutBack,
        ),
      ),
    ]);

    tile2!.addAll([
      SizeEffect.to(
        Vector2.all((world as MyWorld).tileSize),
        EffectController(duration: Constants.resizeDuration),
      ),
      MoveToEffect(
        pos1!,
        EffectController(
          duration: Constants.switchDuration,
          alternate: combinations.isEmpty ? true : false,
          curve: Curves.easeInOutBack,
        ),
      ),
    ]);

    if (combinations.isEmpty) {
      switchPairInTheGrid(grid);
    } else {
      await Future.delayed(
        Duration(milliseconds: (Constants.switchDuration * 1 * 1000).toInt()),
      );

      Set<TileComponent> filledTiles = combinations.expand((x) => x).toSet();

      // удаляем тавсе тайлы в совпадениях
      for (TileComponent tile in filledTiles) {
        grid.tiles[tile.row][tile.column] = null;
        tile.dropFromTheGrid();
      }

      // Опускаем существующие тайлы
      for (int j = 0; j < Constants.columnCount; j++) {
        for (int i = Constants.rowCount - 1; i > 0; i--) {
          TileComponent? tile = grid.tiles[i][j];
          if (tile == null) {
            TileComponent? higherTile = findFirstHigherTile(grid.tiles, i, j);
            if (higherTile != null) {
              grid.tiles[i][j] = higherTile;
              grid.tiles[higherTile.row][higherTile.column] = null;
              higherTile.add(
                MoveToEffect(
                  grid.getPosition(i, j),
                  EffectController(
                    duration: Constants.slideAnimationTime,
                    curve: Curves.easeInOutBack,
                  ),
                ),
              );
              higherTile.row = i;
              higherTile.column = j;
            }
          }
        }
      }

      // Заполняем пустые тайлы
      for (int j = 0; j < Constants.columnCount; j++) {
        for (int i = Constants.rowCount - 1; i >= 0; i--) {
          TileComponent? tile = grid.tiles[i][j];
          if (tile == null) {
            Vector2 targetPosition = grid.getPosition(i, j);
            TileComponent newTile = TileComponent(
              row: i,
              column: j,
              tileSize: grid.tileSize,
              random: random,
              position: Vector2(
                targetPosition.x,
                -(size.y - grid.size.y) / 2 - grid.tileSize,
              ),
            )..add(
              MoveToEffect(
                targetPosition,
                EffectController(
                  duration: 1,
                  curve: Curves.easeIn,
                  startDelay: j * 0.1,
                ),
              ),
            );
            grid.tiles[i][j] = newTile;
            grid.add(newTile);
          }
        }
      }
    }

    pair.clear();
    tapIsAvailible = true;
  }

  void resetPair() {
    final grid = world.children.whereType<GridComponent>().first;
    if (pair.isNotEmpty) {
      var cords = pair[0];
      var tile = grid.tiles[cords[0]][cords[1]];
      tile?.add(
        SizeEffect.to(
          Vector2.all(tile.tileSize),
          EffectController(duration: Constants.resizeDuration),
        ),
      );
    }
    pair.clear();
  }

  // Возвращает список удаляемых блоков
  List<List<TileComponent>> getFilledTilesCombinations(GridComponent grid) {
    List<List<TileComponent>> filledRows = [];

    for (int i = 0; i < Constants.rowCount; i++) {
      List<TileComponent?> filledRow = [];
      for (int j = 0; j < Constants.columnCount; j++) {
        TileComponent? curElement = grid.tiles[i][j];

        if (filledRow.isEmpty ||
            filledRow.last!.spriteName == curElement!.spriteName) {
          filledRow.add(curElement);
        } else {
          if (filledRow.length >= 3) {
            filledRows.add(List.from(filledRow));
          }
          filledRow.clear();
          filledRow.add(curElement);
        }
      }

      if (filledRow.length >= 3) {
        filledRows.add(List.from(filledRow));
      }
    }

    for (int j = 0; j < Constants.columnCount; j++) {
      List<TileComponent?> filledRow = [];
      for (int i = 0; i < Constants.rowCount; i++) {
        TileComponent? curElement = grid.tiles[i][j];

        if (filledRow.isEmpty ||
            filledRow.last!.spriteName == curElement!.spriteName) {
          filledRow.add(curElement);
        } else {
          if (filledRow.length >= 3) {
            filledRows.add(List.from(filledRow));
          }
          filledRow.clear();
          filledRow.add(curElement);
        }
      }

      if (filledRow.length >= 3) {
        filledRows.add(List.from(filledRow));
      }
    }

    return filledRows;
  }

  void switchPairInTheGrid(GridComponent grid) {
    var first = pair[0];
    var second = pair[1];

    var tile1 = grid.tiles[first[0]][first[1]];
    var tile2 = grid.tiles[second[0]][second[1]];

    grid.tiles[first[0]][first[1]] = tile2;
    grid.tiles[second[0]][second[1]] = tile1;

    grid.tiles[first[0]][first[1]]?.row = first[0];
    grid.tiles[first[0]][first[1]]?.column = first[1];

    grid.tiles[second[0]][second[1]]?.row = second[0];
    grid.tiles[second[0]][second[1]]?.column = second[1];
  }

  TileComponent? findFirstHigherTile(
    List<List<TileComponent?>> tiles,
    int row,
    int column,
  ) {
    for (int y = row - 1; y >= 0; y--) {
      TileComponent? currentTile = tiles[y][column];
      if (currentTile != null) {
        return currentTile;
      }
    }
    return null;
  }
}
