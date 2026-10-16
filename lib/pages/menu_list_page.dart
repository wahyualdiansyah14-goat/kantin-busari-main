import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/cart_model.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/food_card.dart';

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  final _searchCtrl = TextEditingController();
  MenuCategory? _category;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FoodItem> get _filtered => menuItems.where((m) {
        final okCategory = _category == null || m.category == _category;
        final okQuery = m.name.toLowerCase().contains(_query.toLowerCase());
        return okCategory && okQuery;
      }).toList();

  void _quickAdd(FoodItem item) {
    final cart = CartScope.of(context);
    cart.add(item, item.variants.first, 1);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${item.name} ditambahkan'),
          action: SnackBarAction(
            label: 'Keranjang',
            onPressed: () => Navigator.pushNamed(context, '/keranjang'),
          ),
        ),
      );
  }

  void _addPromoPackage() {
    final cart = CartScope.of(context);
    cart.add(menuItems[0], menuItems[0].variants.first, 1);
    cart.add(menuItems[5], menuItems[5].variants.first, 1);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text('Paket Nasi Goreng + Es Teh ditambahkan'),
          action: SnackBarAction(
            label: 'Keranjang',
            onPressed: () => Navigator.pushNamed(context, '/keranjang'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final items = _filtered;

    return Scaffold(
      floatingActionButton: cart.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/keranjang'),
              icon: const Icon(Icons.shopping_basket_rounded),
              label: Text(
                  '${cart.totalItems} item  •  ${rupiah(cart.subtotal)}'),
            ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text('Kantin Bu Sari',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Keranjang',
                onPressed: () => Navigator.pushNamed(context, '/keranjang'),
                icon: Badge(
                  isLabelVisible: cart.totalItems > 0,
                  label: Text('${cart.totalItems}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mau makan apa hari ini? 👋',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pesan dari meja, ambil tanpa antre.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  _PromoBanner(onTap: _addPromoPackage),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari menu favoritmu...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: 'Semua',
                          icon: Icons.apps_rounded,
                          selected: _category == null,
                          onTap: () => setState(() => _category = null),
                        ),
                        for (final c in MenuCategory.values)
                          _CategoryChip(
                            label: c.label,
                            icon: c.icon,
                            selected: _category == c,
                            onTap: () => setState(() => _category = c),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Menu Hari Ini',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      Text('${items.length} menu',
                          style: const TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            sliver: items.isEmpty
                ? const SliverToBoxAdapter(child: _EmptySearch())
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisExtent: 236,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => FoodCard(
                        item: items[i],
                        onTap: () => Navigator.pushNamed(context, '/detail',
                            arguments: items[i]),
                        onAdd: () => _quickAdd(items[i]),
                      ),
                      childCount: items.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFFFF922B)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('PAKET HEMAT',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nasi Goreng + Es Teh',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Cuma Rp19.000, kenyang dan segar.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Ambil Paket'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('🍛', style: TextStyle(fontSize: 64)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon,
            size: 18, color: selected ? Colors.white : AppColors.primary),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: Colors.orange.withValues(alpha: 0.2)),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Text('🔍', style: TextStyle(fontSize: 48)),
          SizedBox(height: 8),
          Text('Menu tidak ditemukan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          SizedBox(height: 4),
          Text('Coba kata kunci atau kategori lain.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
