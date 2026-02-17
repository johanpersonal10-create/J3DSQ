// Cobros screen — Select a store and register a cobro
// J3D SQ ERP

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../helpers/alerts.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

final _cur = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

class CobrosScreen extends StatelessWidget {
  const CobrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final stores = state.stores;
    final pm = state.productsMap;

    // Only show stores that have inventory
    final storesWithStock =
        stores.where((s) => s.totalStock > 0).toList();
    final storesEmpty =
        stores.where((s) => s.totalStock == 0).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Cobros')),
      body: stores.isEmpty
          ? _emptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.point_of_sale_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Registrar Cobro',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${storesWithStock.length} tienda${storesWithStock.length == 1 ? '' : 's'} con inventario',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Stores with stock
                if (storesWithStock.isNotEmpty) ...[
                  _sectionLabel('Selecciona una tienda'),
                  const SizedBox(height: 10),
                  ...storesWithStock.map(
                      (s) => _StoreCobroCard(store: s, productsMap: pm)),
                ],

                // Stores without stock
                if (storesEmpty.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionLabel('Sin inventario'),
                  const SizedBox(height: 10),
                  ...storesEmpty.map(
                      (s) => _StoreCobroCard(store: s, productsMap: pm)),
                ],
              ],
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.store_rounded,
              size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'No hay tiendas registradas',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Agrega tiendas en la sección Tiendas',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

// ─── Store Card for Cobro ─────────────────────────────────────

class _StoreCobroCard extends StatelessWidget {
  final StoreModel store;
  final Map<String, ProductModel> productsMap;
  const _StoreCobroCard({required this.store, required this.productsMap});

  @override
  Widget build(BuildContext context) {
    final hasStock = store.totalStock > 0;
    final invValue = store.inventoryValueWith(productsMap);

    return GestureDetector(
      onTap: hasStock
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _CobroFlowScreen(
                      store: store, productsMap: productsMap),
                ),
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasStock
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Store icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasStock
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.border.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.storefront_rounded,
                color:
                    hasStock ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Store info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: hasStock
                          ? AppColors.text
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _miniChip(Icons.inventory_2_rounded,
                          '${store.totalStock} pzas', AppColors.primary),
                      const SizedBox(width: 8),
                      if (hasStock)
                        _miniChip(Icons.attach_money_rounded,
                            _cur.format(invValue), AppColors.success),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            if (hasStock)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.primary),
              ),
            if (!hasStock)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sin stock',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

// ─── Cobro Flow Screen (full-page for selected store) ─────────

class _CobroFlowScreen extends StatefulWidget {
  final StoreModel store;
  final Map<String, ProductModel> productsMap;
  const _CobroFlowScreen(
      {required this.store, required this.productsMap});

  @override
  State<_CobroFlowScreen> createState() => _CobroFlowScreenState();
}

class _CobroFlowScreenState extends State<_CobroFlowScreen> {
  late Map<String, TextEditingController> _controllers;
  bool _showSummary = false;

  Map<String, int> _soldByProduct = {};
  double _totalSale = 0;
  double _commission = 0;
  double _toReceive = 0;

  StoreModel get _store => widget.store;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final entry in _store.inventory.entries) {
      if (entry.value.stock > 0) {
        _controllers[entry.key] =
            TextEditingController(text: '${entry.value.stock}');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    final inv = _store.inventory;
    _soldByProduct = {};
    _totalSale = 0;

    for (final entry in _controllers.entries) {
      final productId = entry.key;
      final prevStock = inv[productId]?.stock ?? 0;
      final current = int.tryParse(entry.value.text) ?? prevStock;

      if (current > prevStock) {
        showWarning(context,
            'La existencia no puede ser mayor al stock registrado');
        return;
      }
      if (current < 0) {
        showWarning(context, 'La existencia no puede ser negativa');
        return;
      }

      final soldQty = prevStock - current;
      if (soldQty > 0) {
        _soldByProduct[productId] = soldQty;
        final product = widget.productsMap[productId];
        _totalSale += soldQty * (product?.price ?? 0);
      }
    }

    if (_soldByProduct.isEmpty) {
      showWarning(context, 'No hay ventas registradas — las existencias no cambiaron');
      return;
    }

    setState(() {
      _commission = _totalSale * (_store.commissionRate / 100);
      _toReceive = _totalSale - _commission;
      _showSummary = true;
    });
  }

  void _confirm() async {
    final currentStock = <String, int>{};
    for (final entry in _controllers.entries) {
      currentStock[entry.key] = int.tryParse(entry.value.text) ?? 0;
    }

    try {
      await context.read<AppState>().registerSale(
            store: _store,
            currentStock: currentStock,
          );

      if (mounted) {
        Navigator.pop(context);
        showSuccess(context,
            'Cobro de \$${_toReceive.toStringAsFixed(2)} registrado');
      }
    } catch (e) {
      if (mounted) {
        showError(context, 'Error al registrar cobro: $e');
      }
    }
  }

  int get _totalSold =>
      _soldByProduct.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_store.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Store info header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_store.contactName,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(
                          'Comisión ${_store.commissionRate.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_store.balance > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Saldo: ${_cur.format(_store.balance)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Instruction
            const Text(
              'Ingresa las piezas que QUEDAN en existencia',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'El sistema calculará automáticamente cuánto se vendió',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Product inputs
            ..._controllers.entries.map((entry) {
              final productId = entry.key;
              final product = widget.productsMap[productId];
              final color = product != null
                  ? Color(product.colorValue)
                  : AppColors.textSecondary;
              final label = product?.name ?? 'Producto';
              final stock = _store.inventory[productId]?.stock ?? 0;
              final price = product?.price ?? 0;

              return _ProductExistenciaCard(
                label: label,
                color: color,
                stockEsperado: stock,
                pricePerUnit: price,
                controller: entry.value,
                onChanged: () {
                  if (_showSummary) setState(() => _showSummary = false);
                },
              );
            }),

            const SizedBox(height: 20),

            // Calculate button
            if (!_showSummary)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate_rounded),
                  label: const Text('Calcular Cobro',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

            // Summary
            if (_showSummary) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B894).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Resumen del Cobro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Each product sold
                    ..._soldByProduct.entries.map((e) {
                      final product = widget.productsMap[e.key];
                      final name = product?.name ?? '?';
                      final price = product?.price ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${e.value} × \$${price.toStringAsFixed(0)} ($name)',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                            Text(
                              _cur.format(e.value * price),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(color: Colors.white30, height: 24),

                    _summaryRow('Venta Total', _cur.format(_totalSale)),
                    _summaryRow(
                      'Comisión (${_store.commissionRate.toStringAsFixed(1)}%)',
                      '-${_cur.format(_commission)}',
                      dim: true,
                    ),

                    const Divider(color: Colors.white30, height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'A Cobrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _cur.format(_toReceive),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_totalSold unidad${_totalSold == 1 ? '' : 'es'} vendida${_totalSold == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _showSummary = false),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Modificar'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _totalSold > 0 ? _confirm : null,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Confirmar Cobro',
                          style: TextStyle(fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool dim = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: dim ? Colors.white60 : Colors.white)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dim ? Colors.white60 : Colors.white)),
        ],
      ),
    );
  }
}

// ─── Product Existencia Input Card ─────────────────────────────

class _ProductExistenciaCard extends StatelessWidget {
  final String label;
  final Color color;
  final int stockEsperado;
  final double pricePerUnit;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _ProductExistenciaCard({
    required this.label,
    required this.color,
    required this.stockEsperado,
    required this.pricePerUnit,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with product name
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Text(
                  '\$${pricePerUnit.toStringAsFixed(0)} c/u',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Input area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Expected stock
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Debería haber',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$stockEsperado piezas',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: AppColors.textSecondary, size: 20),
                ),
                // Actual input
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Hay realmente',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: color.withOpacity(0.4)),
                        ),
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (_) => onChanged(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                          decoration: const InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
