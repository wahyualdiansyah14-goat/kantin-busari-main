import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/cart_model.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/emoji_tile.dart';
import '../widgets/qty_stepper.dart';

class MenuDetailPage extends StatefulWidget {
  const MenuDetailPage({super.key});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  final _noteCtrl = TextEditingController();
  int _qty = 1;
  int _variantIndex = 0;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final item = args is FoodItem ? args : menuItems.first;
    final variant = item.variants[_variantIndex];
    final total = (item.price + variant.extra) * _qty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: item.tint,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [item.tint, AppColors.background],
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 40),
                child: EmojiTile(
                    item: item, size: 120, heroTag: 'food-${item.id}'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(item.name,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Text(rupiah(item.price),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.star,
                          label: '${item.rating}'),
                      _InfoChip(
                          icon: Icons.schedule_rounded,
                          label: '${item.minutes} menit'),
                      _InfoChip(
                          icon: Icons.local_fire_department_outlined,
                          label: '${item.calories} kkal'),
                      _InfoChip(
                          icon: item.category.icon,
                          label: item.category.label),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.description,
                    style: const TextStyle(
                        height: 1.5, color: AppColors.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(item.variantLabel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < item.variants.length; i++)
                        ChoiceChip(
                          label: Text(item.variants[i].extra > 0
                              ? '${item.variants[i].label} (+${rupiah(item.variants[i].extra)})'
                              : item.variants[i].label),
                          selected: _variantIndex == i,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: _variantIndex == i
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                              color: Colors.orange.withValues(alpha: 0.25)),
                          onSelected: (_) => setState(() => _variantIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Catatan untuk Bu Sari',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    maxLength: 80,
                    decoration: InputDecoration(
                      hintText: 'Contoh: tanpa bawang goreng, telur setengah matang',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      leading: const Icon(Icons.info_outline_rounded,
                          color: AppColors.primary),
                      title: const Text('Bahan & informasi gizi',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.ingredients,
                            style: const TextStyle(
                                color: AppColors.textMuted, height: 1.5)),
                        const SizedBox(height: 8),
                        Text('Energi: ${item.calories} kkal per porsi',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 12,
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                QtyStepper(
                  value: _qty,
                  onAdd: () => setState(() => _qty++),
                  onRemove: () {
                    if (_qty > 1) setState(() => _qty--);
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      CartScope.of(context)
                          .add(item, variant, _qty, note: _noteCtrl.text);
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);
                      nav.pop();
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('$_qty× ${item.name} masuk keranjang'),
                          action: SnackBarAction(
                            label: 'Lihat',
                            onPressed: () => nav.pushNamed('/keranjang'),
                          ),
                        ));
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: Text('Tambah  •  ${rupiah(total)}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.iconColor});

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
