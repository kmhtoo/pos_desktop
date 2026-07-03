import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/pos_provider.dart';

class PaymentModeDock extends StatelessWidget {
  const PaymentModeDock({super.key});

  static const _modeIcons = <TenderType, IconData>{
    TenderType.cash: Icons.payments_outlined,
    TenderType.card: Icons.credit_card,
    TenderType.split: Icons.call_split,
    TenderType.voucher: Icons.qr_code_2_outlined,
  };

  static const _modeColors = <TenderType, Color>{
    TenderType.cash: Color(0xFF22C55E),
    TenderType.card: Color(0xFF14B8A6),
    TenderType.split: Color(0xFFF59E0B),
    TenderType.voucher: Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    final selected = provider.selectedPaymentMode;
    final modes = provider.paymentModes;
    final canInteract = !provider.cartIsEmpty;

    return Container(
      height: 58,
      color: const Color(0xFF1E293B),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: modes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final mode = modes[i];
          final isActive = mode == selected;
          final color = _modeColors[mode]!;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              key: Key('payment-mode-${mode.name}'),
              borderRadius: BorderRadius.circular(10),
              onTap: canInteract
                  ? () => provider.selectPaymentMode(mode)
                  : null,
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
                      color: canInteract
                          ? (isActive ? color : const Color(0xFF94A3B8))
                          : const Color(0xFF64748B),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mode.label,
                      style: TextStyle(
                        color: canInteract
                            ? (isActive ? color : const Color(0xFF94A3B8))
                            : const Color(0xFF64748B),
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
