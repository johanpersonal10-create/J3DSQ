// Data models for J3D SQ

import 'package:cloud_firestore/cloud_firestore.dart';

/// Product model — user-defined products with custom prices
class ProductModel {
  final String id;
  final String name;
  final double price;
  final double productionCost;
  final int colorValue; // hex ARGB, e.g. 0xFF2196F3

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.productionCost,
    this.colorValue = 0xFF6C5CE7,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'productionCost': productionCost,
        'colorValue': colorValue,
      };

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      productionCost: (map['productionCost'] as num?)?.toDouble() ?? 0,
      colorValue: (map['colorValue'] as num?)?.toInt() ?? 0xFF6C5CE7,
    );
  }

  ProductModel copyWith({
    String? name,
    double? price,
    double? productionCost,
    int? colorValue,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      productionCost: productionCost ?? this.productionCost,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

/// Inventory stats per product
class InventoryStats {
  final int stock;
  final int sold;

  const InventoryStats({this.stock = 0, this.sold = 0});

  Map<String, dynamic> toMap() => {'stock': stock, 'sold': sold};

  factory InventoryStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const InventoryStats();
    return InventoryStats(
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      sold: (map['sold'] as num?)?.toInt() ?? 0,
    );
  }

  InventoryStats copyWith({int? stock, int? sold}) {
    return InventoryStats(
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
    );
  }
}

/// Store model
class StoreModel {
  final String id;
  final String name;
  final String contactName;
  final String address;
  final double commissionRate; // percentage, e.g. 20 means 20%
  final int totalDelivered;
  final int totalSold;
  final double balance;
  final Map<String, InventoryStats> inventory; // key: product ID

  StoreModel({
    required this.id,
    required this.name,
    required this.contactName,
    required this.address,
    required this.commissionRate,
    this.totalDelivered = 0,
    this.totalSold = 0,
    this.balance = 0,
    Map<String, InventoryStats>? inventory,
  }) : inventory = inventory ?? {};

  int get totalStock =>
      inventory.values.fold(0, (sum, s) => sum + s.stock);

  /// Compute inventory value using a products map (productId -> ProductModel)
  double inventoryValueWith(Map<String, ProductModel> products) {
    double value = 0;
    inventory.forEach((productId, stats) {
      final product = products[productId];
      if (product != null) {
        value += stats.stock * product.price;
      }
    });
    return value;
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'contactName': contactName,
        'address': address,
        'commissionRate': commissionRate,
        'totalDelivered': totalDelivered,
        'totalSold': totalSold,
        'balance': balance,
        'inventory': inventory.map((k, v) => MapEntry(k, v.toMap())),
      };

  factory StoreModel.fromMap(String id, Map<String, dynamic> map) {
    final invMap = map['inventory'] as Map<String, dynamic>? ?? {};
    final inventory = <String, InventoryStats>{};
    invMap.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        inventory[key] = InventoryStats.fromMap(value);
      }
    });

    return StoreModel(
      id: id,
      name: map['name'] ?? '',
      contactName: map['contactName'] ?? '',
      address: map['address'] ?? '',
      commissionRate: (map['commissionRate'] as num?)?.toDouble() ?? 20,
      totalDelivered: (map['totalDelivered'] as num?)?.toInt() ?? 0,
      totalSold: (map['totalSold'] as num?)?.toInt() ?? 0,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      inventory: inventory,
    );
  }

  StoreModel copyWith({
    String? name,
    String? contactName,
    String? address,
    double? commissionRate,
    int? totalDelivered,
    int? totalSold,
    double? balance,
    Map<String, InventoryStats>? inventory,
  }) {
    return StoreModel(
      id: id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      address: address ?? this.address,
      commissionRate: commissionRate ?? this.commissionRate,
      totalDelivered: totalDelivered ?? this.totalDelivered,
      totalSold: totalSold ?? this.totalSold,
      balance: balance ?? this.balance,
      inventory: inventory ?? this.inventory,
    );
  }
}

/// Transaction types
enum TransactionType { delivery, sale, payment }

/// Unified transaction model
class TransactionModel {
  final String id;
  final String storeId;
  final String storeName;
  final TransactionType type;
  final DateTime date;
  final double totalAmount;
  final String? note;
  final Map<String, int>? items; // key: product ID, value: quantity

  TransactionModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.type,
    required this.date,
    required this.totalAmount,
    this.note,
    this.items,
  });

  Map<String, dynamic> toMap() => {
        'storeId': storeId,
        'storeName': storeName,
        'type': type.name,
        'date': Timestamp.fromDate(date),
        'totalAmount': totalAmount,
        'note': note,
        'items': items,
      };

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    final itemsRaw = map['items'] as Map<String, dynamic>?;
    return TransactionModel(
      id: id,
      storeId: map['storeId'] ?? '',
      storeName: map['storeName'] ?? '',
      type: TransactionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TransactionType.delivery,
      ),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
      note: map['note'] as String?,
      items: itemsRaw?.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }
}
