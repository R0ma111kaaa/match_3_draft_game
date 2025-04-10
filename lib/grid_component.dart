// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flame/components.dart';
import 'package:platformer/tile_component.dart';

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
