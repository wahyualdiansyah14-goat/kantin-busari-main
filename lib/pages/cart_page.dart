import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../models/order_summary.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/emoji_tile.dart';
import '../widgets/price_row.dart';
import '../widgets/qty_stepper.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const _payments = <String, IconData>{
    'Tunai': Icons.payments_outlined,
    'QRIS': Icons.qr_code_2_rounded,
    'Transfer': Icons.account_balance_outlined,
  };

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _dineIn = true;
  String _table = 'Meja 1';
  String _payment = 'Tunai';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  int _tax(int subtotal) => (subtotal * 0.1).round();

  Future<void> _confirmClear(CartModel cart) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan keranjang?'),
        content: const Text('Semua menu di keranjang akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Kosongkan')),
        ],
      ),
    );
    if (ok == true) cart.clear();
  }

  void _checkout(CartModel cart) {
    if (!_formKey.currentState!.validate()) return;
    final subtotal = cart.subtotal;
    final order = OrderSummary(
      orderNumber: 'BS-${100 + DateTime.now().millisecondsSinceEpoch % 900}',
      customerName: _nameCtrl.text.trim(),
      lines: List<CartLine>.from(cart.lines),
      subtotal: subtotal,
      tax: _tax(subtotal),
      dineIn: _dineIn,
      table: _table,
      payment: _payment,
      createdAt: DateTime.now(),
    );
    cart.clear();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/pesan',
      (route) => route.isFirst,
      arguments: order,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final subtotal = cart.subtotal;
    final tax = _tax(subtotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!cart.isEmpty)
            TextButton.icon(
              onPressed: () => _confirmClear(cart),
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              label: const Text('Kosongkan'),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const _EmptyCart()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Pesanan (geser kiri untuk hapus)'),
                    for (final line in cart.lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(line.key),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.delete_outline_rounded),
                          ),
                          onDismissed: (_) => cart.remove(line),
                          child: _CartTile(line: line, cart: cart),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const _SectionTitle('Data pemesan'),
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                          'Nama pemesan', Icons.person_outline_rounded),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama pemesan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                              value: true,
                              icon: Icon(Icons.chair_alt_outlined),
                              label: Text('Makan di tempat')),
                          ButtonSegment(
                              value: false,
                              icon: Icon(Icons.shopping_bag_outlined),
                              label: Text('Bawa pulang')),
                        ],
                        selected: {_dineIn},
                        onSelectionChanged: (s) =>
                            setState(() => _dineIn = s.first),
                      ),
                    ),
                    if (_dineIn) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _table,
                        decoration: _inputDecoration(
                            'Nomor meja', Icons.table_restaurant_outlined),
                        items: [
                          for (var i = 1; i <= 12; i++)
                            DropdownMenuItem(
                                value: 'Meja $i', child: Text('Meja $i')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _table = v);
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    const _SectionTitle('Metode pembayaran'),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final e in _payments.entries)
                          ChoiceChip(
                            avatar: Icon(e.value,
                                size: 18,
                                color: _payment == e.key
                                    ? Colors.white
                                    : AppColors.primary),
                            label: Text(e.key),
                            selected: _payment == e.key,
                            showCheckmark: false,
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _payment == e.key
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                                color: Colors.orange.withValues(alpha: 0.25)),
                            onSelected: (_) =>
                                setState(() => _payment = e.key),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle('Ringkasan pembayaran'),
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            PriceRow('Subtotal (${cart.totalItems} item)',
                                rupiah(subtotal)),
                            PriceRow('Pajak 10%', rupiah(tax)),
                            const Divider(height: 20),
                            PriceRow('Total', rupiah(subtotal + tax),
                                bold: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Material(
              elevation: 12,
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total bayar',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                          Text(rupiah(subtotal + tax),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _checkout(cart),
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text('Pesan Sekarang'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.line, required this.cart});

  final CartLine line;
  final CartModel cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: line.item.tint,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: EmojiTile(item: line.item, size: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  '${line.item.variantLabel}: ${line.variant.label}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                if (line.note.isNotEmpty)
                  Text(
                    '“${line.note}”',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted),
                  ),
                const SizedBox(height: 4),
                Text(rupiah(line.subtotal),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark)),
              ],
            ),
          ),
          QtyStepper(
            value: line.qty,
            onAdd: () => cart.increment(line),
            onRemove: () => cart.decrement(line),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text('Keranjangmu masih kosong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Yuk pilih menu favoritmu dulu di daftar menu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text('Lihat Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
