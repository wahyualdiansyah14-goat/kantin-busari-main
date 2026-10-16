import 'package:flutter/material.dart';

import 'food_item.dart';

class CartLine {
  CartLine({
    required this.item,
    required this.variant,
    required this.qty,
    this.note = '',
  });

  final FoodItem item;
  final MenuVariant variant;
  final String note;
  int qty;

  int get unitPrice => item.price + variant.extra;
  int get subtotal => unitPrice * qty;
  String get key => '${item.id}|${variant.label}|$note';
}

class CartModel extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;
  int get totalItems => _lines.fold(0, (s, l) => s + l.qty);
  int get subtotal => _lines.fold(0, (s, l) => s + l.subtotal);

  void add(FoodItem item, MenuVariant variant, int qty, {String note = ''}) {
    final probe =
        CartLine(item: item, variant: variant, qty: qty, note: note.trim());
    final idx = _lines.indexWhere((l) => l.key == probe.key);
    if (idx >= 0) {
      _lines[idx].qty += qty;
    } else {
      _lines.add(probe);
    }
    notifyListeners();
  }

  void increment(CartLine line) {
    line.qty++;
    notifyListeners();
  }

  void decrement(CartLine line) {
    if (line.qty <= 1) {
      _lines.remove(line);
    } else {
      line.qty--;
    }
    notifyListeners();
  }

  void remove(CartLine line) {
    _lines.remove(line);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}

/// Menyediakan CartModel ke seluruh halaman tanpa package tambahan.
class CartScope extends InheritedNotifier<CartModel> {
  const CartScope({super.key, required CartModel cart, required super.child})
      : super(notifier: cart);

  static CartModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope tidak ditemukan di widget tree');
    return scope!.notifier!;
  }
}
