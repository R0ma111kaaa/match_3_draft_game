import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyColors {
  static Color red = Colors.red;
  static Color yellow = Colors.yellow;
  static Color green = Colors.green;
  static Color brown = Colors.brown;
  static Color purple = Colors.purple;

  static final List<Color> colorList = [red, yellow, green, brown, purple];
  static final lenght = colorList.length;
}

class Constants {
  static int rowCount = 6;
  static int columnCount = 6;
  static int spaceBetweenTiles = 10;
  static double fieldPadding = 10;
}

class MyGame extends FlameGame {
  MyGame(World world) : super(world: world);

  @override
  Future<void> onLoad() async {
    children.register<GridComponent>();
    camera.viewfinder.anchor = Anchor.topLeft;
  }

  // var pair = {};
  // void addTileToPair(int row, int column) {
  //   if (pair.containsKey("first")) {
  //     pair["second"] = [row, column];
  //     switchPair(pair);
  //   } else {
  //     pair["first"] = [row, column];
  //   }
  // }

  // void switchPair(pair) {
  //   GridComponent grid = children.query<GridComponent>().first;
  //   var first = pair["first"];
  //   var second = pair["second"];
  //   var help = grid.tiles[first[0]][first[1]];
  //   grid.tiles[first[0]][first[1]] = grid.tiles[second[0]][second[1]];
  //   grid.tiles[second[0]][second[1]] = help;
  //   this.pair = {};
  // }
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
  dynamic tiles;

  Random random = Random();

  GridComponent({
    required this.rowCount,
    required this.columnCount,
    required this.tileSize,
  });

  @override
  void onLoad() async {
    super.anchor = Anchor.center;
    List<List<dynamic>> tiles = List<List>.generate(
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
    this.tiles = tiles;
  }
}

class TileComponent extends RectangleComponent
    with TapCallbacks, HasGameRef<MyGame> {
  int row;
  int column;
  double tileSize;
  Random random;

  TileComponent({
    required this.row,
    required this.column,
    required this.tileSize,
    required this.random,
  });

  @override
  void onLoad() {
    size = Vector2.all(tileSize);
    position = Vector2(
      column * (tileSize + Constants.spaceBetweenTiles),
      row * (tileSize + Constants.spaceBetweenTiles),
    );
    paint =
        Paint()..color = MyColors.colorList[random.nextInt(MyColors.lenght)];
  }

  // @override
  // void onTapDown(TapDownEvent event) {
  //   gameRef.addTileToPair(row, column);
  // }
}

void main() {
  final myGame = MyGame(MyWorld());
  runApp(GameWidget(game: myGame));
}
