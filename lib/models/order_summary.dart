import 'cart_model.dart';

class OrderSummary {
  OrderSummary({
    required this.orderNumber,
    required this.customerName,
    required this.lines,
    required this.subtotal,
    required this.tax,
    required this.dineIn,
    required this.table,
    required this.payment,
    required this.createdAt,
  });

  final String orderNumber;
  final String customerName;
  final List<CartLine> lines;
  final int subtotal;
  final int tax;
  final bool dineIn;
  final String table;
  final String payment;
  final DateTime createdAt;

  int get total => subtotal + tax;
  int get totalItems => lines.fold(0, (s, l) => s + l.qty);
}
