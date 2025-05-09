// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:platformer/hud_components.dart';
import 'package:platformer/grid_component.dart';
import 'package:platformer/main.dart';
import 'package:platformer/my_game.dart';
import 'package:platformer/tile_component.dart';

class MyWorld extends World with HasGameRef<MyGame> {
  late double tileSize;
  late GridComponent grid;
  late double fieldSize;

  bool tapIsAvailible = true;
  late Random random;

  @override
  Future<void> onLoad() async {
    random = gameRef.random;
    tileSize = getTileSize();
    fieldSize = getFieldSize();
    resetLevel();
  }

  double getTileSize() {
    return (min(gameRef.size.x, gameRef.size.y) -
            Constants.fieldPadding * 2 -
            (Constants.columnCount - 1) * Constants.spaceBetweenTiles) /
        Constants.columnCount;
  }

  double getFieldSize() {
    return tileSize * Constants.columnCount +
        (Constants.columnCount - 1) * Constants.spaceBetweenTiles;
  }

  @override
  void onGameResize(Vector2 size) {
    tileSize = getTileSize();
    fieldSize = getFieldSize();
    grid.position = Vector2(
      (gameRef.size.x - fieldSize).abs() / 2,
      (gameRef.size.y - fieldSize).abs() / 2,
    );
    super.onGameResize(size);
  }

  void resetLevel() {
    tapIsAvailible = true;
    removeAll(children);
    grid = GridComponent(
      columnCount: Constants.columnCount,
      rowCount: Constants.rowCount,
      tileSize: tileSize,
    );
    add(Background(gameRef.size));
    add(grid);
    onGameResize(game.size);
  }

  final hudComponents = <Component>[];

  @override
  void onMount() {
    hudComponents.addAll([
      BackButton(
        ButtonSprites.back,
        position: Vector2(
          Constants.worldButtonsPaddinX,
          Constants.worldButtonsPaddinY,
        ),
      ),
      RestartButton(
        ButtonSprites.reload,
        position: Vector2(
          gameRef.size.x -
              Constants.worldButtonsPaddinX -
              Constants.worldButtonsSize,
          Constants.worldButtonsPaddinY,
        ),
        world: this,
      ),
    ]);
    gameRef.camera.viewport.addAll(hudComponents);
  }

  @override
  void onRemove() {
    gameRef.camera.viewport.removeAll(hudComponents);
    super.onRemove();
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

    final grid = children.whereType<GridComponent>().first;
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
        Vector2.all(grid.tileSize),
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
        Vector2.all(grid.tileSize),
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
        Duration(milliseconds: (Constants.switchDuration * 1000).toInt()),
      );
      bool hasMatch = true;
      while (hasMatch) {
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
                      curve: Curves.easeIn,
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
                  -(gameRef.size.y - grid.size.y) / 2 - grid.tileSize,
                ),
              )..add(
                MoveToEffect(
                  targetPosition,
                  EffectController(
                    duration: 1,
                    curve: Curves.easeInQuint,
                    startDelay: (j + Constants.rowCount - i) * 0.05,
                  ),
                ),
              );
              grid.tiles[i][j] = newTile;
              grid.add(newTile);
            }
          }
        }
        combinations = getFilledTilesCombinations(grid);
        await Future.delayed(
          Duration(milliseconds: (Constants.switchDuration * 5 * 1000).toInt()),
        );
        if (combinations.isEmpty) {
          // await Future.delayed(Duration(milliseconds: (1000).toInt()));
          hasMatch = false;
        }
      }
    }
    pair.clear();
    tapIsAvailible = true;
  }

  void resetPair() {
    final grid = children.whereType<GridComponent>().first;
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
