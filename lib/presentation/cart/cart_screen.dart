import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isOrdering = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: cart.items.isEmpty ? _buildEmptyState(context) : _buildCart(context, cart),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(fontSize: 20, color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega productos para continuar',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.products),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Ver Productos'),
          ),
        ],
      ),
    );
  }

  Widget _buildCart(BuildContext context, cart) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (_, i) {
              final item = cart.items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.darkGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: item.imagenUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.imagenUrl!,
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.inventory,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.inventory, color: AppColors.gold),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nombre,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.darkGrey,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => cart.updateQuantity(
                                              item.productId, item.cantidad - 1),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(
                                              Icons.remove,
                                              color: AppColors.gold,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            '${item.cantidad}',
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => cart.updateQuantity(
                                              item.productId, item.cantidad + 1),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(
                                              Icons.add,
                                              color: AppColors.gold,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '\$${item.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              iconSize: 20,
                              onPressed: () => cart.removeItem(item.productId),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.card,
            boxShadow: [
              BoxShadow(
                color: AppColors.black,
                blurRadius: 8,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  Text(
                    '\$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutes.products),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Seguir Comprando'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        side: const BorderSide(color: AppColors.gold),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isOrdering ? null : () => _showPaymentSheet(context, cart),
                      icon: _isOrdering
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(_isOrdering ? 'Procesando...' : 'Confirmar Pedido'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPaymentSheet(BuildContext context, cart) {
    final refCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String? selectedMethod;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20, right: 20, top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 16),
                    if (selectedMethod == null) ...[
                      const Text('Selecciona método de pago', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _paymentOptionBtn(ctx, setSheetState,
                        icon: Icons.money,
                        label: 'Efectivo',
                        subtitle: 'Paga al recibir el pedido',
                        value: 'Efectivo',
                        onSelected: () => setSheetState(() => selectedMethod = 'Efectivo'),
                      ),
                      const SizedBox(height: 12),
                      _paymentOptionBtn(ctx, setSheetState,
                        icon: Icons.account_balance,
                        label: 'Yape / Transferencia',
                        subtitle: 'Paga con Yape o transferencia bancaria',
                        value: 'Yape',
                        onSelected: () => setSheetState(() => selectedMethod = 'Yape'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
                      ),
                    ] else if (selectedMethod == 'Efectivo') ...[
                      const Text('Pago en Efectivo', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Pagas al recibir tu pedido', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                      const SizedBox(height: 24),
                      const Icon(Icons.money, color: AppColors.gold, size: 56),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmOrder(cart, 'Efectivo', null, ctx),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Confirmar Pago en Efectivo'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setSheetState(() => selectedMethod = null),
                        child: const Text('Cambiar método', style: TextStyle(color: AppColors.grey)),
                      ),
                    ] else ...[
                      const Text('Yape / Transferencia', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Ingresa el número de operación después de realizar el pago', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.account_balance, color: AppColors.gold),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'BCP: 123-456789-0-00\nYape: 987 654 321',
                                style: TextStyle(color: AppColors.white, fontSize: 13),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.content_copy, color: AppColors.gold, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: refCtrl,
                        style: const TextStyle(color: AppColors.white),
                        decoration: InputDecoration(
                          labelText: 'Número de operación',
                          labelStyle: const TextStyle(color: AppColors.grey),
                          hintText: 'Ej: 00012345',
                          hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: AppColors.darkGrey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.gold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final op = refCtrl.text.trim();
                            if (op.isEmpty) {
                              showAppSnackBar(ctx, 'Ingresa el número de operación', type: SnackType.error);
                              return;
                            }
                            _confirmOrder(cart, 'Yape / Transferencia', {'numero_operacion': op}, ctx);
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Confirmar Pago'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => selectedMethod = null);
                          refCtrl.clear();
                        },
                        child: const Text('Cambiar método', style: TextStyle(color: AppColors.grey)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _paymentOptionBtn(BuildContext ctx, StateSetter setSheetState, {required IconData icon, required String label, required String subtitle, required String value, required VoidCallback onSelected}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onSelected,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.gold),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder(CartProvider cart, String paymentMethod, Map<String, dynamic>? paymentDetails, BuildContext sheetCtx) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      showAppSnackBar(context, 'Debes iniciar sesión', type: SnackType.error);
      return;
    }

    setState(() => _isOrdering = true);
    Navigator.pop(sheetCtx);

    final repo = OrderRepository();
    final firestore = FirebaseFirestore.instance;
    final orderId = firestore.collection('orders').doc().id;

    final order = OrderModel(
      id: orderId,
      userId: auth.user!.id,
      userName: auth.user!.nombre,
      items: cart.items.map((item) => OrderItem(
        productId: item.productId,
        nombre: item.nombre,
        precio: item.precio,
        cantidad: item.cantidad,
        imagenUrl: item.imagenUrl,
      )).toList(),
      total: cart.total,
      paymentMethod: paymentMethod,
      paymentDetails: paymentDetails,
    );

    try {
      await repo.createOrder(order).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      cart.clearCart();
      setState(() => _isOrdering = false);
      showAppSnackBar(context, 'Pedido confirmado con $paymentMethod', type: SnackType.success);
      context.go(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isOrdering = false);
      showAppSnackBar(context, 'Error al procesar el pedido', type: SnackType.error);
    }
  }
}
