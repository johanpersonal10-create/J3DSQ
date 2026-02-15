// Finances screen with dynamic products

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  String _range = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final txs = _filteredTransactions(state.transactions);

        // Totals
        double totalIncome = 0;
        double totalExpenses = 0;
        for (final tx in txs) {
          if (tx.type == TransactionType.sale) {
            totalIncome += tx.totalAmount;
          } else if (tx.type == TransactionType.delivery) {
            // Estimate production costs
            tx.items?.forEach((productId, qty) {
              final product = state.getProductById(productId);
              if (product != null) {
                totalExpenses += product.productionCost * qty;
              }
            });
          }
        }
        final netProfit = totalIncome - totalExpenses;

        return Scaffold(
          appBar: AppBar(title: const Text('Finanzas')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time range filter
                _TimeRangeFilter(
                  selected: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
                const SizedBox(height: 20),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Ingresos',
                        value: '\$${totalIncome.toStringAsFixed(0)}',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Costos',
                        value: '\$${totalExpenses.toStringAsFixed(0)}',
                        icon: Icons.trending_down_rounded,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SummaryCard(
                  label: 'Ganancia Neta',
                  value: '\$${netProfit.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: netProfit >= 0 ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(height: 24),

                // Per-store performance
                _StorePerformanceSection(
                  stores: state.stores,
                  transactions: txs,
                  productsMap: state.productsMap,
                ),
                const SizedBox(height: 24),

                // Transaction history
                _CollapsibleHistory(
                  transactions: txs,
                  productsMap: state.productsMap,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<TransactionModel> _filteredTransactions(List<TransactionModel> all) {
    final now = DateTime.now();
    switch (_range) {
      case 'Hoy':
        return all.where((t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day).toList();
      case 'Semana':
        final start = now.subtract(const Duration(days: 7));
        return all.where((t) => t.date.isAfter(start)).toList();
      case 'Mes':
        final start = now.subtract(const Duration(days: 30));
        return all.where((t) => t.date.isAfter(start)).toList();
      default:
        return all;
    }
  }
}

class _TimeRangeFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _TimeRangeFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Hoy', 'Semana', 'Mes', 'Todos'].map((r) {
        final isSelected = selected == r;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                r,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Per-Store Performance ─────────────────────────────────

class _StorePerformanceSection extends StatelessWidget {
  final List<StoreModel> stores;
  final List<TransactionModel> transactions;
  final Map<String, ProductModel> productsMap;

  const _StorePerformanceSection({
    required this.stores,
    required this.transactions,
    required this.productsMap,
  });

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rendimiento por Tienda',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        ...stores.map((store) {
          // Calculate income and expenses for this store
          double storeIncome = 0;
          double storeExpenses = 0;

          for (final tx in transactions) {
            if (tx.storeId != store.id) continue;
            if (tx.type == TransactionType.sale) {
              storeIncome += tx.totalAmount;
            } else if (tx.type == TransactionType.delivery) {
              tx.items?.forEach((productId, qty) {
                final product = productsMap[productId];
                if (product != null) {
                  storeExpenses += product.productionCost * qty;
                }
              });
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Ingreso: \$${storeIncome.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(storeIncome - storeExpenses).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      'Costo: \$${storeExpenses.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Collapsible History ───────────────────────────────────

class _CollapsibleHistory extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Map<String, ProductModel> productsMap;
  const _CollapsibleHistory({
    required this.transactions,
    required this.productsMap,
  });

  @override
  State<_CollapsibleHistory> createState() => _CollapsibleHistoryState();
}

class _CollapsibleHistoryState extends State<_CollapsibleHistory> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Historial Reciente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.transactions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1, color: AppColors.border),
                if (widget.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Sin transacciones en este período',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...widget.transactions.take(30).map((tx) =>
                      _TransactionTile(tx: tx, productsMap: widget.productsMap)),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final Map<String, ProductModel> productsMap;
  const _TransactionTile({required this.tx, required this.productsMap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM · HH:mm', 'es').format(tx.date);
    final isPayment = tx.type == TransactionType.payment;
    final isDelivery = tx.type == TransactionType.delivery;

    IconData icon;
    Color color;
    String prefix;

    if (isPayment) {
      icon = Icons.payments_rounded;
      color = AppColors.primary;
      prefix = '+';
    } else if (isDelivery) {
      icon = Icons.inventory_2_rounded;
      color = AppColors.textSecondary;
      prefix = '';
    } else {
      icon = Icons.point_of_sale_rounded;
      color = AppColors.success;
      prefix = '+';
    }

    return GestureDetector(
      onLongPress: () => _showDeleteOption(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.storeName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (tx.note != null && tx.note!.isNotEmpty)
                    Text(
                      tx.note!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$prefix\$${tx.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDelivery ? AppColors.textSecondary : color,
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.delete_rounded, color: AppColors.danger),
              title: const Text('Eliminar Transacción',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    String message;
    switch (tx.type) {
      case TransactionType.delivery:
        message = 'Se revertirá el stock entregado a "${tx.storeName}".';
        break;
      case TransactionType.sale:
        message =
            'Se revertirán las ventas y el saldo pendiente de "${tx.storeName}".';
        break;
      case TransactionType.payment:
        message =
            'Se revertirá el pago al saldo pendiente de "${tx.storeName}".';
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Transacción'),
        content: Text('$message ¿Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteTransaction(tx);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transacción eliminada'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
