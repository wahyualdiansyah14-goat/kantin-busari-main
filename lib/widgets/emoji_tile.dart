import 'package:flutter/material.dart';

import '../models/food_item.dart';

/// Pengganti foto menu: emoji di atas latar gradien, dengan animasi Hero.
class EmojiTile extends StatelessWidget {
  const EmojiTile({
    super.key,
    required this.item,
    this.size = 56,
    this.heroTag,
  });

  final FoodItem item;
  final double size;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget emoji = SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        child: Material(
          type: MaterialType.transparency,
          child: Text(item.emoji, style: TextStyle(fontSize: size)),
        ),
      ),
    );
    if (heroTag != null) {
      emoji = Hero(tag: heroTag!, child: emoji);
    }
    return emoji;
  }
}
