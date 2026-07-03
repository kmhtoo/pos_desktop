import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/shift.dart';

class SystemScreen extends StatelessWidget {
  const SystemScreen({super.key});

  String _fmt(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text(
          'System Info',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF334155)),
        ),
      ),
      body: Consumer<PosProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionLabel(label: 'BUSINESS DAY'),
              const SizedBox(height: 8),
              _BusinessDayCard(provider: provider, fmt: _fmt),
              const SizedBox(height: 20),
              _SectionLabel(label: 'CURRENT SHIFT'),
              const SizedBox(height: 8),
              _ShiftCard(provider: provider, fmt: _fmt),
              const SizedBox(height: 20),
              _SectionLabel(label: 'APP SETTINGS'),
              const SizedBox(height: 8),
              _AppSettingsCard(provider: provider),
              if (provider.todayShifts.any((s) => !s.isOpen)) ...[
                const SizedBox(height: 20),
                _SectionLabel(label: "TODAY'S SHIFTS"),
                const SizedBox(height: 8),
                ...provider.todayShifts
                    .where((s) => !s.isOpen)
                    .map(
                      (s) => _PastShiftTile(
                        shift: s,
                        receiptCount: provider.shiftReceiptCountFor(s.id),
                        totalSales: provider.shiftTotalSalesFor(s.id),
                        fmt: _fmt,
                      ),
                    ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _BusinessDayCard extends StatelessWidget {
  const _BusinessDayCard({required this.provider, required this.fmt});
  final PosProvider provider;
  final String Function(DateTime) fmt;

  @override
  Widget build(BuildContext context) {
    final bd = provider.currentBusinessDay;
    final isOpen = provider.hasActiveBusinessDay;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpen ? const Color(0xFF14B8A6) : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOpen
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isOpen ? 'OPEN' : 'CLOSED',
                style: TextStyle(
                  color: isOpen
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (bd != null)
                Text(
                  bd.id,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (bd == null)
            const Text(
              'No business day open',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            )
          else ...[
            _InfoRow(
              label: 'Opened',
              value: '${fmt(bd.openedAt)} by ${bd.openedByName}',
            ),
            if (!isOpen && bd.closedAt != null)
              _InfoRow(
                label: 'Closed',
                value: '${fmt(bd.closedAt!)} by ${bd.closedByName ?? '—'}',
              ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: isOpen
                ? OutlinedButton.icon(
                    onPressed: () => _confirmCloseDay(context, provider),
                    icon: const Icon(Icons.lock_outline, size: 16),
                    label: const Text('Close Business Day'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _confirmOpenDay(context, provider),
                    icon: const Icon(Icons.lock_open, size: 16),
                    label: const Text('Open Business Day'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmOpenDay(BuildContext context, PosProvider provider) {
    final user = provider.currentUser;
    if (user == null) return;
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Open Business Day?',
        icon: Icons.store_outlined,
        iconColor: const Color(0xFF14B8A6),
        message:
            'This will start a new business day. Any previous session data will be cleared.',
        confirmLabel: 'Open Day',
        confirmColor: const Color(0xFF14B8A6),
        onConfirm: () => provider.openBusinessDay(user),
      ),
    );
  }

  void _confirmCloseDay(BuildContext context, PosProvider provider) {
    final user = provider.currentUser;
    if (user == null) return;
    if (provider.hasActiveShift) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Close the active shift before closing the business day.',
          ),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Close Business Day?',
        icon: Icons.lock_outline,
        iconColor: const Color(0xFFEF4444),
        message:
            'The business day will be closed. No further orders can be taken until a new day is opened.',
        confirmLabel: 'Close Day',
        confirmColor: const Color(0xFFEF4444),
        onConfirm: () => provider.closeBusinessDay(user),
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.provider, required this.fmt});
  final PosProvider provider;
  final String Function(DateTime) fmt;

  @override
  Widget build(BuildContext context) {
    final shift = provider.currentShift;
    final hasDay = provider.hasActiveBusinessDay;
    final hasShift = provider.hasActiveShift;
    final available = provider.availableShiftTypes;

    if (!hasDay) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF64748B), size: 18),
            SizedBox(width: 10),
            Text(
              'Open a business day first',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasShift ? const Color(0xFF14B8A6) : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shift != null) ...[
            Row(
              children: [
                Text(shift.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      hasShift ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        color: hasShift
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Opened',
              value: '${fmt(shift.openedAt)} by ${shift.openedByName}',
            ),
            if (!hasShift && shift.closedAt != null)
              _InfoRow(
                label: 'Closed',
                value:
                    '${fmt(shift.closedAt!)} by ${shift.closedByName ?? '—'}',
              ),
            _InfoRow(
              label: 'Receipts',
              value:
                  '${provider.shiftReceiptCount} · \$${provider.shiftTotalSales.toStringAsFixed(2)}',
            ),
          ],
          if (!hasShift) ...[
            if (shift != null) const SizedBox(height: 14),
            if (available.isEmpty)
              const Text(
                'All shifts for today have been completed.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              )
            else ...[
              if (shift == null)
                const Text(
                  'No active shift',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 10),
              const Text(
                'Open a new shift:',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: available.map((type) {
                  return ElevatedButton.icon(
                    onPressed: () => _confirmOpenShift(context, provider, type),
                    icon: Text(
                      type.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    label: Text(type.label),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
          if (hasShift) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCloseShift(context, provider, shift!),
                icon: const Icon(Icons.stop_circle_outlined, size: 16),
                label: const Text('Close Shift'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmOpenShift(
    BuildContext context,
    PosProvider provider,
    ShiftType type,
  ) {
    final user = provider.currentUser;
    if (user == null) return;
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Open ${type.label} Shift?',
        icon: Icons.schedule,
        iconColor: const Color(0xFF14B8A6),
        message:
            'Start the ${type.label} shift. Orders can be taken once the shift is open.',
        confirmLabel: 'Open Shift',
        confirmColor: const Color(0xFF14B8A6),
        onConfirm: () => provider.openShift(type, user),
      ),
    );
  }

  void _confirmCloseShift(
    BuildContext context,
    PosProvider provider,
    Shift shift,
  ) {
    final user = provider.currentUser;
    if (user == null) return;
    final count = provider.shiftReceiptCount;
    final total = provider.shiftTotalSales;
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Close ${provider.currentShift!.name} Shift?',
        icon: Icons.stop_circle_outlined,
        iconColor: const Color(0xFFEF4444),
        message:
            '$count receipt${count != 1 ? 's' : ''} · \$${total.toStringAsFixed(2)} total\n\nNo orders can be taken after closing.',
        confirmLabel: 'Close Shift',
        confirmColor: const Color(0xFFEF4444),
        onConfirm: () => provider.closeShift(user),
      ),
    );
  }
}

class _PastShiftTile extends StatelessWidget {
  const _PastShiftTile({
    required this.shift,
    required this.receiptCount,
    required this.totalSales,
    required this.fmt,
  });

  final Shift shift;
  final int receiptCount;
  final double totalSales;
  final String Function(DateTime) fmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Text(shift.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shift.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${fmt(shift.openedAt)} – ${shift.closedAt != null ? fmt(shift.closedAt!) : '—'}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${totalSales.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF14B8A6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '$receiptCount receipt${receiptCount != 1 ? 's' : ''}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppSettingsCard extends StatelessWidget {
  const _AppSettingsCard({required this.provider});

  final PosProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          _SettingToggleTile(
            icon: Icons.animation_outlined,
            label: 'Page Transition Animation',
            description: 'Enable or disable page change animation.',
            value: provider.useAnimatedPageTransitions,
            onChanged: provider.setUseAnimatedPageTransitions,
          ),
          const Divider(color: Color(0xFF334155), height: 20),
          _SettingToggleTile(
            icon: Icons.flash_on_outlined,
            label: 'One-tap Payment Shortcuts',
            description: 'Allow one tap payment for exact cash and card.',
            value: provider.oneTapPaymentEnabled,
            onChanged: provider.setOneTapPaymentEnabled,
          ),
        ],
      ),
    );
  }
}

class _SettingToggleTile extends StatelessWidget {
  const _SettingToggleTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: const Color(0xFF14B8A6),
          activeTrackColor: const Color(0xFF14B8A6).withValues(alpha: 0.4),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      side: const BorderSide(color: Color(0xFF334155)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
