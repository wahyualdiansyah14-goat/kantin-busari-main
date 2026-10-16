import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/order_summary.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/price_row.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const _steps = <(String, IconData)>[
    ('Diterima', Icons.receipt_long_rounded),
    ('Diproses', Icons.soup_kitchen_rounded),
    ('Siap', Icons.notifications_active_rounded),
  ];

  Timer? _timer;
  int _status = 0;

  @override
  void initState() {
    super.initState();
    // Simulasi progres pesanan agar status terlihat hidup.
    _timer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (!mounted) return;
      if (_status >= _steps.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _status++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _backToMenu() =>
      Navigator.popUntil(context, (route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! OrderSummary) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pesanan')),
        body: Center(
          child: FilledButton(
              onPressed: _backToMenu, child: const Text('Kembali ke Menu')),
        ),
      );
    }
    final order = args;
    final ready = _status == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pesanan Berhasil',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Tutup',
            onPressed: _backToMenu,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 52, color: Color(0xFF16A34A)),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Pesanan Kamu Diterima!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              order.dineIn
                  ? 'Santai di ${order.table}, pesanan akan diantar.'
                  : 'Pesanan dibungkus, ambil di kasir Bu Sari.',
              style: const TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _StatusCard(status: _status, steps: _steps, ready: ready),
            const SizedBox(height: 16),
            _ReceiptCard(order: order),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await Clipboard.setData(
                          ClipboardData(text: order.orderNumber));
                      messenger.showSnackBar(const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Nomor pesanan disalin'),
                      ));
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Salin Nomor'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _backToMenu,
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text('Kembali ke Menu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.steps,
    required this.ready,
  });

  final int status;
  final List<(String, IconData)> steps;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final done = i <= status;
      children.add(
        SizedBox(
          width: 72,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.primary : Colors.grey.shade200,
                ),
                child: Icon(steps[i].$2,
                    size: 20, color: done ? Colors.white : Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                steps[i].$1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                  color: done ? Colors.black87 : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
      if (i < steps.length - 1) {
        children.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i < status ? AppColors.primary : Colors.grey.shade200,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
          const SizedBox(height: 14),
          Text(
            ready
                ? 'Pesananmu sudah siap! 🎉'
                : 'Estimasi selesai sekitar 10–15 menit',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ready ? const Color(0xFF16A34A) : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.order});
  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nomor pesanan',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                  Text(order.orderNumber,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark)),
                ],
              ),
              Chip(
                avatar: Icon(
                    order.dineIn
                        ? Icons.chair_alt_outlined
                        : Icons.shopping_bag_outlined,
                    size: 16),
                label: Text(order.dineIn ? order.table : 'Bawa pulang'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'a.n. ${order.customerName} • ${formatTime(order.createdAt)} • ${order.payment}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          for (final l in order.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l.qty}×',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.item.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          l.note.isEmpty
                              ? l.variant.label
                              : '${l.variant.label} • ${l.note}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(rupiah(l.subtotal)),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          PriceRow('Subtotal', rupiah(order.subtotal)),
          PriceRow('Pajak 10%', rupiah(order.tax)),
          PriceRow('Total', rupiah(order.total), bold: true),
        ],
      ),
    );
  }
}
