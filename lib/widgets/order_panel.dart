import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/cart_item.dart';

class OrderPanel extends StatelessWidget {
  const OrderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _OrderHeader(),
        Expanded(child: _CartList()),
        _OrderFooter(),
      ],
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader();

  @override
  Widget build(BuildContext context) {
    final count = context.select<PosProvider, int>((p) => p.cartItemCount);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFF1E293B),
      child: Row(
        children: [
          const Text(
            'Current Order',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Spacer(),
          if (count > 0)
            TextButton(
              onPressed: () => context.read<PosProvider>().clearCart(),
              child: const Text(
                'Clear',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  const _CartList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    final cart = provider.cart;
    final hasShift = provider.hasActiveShift;
    final hasDay = provider.hasActiveBusinessDay;

    return Column(
      children: [
        if (!hasShift) _NoShiftBanner(hasDay: hasDay),
        Expanded(
          child: cart.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 64, color: Color(0xFF334155)),
                      SizedBox(height: 16),
                      Text(
                        'No items added',
                        style:
                            TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tap a product to add it',
                        style:
                            TextStyle(color: Color(0xFF475569), fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _CartItemTile(item: cart[i]),
                ),
        ),
      ],
    );
  }
}

class _NoShiftBanner extends StatelessWidget {
  const _NoShiftBanner({required this.hasDay});
  final bool hasDay;

  @override
  Widget build(BuildContext context) {
    final msg = hasDay
        ? 'No active shift — open a shift in System Info to accept orders'
        : 'Business day is closed — open the day in System Info';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFF59E0B), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                color: Color(0xFFF59E0B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PosProvider>();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.product.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(item.product.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QtyButton(
                icon: Icons.remove,
                onTap: () => provider.adjustQuantity(item.product.id, -1),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _QtyButton(
                icon: Icons.add,
                onTap: () => provider.adjustQuantity(item.product.id, 1),
              ),
            ],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            child: Text(
              '\$${item.total.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF14B8A6),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => provider.removeFromCart(item.product.id),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, color: Color(0xFF64748B), size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _OrderFooter extends StatelessWidget {
  const _OrderFooter();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Color(0xFF334155))),
      ),
      child: Column(
        children: [
          _SummaryRow('Subtotal', provider.subtotal),
          const SizedBox(height: 6),
          _SummaryRow('Tax (10%)', provider.tax),
          const Divider(color: Color(0xFF334155), height: 20),
          Row(
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '\$${provider.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF14B8A6),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.amount);

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        const Spacer(),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}
