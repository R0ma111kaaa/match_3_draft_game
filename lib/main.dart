// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyColors {
  static Color red = Colors.red;
  static Color yellow = Colors.yellow;
  static Color green = Colors.green;
  static Color pink = Colors.pink;
  static Color purple = Colors.purple;

  static final List<Color> colorList = [red, yellow, green, pink, purple];
  static final lenght = colorList.length;
}

class Constants {
  static int rowCount = 6;
  static int columnCount = 6;
  static int spaceBetweenTiles = 10;
  static double fieldPadding = 10;
  static double switchDuration = 0.4;
  static double resizeDuration = 0.4;
}

class MyGame extends FlameGame {
  MyGame(World world) : super(world: world);

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

  void switchPair() {
    final grid = world.children.whereType<GridComponent>().first;
    switchPairInTheGrid(grid);

    var first = pair[0];
    var second = pair[1];

    var tile1 = grid.tiles[first[0]][first[1]];
    var tile2 = grid.tiles[second[0]][second[1]];

    // Запоминаем их абсолютные позиции
    Vector2 pos1 = tile1.getPosition();
    Vector2 pos2 = tile2.getPosition();

    List<List<TileComponent>> filledTiles = getFilledTiles();
    if (filledTiles.isEmpty) {
      switchPairInTheGrid(grid);
    }

    // Перемещаем тайлы
    tile1.add(
      SequenceEffect([
        MoveToEffect(
          pos2,
          EffectController(
            duration: Constants.switchDuration,
            alternate: filledTiles.isEmpty ? true : false,
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
            alternate: filledTiles.isEmpty ? true : false,
          ),
        ),
        SizeEffect.to(
          Vector2.all(tile2.tileSize),
          EffectController(duration: Constants.resizeDuration),
        ),
      ]),
    );

    pair.clear();
  }

  void resetPair() {
    final grid = world.children.whereType<GridComponent>().first;
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
    pair.clear();
  }

  // Возвращает список удаляемых блоков
  List<List<TileComponent>> getFilledTiles() {
    List<List<TileComponent>> transposedMatrix = List.generate(
      Constants.columnCount,
      (_) => [],
    );
    final grid = world.children.whereType<GridComponent>().first;

    List<List<TileComponent>> filledRows = [];
    List<TileComponent> filledRow = [];
    // проверяем 3 в ряд в строках, попутно созадавая транспонированную матрицу
    for (int i = 0; i < Constants.rowCount; i++) {
      for (int j = 0; j < Constants.columnCount; j++) {
        TileComponent curElement = grid.tiles[i][j];

        if (filledRow.isEmpty || filledRow.last.color == curElement.color) {
          filledRow.add(curElement);
        } else {
          if (filledRow.length >= 3) {
            filledRows.add(List.from(filledRow));
          }
          filledRow.clear();
          filledRow.add(curElement);
        }
        // доббавляем элемент в транспонированную матрицу
        transposedMatrix[j].add(curElement);
      }

      if (filledRow.length >= 3) {
        filledRows.add(List.from(filledRow));
      }
      filledRow.clear();
    }
    for (int i = 0; i < Constants.columnCount; i++) {
      for (int j = 0; j < Constants.rowCount; j++) {
        TileComponent curElement = transposedMatrix[i][j];

        if (filledRow.isEmpty || filledRow.last.color == curElement.color) {
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
      filledRow.clear();
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

    grid.tiles[first[0]][first[1]].row = first[0];
    grid.tiles[first[0]][first[1]].column = first[1];

    grid.tiles[second[0]][second[1]].row = second[0];
    grid.tiles[second[0]][second[1]].column = second[1];
  }
}

class MyWorld extends World with HasGameRef<MyGame> {
  @override
  Future<void> onLoad() async {
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

class GridComponent extends PositionComponent {
  int rowCount;
  int columnCount;
  double tileSize;
  List<List<dynamic>> tiles = [];

  Random random = Random();

  GridComponent({
    required this.rowCount,
    required this.columnCount,
    required this.tileSize,
  });

  @override
  void onLoad() async {
    super.anchor = Anchor.center;
    tiles = List<List>.generate(
      rowCount,
      (i) => List<TileComponent>.generate(columnCount, (j) {
        TileComponent tile = TileComponent(
          row: i,
          column: j,
          tileSize: tileSize,
          random: random,
        );
        add(tile);
        return tile;
      }),
    );
  }
}

class TileComponent extends RectangleComponent
    with TapCallbacks, HasGameRef<MyGame> {
  int row;
  int column;
  double tileSize;
  Random random;
  bool isTapped = false;
  late Color color;

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
    color = MyColors.colorList[random.nextInt(MyColors.lenght)];
    paint = Paint()..color = color;
  }

  @override
  void onTapDown(TapDownEvent event) {
    var pair = gameRef.pair;
    if (!isTapped) {
      if (pair.isNotEmpty) {
        dynamic firstElement = pair[0];
        int verticalDistance = (firstElement[0] - row).abs();
        int horisontalDistance = (firstElement[1] - column).abs();
        if (!(horisontalDistance == 0 && verticalDistance == 1 ||
                verticalDistance == 0 && horisontalDistance == 1) ||
            firstElement == [row, column]) {
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

void main() {
  final myGame = MyGame(MyWorld());
  runApp(GameWidget(game: myGame));
}
