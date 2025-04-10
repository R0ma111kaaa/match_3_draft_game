// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flame/components.dart';
import 'package:platformer/main.dart';
import 'package:platformer/tile_component.dart';

class GridComponent extends PositionComponent {
  int rowCount;
  int columnCount;
  double tileSize;
  List<List<TileComponent?>> tiles = [];

  Random random = Random();

  GridComponent({
    required this.rowCount,
    required this.columnCount,
    required this.tileSize,
  });

  @override
  void onLoad() async {
    super.anchor = Anchor.topLeft;
    tiles = List<List<TileComponent?>>.generate(
      rowCount,
      (i) => List<TileComponent?>.generate(columnCount, (j) {
        TileComponent tile = TileComponent(
          row: i,
          column: j,
          tileSize: tileSize,
          random: random,
          position: getPosition(i, j),
        );
        add(tile);
        return tile;
      }),
    );
  }

  Vector2 getPosition(int row, int column) {
    return Vector2(
      column * (tileSize + Constants.spaceBetweenTiles) + tileSize / 2,
      row * (tileSize + Constants.spaceBetweenTiles) + tileSize / 2,
    );
  }
}
