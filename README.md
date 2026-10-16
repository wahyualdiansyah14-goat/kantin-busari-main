# Kantin Bu Sari

Aplikasi Flutter pemesanan menu kantin. Alur: **Daftar Menu → Detail Menu → Keranjang → Struk & Status Pesanan**.

## Fitur
- Pencarian menu, filter kategori, promo paket hemat, tambah cepat ke keranjang
- Detail menu: pilihan varian, catatan, jumlah, info bahan & gizi
- Keranjang: ubah jumlah, geser untuk hapus, tipe pesanan, nomor meja, metode bayar, pajak 10%
- Struk pesanan dengan status yang berjalan otomatis (Diterima → Diproses → Siap)

## Struktur
```
lib/
  main.dart            # routes + CartScope
  theme/               # warna & tema
  models/              # FoodItem, CartModel, OrderSummary
  data/menu_data.dart  # data menu
  widgets/             # FoodCard, QtyStepper, PriceRow, EmojiTile
  pages/               # menu_list, menu_detail, cart, order
```

## Menjalankan
```
flutter pub get
flutter run
flutter test
```
Tanpa package tambahan dan tanpa aset gambar (gambar menu memakai emoji).
