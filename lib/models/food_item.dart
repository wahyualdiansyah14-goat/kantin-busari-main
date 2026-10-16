import 'package:flutter/material.dart';

enum MenuCategory { makanan, minuman, camilan }

extension MenuCategoryX on MenuCategory {
  String get label {
    switch (this) {
      case MenuCategory.makanan:
        return 'Makanan';
      case MenuCategory.minuman:
        return 'Minuman';
      case MenuCategory.camilan:
        return 'Camilan';
    }
  }

  IconData get icon {
    switch (this) {
      case MenuCategory.makanan:
        return Icons.rice_bowl_outlined;
      case MenuCategory.minuman:
        return Icons.local_cafe_outlined;
      case MenuCategory.camilan:
        return Icons.cookie_outlined;
    }
  }
}

/// Pilihan varian menu (level pedas, ukuran, dsb) beserta tambahan harga.
class MenuVariant {
  const MenuVariant(this.label, [this.extra = 0]);
  final String label;
  final int extra;
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
    required this.category,
    required this.rating,
    required this.minutes,
    required this.calories,
    required this.ingredients,
    required this.variantLabel,
    required this.variants,
    required this.tint,
    this.isBestSeller = false,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;
  final int price;
  final MenuCategory category;
  final double rating;
  final int minutes;
  final int calories;
  final String ingredients;
  final String variantLabel;
  final List<MenuVariant> variants;
  final Color tint;
  final bool isBestSeller;
}
