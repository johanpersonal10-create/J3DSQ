// Stores list screen with CRUD

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'store_detail_screen.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Tiendas')),
          body: state.stores.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store_outlined,
                          size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'No hay tiendas registradas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Toca el botón + para agregar una',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: state.stores.length,
                  itemBuilder: (context, i) {
                    final store = state.stores[i];
                    return _StoreCard(store: store);
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showStoreForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nueva'),
          ),
        );
      },
    );
  }

  void _showStoreForm(BuildContext context, {StoreModel? store}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _StoreFormSheet(store: store),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreModel store;
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoreDetailScreen(storeId: store.id),
        ),
      ),
      onLongPress: () => _showActions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.store_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${store.contactName} · Comisión ${store.commissionRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniChip(
                      label: '${store.totalStock}',
                      color: AppColors.primary,
                      icon: Icons.inventory_2_rounded,
                    ),
                    const SizedBox(width: 6),
                    _MiniChip(
                      label: '${store.totalSold}',
                      color: AppColors.success,
                      icon: Icons.sell_rounded,
                    ),
                  ],
                ),
                if (store.balance > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    '\$${store.balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showActions(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_vert_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
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
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => _StoreFormSheet(store: store),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_rounded, color: AppColors.danger),
              title: const Text('Eliminar',
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Tienda'),
        content: Text(
            '¿Estás seguro de eliminar "${store.name}"? Se borrará todo su inventario y transacciones.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteStore(store.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _MiniChip(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreFormSheet extends StatefulWidget {
  final StoreModel? store;
  const _StoreFormSheet({this.store});

  @override
  State<_StoreFormSheet> createState() => _StoreFormSheetState();
}

class _StoreFormSheetState extends State<_StoreFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _commissionCtrl;

  bool get isEditing => widget.store != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.store?.name ?? '');
    _contactCtrl =
        TextEditingController(text: widget.store?.contactName ?? '');
    _addressCtrl = TextEditingController(text: widget.store?.address ?? '');
    _commissionCtrl = TextEditingController(
        text: widget.store != null
            ? widget.store!.commissionRate.toStringAsFixed(
                widget.store!.commissionRate.truncateToDouble() ==
                        widget.store!.commissionRate
                    ? 0
                    : 1)
            : '20');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              isEditing ? 'Editar Tienda' : 'Nueva Tienda',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            const Text('Nombre',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(hintText: 'Ej. Abarrotes La Esquina'),
            ),
            const SizedBox(height: 16),

            const Text('Contacto',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _contactCtrl,
              decoration: const InputDecoration(hintText: 'Ej. Don Pepe'),
            ),
            const SizedBox(height: 16),

            const Text('Dirección',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtrl,
              decoration:
                  const InputDecoration(hintText: 'Ej. Av. Siempre Viva 123'),
            ),
            const SizedBox(height: 20),

            const Text('Comisión de Tienda (%)',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _commissionCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Ej. 20',
                suffixText: '%',
                suffixStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                child: Text(isEditing ? 'Guardar Cambios' : 'Crear Tienda'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _handleSave() async {
    final name = _nameCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final commission = double.tryParse(_commissionCtrl.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }

    if (commission == null || commission < 0 || commission > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La comisión debe ser un número entre 0 y 100')),
      );
      return;
    }

    final state = context.read<AppState>();
    if (isEditing) {
      await state.updateStore(
        widget.store!.id,
        name: name,
        contactName: contact,
        address: address,
        commissionRate: commission,
      );
    } else {
      await state.addStore(
        name: name,
        contactName: contact,
        address: address,
        commissionRate: commission,
      );
    }
    if (mounted) Navigator.pop(context);
  }
}
