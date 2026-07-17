import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_panel.dart';
import '../providers/pos_provider.dart';
import '../models/cart_item.dart';
import '../models/suspended_order.dart';
import '../models/transaction.dart';

class OrderPanel extends StatelessWidget {
  const OrderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(flex: 2, child: _OrderMainSection()),
        Container(height: 1, color: const Color(0xFF334155)),
        const Expanded(flex: 1, child: PaymentPanel()),
      ],
    );
  }
}

class _OrderMainSection extends StatelessWidget {
  const _OrderMainSection();

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

class _OrderHeader extends StatefulWidget {
  const _OrderHeader();

  @override
  State<_OrderHeader> createState() => _OrderHeaderState();
}

class _OrderHeaderState extends State<_OrderHeader> {
  bool _isParking = false;

  @override
  Widget build(BuildContext context) {
    final count = context.select<PosProvider, int>((p) => p.cartItemCount);
    final suspendedCount = context.select<PosProvider, int>(
      (p) => p.suspendedOrderCount,
    );
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
          if (suspendedCount > 0)
            TextButton.icon(
              key: const Key('saved-orders-button'),
              onPressed: () => _showSuspendedOrdersSheet(context),
              icon: const Icon(Icons.receipt_long_outlined, size: 16),
              label: Text('Saved ($suspendedCount)'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF38BDF8),
              ),
            ),
          if (count > 0)
            TextButton.icon(
              key: const Key('hold-order-button'),
              onPressed: _isParking ? null : _parkCurrentOrder,
              icon: const Icon(Icons.pause_circle_outline, size: 16),
              label: const Text('Hold'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF59E0B),
              ),
            ),
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

  Future<void> _parkCurrentOrder() async {
    if (_isParking) return;
    setState(() => _isParking = true);
    final provider = context.read<PosProvider>();
    try {
      final label = await _showHoldOrderDialog(context);
      if (!mounted || label == null) return;

      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      final order = await provider.parkCurrentOrder(customLabel: label);
      if (!mounted || order == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
          content: Text(
            '${order.orderLabel} saved for later. ${order.itemCount} item${order.itemCount == 1 ? '' : 's'} parked.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isParking = false);
      }
    }
  }

  Future<String?> _showHoldOrderDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => const _HoldOrderDialog(),
    );
  }

  void _showSuspendedOrdersSheet(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close saved orders panel',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const _SuspendedOrdersSheet(),
      transitionBuilder: (_, animation, _, child) {
        final slideTween = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        );
        return SlideTransition(
          position: animation.drive(
            slideTween.chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        );
      },
    );
  }
}

class _HoldOrderDialog extends StatefulWidget {
  const _HoldOrderDialog();

  @override
  State<_HoldOrderDialog> createState() => _HoldOrderDialogState();
}

class _HoldOrderDialogState extends State<_HoldOrderDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;

  static const List<List<String>> _keyboardRows = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '-', '/'],
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _appendKey(String key) {
    final current = _controller.text;
    _controller.value = TextEditingValue(
      text: current + key,
      selection: TextSelection.collapsed(offset: current.length + key.length),
    );
  }

  void _backspace() {
    final current = _controller.text;
    if (current.isEmpty) return;
    final updated = current.substring(0, current.length - 1);
    _controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: updated.length),
    );
  }

  void _insertSpace() {
    final current = _controller.text;
    if (current.isNotEmpty && current.endsWith(' ')) return;
    _controller.value = TextEditingValue(
      text: '$current ',
      selection: TextSelection.collapsed(offset: current.length + 1),
    );
  }

  void _clearText() {
    _controller.clear();
  }

  void _save() {
    if (_submitted) return;
    setState(() => _submitted = true);
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('hold-order-dialog'),
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Save Order', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 620,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a customer or order name. Leave blank to use an auto-number label.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Customer name / Table / Order name',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            ..._keyboardRows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: row
                      .map(
                        (key) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: _OnscreenKeyButton(
                              label: key,
                              onTap: () => _appendKey(key),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _OnscreenKeyButton(
                    label: 'Space',
                    onTap: _insertSpace,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _OnscreenKeyButton(
                    label: '⌫',
                    onTap: _backspace,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _OnscreenKeyButton(
                    label: 'Clear',
                    onTap: _clearText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _OnscreenKeyButton extends StatelessWidget {
  const _OnscreenKeyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 44,
        child: Material(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
    );
  }
}

class _SuspendedOrdersSheet extends StatelessWidget {
  const _SuspendedOrdersSheet();

  String _fmtTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = MediaQuery.sizeOf(context).width / 3;
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: const Color(0xFF1E293B),
        elevation: 12,
        child: SizedBox(
          key: const Key('saved-orders-panel'),
          width: panelWidth,
          height: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Consumer<PosProvider>(
                builder: (context, provider, _) {
                  final orders = provider.suspendedOrders;
                  final hasCurrentOrder = provider.cart.isNotEmpty;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Saved Orders',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      if (hasCurrentOrder)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Text(
                            'Hold or clear the current order before opening a saved one.',
                            style: TextStyle(
                              color: Color(0xFFFCD34D),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (orders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No saved orders yet.',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            itemCount: orders.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return _SuspendedOrderTile(
                                order: order,
                                timestampLabel: _fmtTime(order.updatedAt),
                                canResume: !hasCurrentOrder,
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuspendedOrderTile extends StatelessWidget {
  const _SuspendedOrderTile({
    required this.order,
    required this.timestampLabel,
    required this.canResume,
  });

  final SuspendedOrder order;
  final String timestampLabel;
  final bool canResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bookmark_outline,
                color: Color(0xFF38BDF8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.orderLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                timestampLabel,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${order.itemCount} item${order.itemCount == 1 ? '' : 's'} • \$${order.subtotal.toStringAsFixed(2)}'
            '${order.cashierName == null ? '' : ' • ${order.cashierName}'}',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final deleted = await context
                        .read<PosProvider>()
                        .deleteSuspendedOrder(order.id);
                    if (!context.mounted || !deleted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(12),
                        duration: Duration(seconds: 3),
                        content: Text('Saved order removed.'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                  ),
                  child: const Text('Delete'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: canResume
                      ? () async {
                          final resumed = await context
                              .read<PosProvider>()
                              .resumeSuspendedOrder(order.id);
                          if (!context.mounted || !resumed) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(12),
                              duration: Duration(seconds: 3),
                              content: Text('Saved order loaded back into Current Order.'),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Resume'),
                ),
              ),
            ],
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
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Color(0xFF334155),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No items added',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tap a product to add it',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                        ),
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
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF59E0B),
            size: 16,
          ),
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
              child: Text(
                item.product.emoji,
                style: const TextStyle(fontSize: 20),
              ),
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
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
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

  String _cashDenominationLabel(double amount) {
    if (amount < 1) {
      return '${(amount * 100).round()}¢';
    }
    if (amount == amount.truncateToDouble()) {
      return '\$${amount.toInt()}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    final selectedTender = provider.selectedPaymentMode;
    final amountTotal = provider.total;
    final amountDue = provider.amountDueDraft;
    final change = provider.cashChangeDraft;
    final cashTenderLines = provider.cashTenderLinesDraft;
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
          const Divider(color: Color(0xFF334155), height: 18),
          Row(
            children: [
              const Text(
                'Tender',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${selectedTender.emoji} ${selectedTender.label}',
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (selectedTender == TenderType.cash && cashTenderLines.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...cashTenderLines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _CashTenderRow(
                  label: '${_cashDenominationLabel(line.key)} x ${line.value}',
                  amount: line.key * line.value,
                  onRemove: () =>
                      context.read<PosProvider>().removeCashDenominationDraft(
                        line.key,
                      ),
                  removeKey: Key('remove-tender-${line.key}'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          _SummaryRow('Amount Total', amountTotal),
          const SizedBox(height: 4),
          _SummaryRow(
            'Amount Due',
            amountDue,
            valueColor: const Color(0xFF22C55E),
            bold: true,
          ),
          if (selectedTender == TenderType.cash &&
              provider.cashTenderedDraft > 0) ...[
            const SizedBox(height: 4),
            _SummaryRow(
              'Change',
              change,
              valueColor: const Color(0xFF22C55E),
              bold: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.label,
    this.amount, {
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final double amount;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _CashTenderRow extends StatelessWidget {
  const _CashTenderRow({
    required this.label,
    required this.amount,
    required this.onRemove,
    required this.removeKey,
  });

  final String label;
  final double amount;
  final VoidCallback onRemove;
  final Key removeKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const Spacer(),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          key: removeKey,
          onTap: onRemove,
          child: const Icon(Icons.close, color: Color(0xFF64748B), size: 16),
        ),
      ],
    );
  }
}
