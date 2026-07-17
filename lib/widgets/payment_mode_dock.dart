import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/pos_provider.dart';

class PaymentModeDock extends StatelessWidget {
  const PaymentModeDock({super.key});

  static const _modeIcons = <TenderType, IconData>{
    TenderType.cash: Icons.payments_outlined,
    TenderType.card: Icons.credit_card,
    TenderType.voucher: Icons.qr_code_2_outlined,
  };

  static const _modeColors = <TenderType, Color>{
    TenderType.cash: Color(0xFF22C55E),
    TenderType.card: Color(0xFF14B8A6),
    TenderType.voucher: Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    final selected = provider.selectedPaymentMode;
    final showHistory = provider.showPaymentHistory;
    final modes = provider.paymentModes;

    return Container(
      height: 58,
      color: const Color(0xFF1E293B),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: modes.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == modes.length) {
            return _HistoryDockItem(
              selected: showHistory,
              onTap: provider.showPaymentHistoryView,
            );
          }

          final mode = modes[i];
          final isActive = !showHistory && mode == selected;
          final color = _modeColors[mode]!;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              key: Key('payment-mode-${mode.name}'),
              borderRadius: BorderRadius.circular(10),
              onTap: () => provider.selectPaymentMode(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? color.withValues(alpha: 0.18)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? color : const Color(0xFF334155),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _modeIcons[mode],
                      color: isActive ? color : const Color(0xFF94A3B8),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mode.label,
                      style: TextStyle(
                        color: isActive ? color : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

class _HistoryDockItem extends StatelessWidget {
  const _HistoryDockItem({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF38BDF8);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('payment-mode-history'),
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.18) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : const Color(0xFF334155),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                color: selected ? color : const Color(0xFF94A3B8),
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                'History',
                style: TextStyle(
                  color: selected ? color : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
