// App state provider wrapping Firestore service

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class AppState extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<StoreModel> _stores = [];
  List<TransactionModel> _transactions = [];
  List<ProductModel> _products = [];
  bool _isLoading = true;

  List<StoreModel> get stores => _stores;
  List<TransactionModel> get transactions => _transactions;
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  /// Quick lookup map: productId -> ProductModel
  Map<String, ProductModel> get productsMap =>
      {for (final p in _products) p.id: p};

  AppState() {
    _init();
  }

  void _init() {
    // Listen to products stream
    _service.productsStream().listen((products) {
      _products = products;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error loading products: $e');
    });

    // Listen to stores stream
    _service.storesStream().listen((stores) {
      _stores = stores;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error loading stores: $e');
      _isLoading = false;
      notifyListeners();
    });

    // Listen to transactions stream
    _service.transactionsStream().listen((txs) {
      _transactions = txs;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error loading transactions: $e');
    });
  }

  // ─── Product Operations ─────────────────────────────────

  Future<ProductModel> addProduct({
    required String name,
    required double price,
    required double productionCost,
    required int colorValue,
  }) async {
    return await _service.addProduct(
      name: name,
      price: price,
      productionCost: productionCost,
      colorValue: colorValue,
    );
  }

  Future<void> updateProduct(String id, {
    String? name,
    double? price,
    double? productionCost,
    int? colorValue,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (price != null) updates['price'] = price;
    if (productionCost != null) updates['productionCost'] = productionCost;
    if (colorValue != null) updates['colorValue'] = colorValue;
    if (updates.isNotEmpty) {
      await _service.updateProduct(id, updates);
    }
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Store Operations ────────────────────────────────────

  Future<StoreModel> addStore({
    required String name,
    required String contactName,
    required String address,
    required double commissionRate,
  }) async {
    return await _service.addStore(
      name: name,
      contactName: contactName,
      address: address,
      commissionRate: commissionRate,
    );
  }

  Future<void> updateStore(String id, {
    String? name,
    String? contactName,
    String? address,
    double? commissionRate,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (contactName != null) updates['contactName'] = contactName;
    if (address != null) updates['address'] = address;
    if (commissionRate != null) updates['commissionRate'] = commissionRate;
    if (updates.isNotEmpty) {
      await _service.updateStore(id, updates);
    }
  }

  Future<void> deleteStore(String id) async {
    await _service.deleteStore(id);
  }

  StoreModel? getStoreById(String id) {
    try {
      return _stores.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Delivery Operations ─────────────────────────────────

  Future<void> addDelivery({
    required StoreModel store,
    required Map<String, int> items,
  }) async {
    await _service.addDelivery(
      store: store,
      items: items,
      productsMap: productsMap,
    );
  }

  // ─── Sale / Cobro Operations ─────────────────────────────

  Future<void> registerSale({
    required StoreModel store,
    required Map<String, int> currentStock,
  }) async {
    await _service.registerSale(
      store: store,
      currentStock: currentStock,
      productsMap: productsMap,
    );
  }

  // ─── Payment Operations ──────────────────────────────────

  Future<void> addPayment({
    required StoreModel store,
    required double amount,
    String? note,
  }) async {
    await _service.addPayment(store: store, amount: amount, note: note);
  }

  // ─── Delete Transaction ──────────────────────────────────

  Future<void> deleteTransaction(TransactionModel tx) async {
    await _service.deleteTransaction(tx);
  }

  // ─── Computed Values ─────────────────────────────────────

  double get totalInventoryValue {
    final pm = productsMap;
    return _stores.fold(0.0, (sum, s) => sum + s.inventoryValueWith(pm));
  }

  int get totalConsignment =>
      _stores.fold(0, (sum, s) => sum + s.totalStock);

  double get totalReceivable =>
      _stores.fold(0.0, (sum, s) => sum + s.balance);

  double get totalEstimatedProfit {
    final pm = productsMap;
    return _stores.fold(0.0, (sum, store) {
      double profit = 0;
      store.inventory.forEach((productId, stats) {
        final product = pm[productId];
        if (product != null && stats.sold > 0) {
          profit += (product.price - product.productionCost) * stats.sold;
        }
      });
      return sum + profit;
    });
  }

  List<TransactionModel> get recentTransactions {
    final sorted = List<TransactionModel>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(20).toList();
  }

  List<TransactionModel> transactionsForStore(String storeId) {
    return _transactions.where((t) => t.storeId == storeId).toList();
  }
}
