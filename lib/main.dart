import 'package:flutter/material.dart';

import 'models/cart_model.dart';
import 'pages/cart_page.dart';
import 'pages/menu_detail_page.dart';
import 'pages/menu_list_page.dart';
import 'pages/order_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CartModel _cart = CartModel();

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CartScope berada di atas MaterialApp sehingga semua route bisa
    // mengakses keranjang yang sama.
    return CartScope(
      cart: _cart,
      child: MaterialApp(
        title: 'Kantin Bu Sari',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const MenuListPage(),
          '/detail': (context) => const MenuDetailPage(),
          '/keranjang': (context) => const CartPage(),
          '/pesan': (context) => const OrderPage(),
        },
      ),
    );
  }
}
