import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/transaction.dart';

class PaymentPanel extends StatefulWidget {
  const PaymentPanel({super.key});

  @override
  State<PaymentPanel> createState() => _PaymentPanelState();
}

class _PaymentPanelState extends State<PaymentPanel> {
  String _voucherCode = '';
  bool _isProcessing = false;

  void _syncDrafts(PosProvider provider) {
    provider.setVoucherCodeDraft(_voucherCode.trim());
  }

  Future<void> _onCashDenominationTap(PosProvider provider, double amount) async {
    if (_isProcessing || provider.cartIsEmpty || !provider.hasActiveShift) return;
    provider.addCashDenominationDraft(amount);
    if (provider.amountDueDraft > 0) return;
    await _processPayment(
      provider,
      tenderType: TenderType.cash,
      cashAmountOverride: provider.cashTenderedDraft,
    );
  }

  Future<void> _processPayment(
    PosProvider provider, {
    TenderType? tenderType,
    double? cashAmountOverride,
    double? cardAmountOverride,
  }) async {
    if (!provider.hasActiveShift || provider.cartIsEmpty) return;

    final activeTenderType = tenderType ?? provider.selectedPaymentMode;
    double cashAmount;
    double cardAmount;

    switch (activeTenderType) {
      case TenderType.cash:
        cashAmount = cashAmountOverride ?? provider.cashTenderedDraft;
        cardAmount = 0.0;
        break;
      case TenderType.card:
        cashAmount = 0.0;
        cardAmount = cardAmountOverride ?? provider.total;
        break;
      case TenderType.split:
        cashAmount = 0.0;
        cardAmount = cardAmountOverride ?? provider.total;
        break;
      case TenderType.voucher:
        cashAmount = 0.0;
        cardAmount = provider.total;
        break;
    }

    setState(() => _isProcessing = true);
    try {
      final txn = await provider.processPayment(
        tenderType: activeTenderType,
        cashAmount: cashAmount,
        cardAmount: cardAmount,
      );

      if (!mounted) return;
      setState(() {
        _voucherCode = '';
      });
      provider.clearPaymentDrafts();

      _showPaymentSuccessToast(txn);
    } on PaymentCompletionException catch (error) {
      if (!mounted) return;
      setState(() {
        _voucherCode = '';
      });
      provider.clearPaymentDrafts();
      _showPaymentSuccessToast(error.transaction);
      _showPrintWarningToast(error);
    } catch (error) {
      if (!mounted) return;
      _showPaymentFailureToast(error);
    } finally {
      if (mounted && _isProcessing) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showPaymentSuccessToast(Transaction txn) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          backgroundColor: const Color(0xFF065F46),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Paid \$${txn.total.toStringAsFixed(2)} • ${txn.tenderType.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                txn.id,
                style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12),
              ),
            ],
          ),
        ),
      );
  }

  void _showPrintWarningToast(PaymentCompletionException error) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFFB45309),
        duration: const Duration(seconds: 4),
        content: Text(
          _friendlyPrintWarning(error),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showPaymentFailureToast(Object error) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFFB91C1C),
        duration: const Duration(seconds: 4),
        content: Text(
          _friendlyPaymentFailure(error),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String _friendlyPrintWarning(PaymentCompletionException error) {
    final cause = error.cause.toString().toLowerCase();
    if (cause.contains('printer') || cause.contains('network')) {
      return 'Payment is completed.\n'
          'Cause: the receipt printer is not ready.\n'
          'Try: check printer power, paper, and Wi-Fi, then try printing again.\n'
          'Tell technician: payment saved, receipt print failed.';
    }
    return 'Payment is completed.\n'
        'Cause: the receipt could not be prepared right now.\n'
        'Try: wait a moment and try printing again.\n'
        'Tell technician: payment saved, receipt print failed.';
  }

  String _friendlyPaymentFailure(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('printer')) {
      return 'Payment could not be completed.\n'
          'Cause: the printer was not ready.\n'
          'Try: check printer power and paper, then try again.\n'
          'Tell technician: payment stopped because printer was not ready.';
    }
    return 'Payment could not be completed.\n'
        'Cause: something went wrong while saving the order.\n'
        'Try: check the order and try again.\n'
        'Tell technician: payment step failed before completion.';
  }

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
    return Consumer<PosProvider>(
      builder: (context, provider, _) {
        if (provider.showPaymentHistory) {
          return _buildHistoryTab();
        }
        return _buildPayTab(provider);
      },
    );
  }

  Widget _buildPayTab(PosProvider provider) {
    final mode = provider.selectedPaymentMode;
    return Column(
      children: [
        _buildShortcutActions(provider, mode),
        Expanded(child: _buildModeContent(provider, mode)),
      ],
    );
  }

  Widget _buildModeContent(PosProvider provider, TenderType mode) {
    switch (mode) {
      case TenderType.cash:
        return _buildCashContent(provider);
      case TenderType.card:
        return _buildCardContent(provider);
      case TenderType.split:
        return _buildCardContent(provider);
      case TenderType.voucher:
        return _buildVoucherContent(provider);
    }
  }

  Widget _buildShortcutActions(PosProvider provider, TenderType mode) {
    if (!provider.oneTapPaymentEnabled) return const SizedBox.shrink();
    if (!provider.hasActiveShift || provider.cartIsEmpty) {
      return const SizedBox.shrink();
    }

    return switch (mode) {
      TenderType.cash => const SizedBox.shrink(),
      TenderType.card => Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isProcessing
                ? null
                : () => _processPayment(
                    provider,
                    tenderType: TenderType.card,
                    cardAmountOverride: provider.total,
                  ),
            icon: const Icon(Icons.tap_and_play, size: 14),
            label: Text('Tap to Pay • \$${provider.total.toStringAsFixed(2)}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              textStyle: const TextStyle(fontSize: 11),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
      TenderType.split => const SizedBox.shrink(),
      TenderType.voucher => const SizedBox.shrink(),
    };
  }

  Widget _buildCashContent(PosProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: _buildCashDenominationGrid(provider),
    );
  }

  Widget _buildCardContent(PosProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card,
              color: Color(0xFF14B8A6),
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Charge to Card',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${provider.total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tap_and_play, color: Color(0xFF14B8A6), size: 16),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Tap, insert, or swipe card',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherContent(PosProvider provider) {
    const vouchers = ['WELCOME5', 'STAFF10', 'SUMMER15'];
    return Padding(
      key: const Key('voucher-mode-content'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voucher Options',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: vouchers.map((code) {
              final selected = _voucherCode == code;
              return ChoiceChip(
                label: Text(code, style: const TextStyle(fontSize: 11)),
                selected: selected,
                onSelected: (_) {
                  if (provider.cartIsEmpty) return;
                  setState(() => _voucherCode = code);
                  _syncDrafts(provider);
                },
                selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: selected
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF94A3B8),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Text(
              _voucherCode.isEmpty
                  ? 'Waiting for voucher QR scan...'
                  : 'Voucher: $_voucherCode',
              style: TextStyle(
                color: _voucherCode.isEmpty
                    ? const Color(0xFF64748B)
                    : Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (provider.cartIsEmpty) return;
                    setState(() => _voucherCode = 'QR-VOUCHER');
                    _syncDrafts(provider);
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 16),
                  label: const Text('Scan QR', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    side: const BorderSide(color: Color(0xFF8B5CF6)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _voucherCode.isEmpty
                      ? null
                      : () {
                          if (provider.cartIsEmpty) return;
                          setState(() => _voucherCode = '');
                          _syncDrafts(provider);
                        },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    side: const BorderSide(color: Color(0xFF334155)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashDenominationGrid(PosProvider provider) {
    final visible = provider.visibleCashDenominations;
    final rows = <List<double>>[];
    for (var i = 0; i < visible.length; i += 3) {
      rows.add(
        visible.sublist(
          i,
          (i + 3) > visible.length ? visible.length : i + 3,
        ),
      );
    }

    if (rows.isEmpty) {
      return const Center(
        child: Text(
          'No cash denominations configured',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Column(
            children: rows.map((row) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: row.map((amount) {
                      final count = provider.cashTenderCountFor(amount);
                      final label = _cashDenominationLabel(amount);
                      final isEnabled =
                          provider.isCashDenominationEnabled(amount) &&
                          !provider.cartIsEmpty &&
                          provider.hasActiveShift &&
                          !_isProcessing;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Material(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              key: Key('cash-denomination-$label'),
                              onTap: isEnabled
                                  ? () => _onCashDenominationTap(provider, amount)
                                  : null,
                              borderRadius: BorderRadius.circular(10),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        color: isEnabled
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      count > 0 ? 'x$count' : ' ',
                                      style: TextStyle(
                                        color: isEnabled
                                            ? const Color(0xFF14B8A6)
                                            : const Color(0xFF475569),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<PosProvider>(
      builder: (context, provider, _) {
        final transactions = provider.transactions;
        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Color(0xFF334155),
                ),
                SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                ),
                SizedBox(height: 6),
                Text(
                  'Completed payments appear here',
                  style: TextStyle(color: Color(0xFF475569), fontSize: 13),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) =>
              _TransactionCard(transaction: transactions[index]),
        );
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final Transaction transaction;

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.id,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _tenderColor(t.tenderType).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${t.tenderType.emoji} ${t.tenderType.label}',
                  style: TextStyle(
                    color: _tenderColor(t.tenderType),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${t.itemCount} item${t.itemCount != 1 ? 's' : ''}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(width: 8),
              const Text('·', style: TextStyle(color: Color(0xFF475569))),
              const SizedBox(width: 8),
              Text(
                _formatTime(t.timestamp),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const Spacer(),
              Text(
                '\$${t.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF14B8A6),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          if (t.tenderType == TenderType.cash && t.change > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Change: \$${t.change.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFF22C55E), fontSize: 12),
            ),
          ],
          if (t.tenderType == TenderType.split) ...[
            const SizedBox(height: 4),
            Text(
              '💳 \$${t.cardAmount.toStringAsFixed(2)}  '
              '💵 \$${t.cashAmount.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Color _tenderColor(TenderType type) {
    switch (type) {
      case TenderType.cash:
        return const Color(0xFF22C55E);
      case TenderType.card:
        return const Color(0xFF14B8A6);
      case TenderType.split:
        return const Color(0xFFF59E0B);
      case TenderType.voucher:
        return const Color(0xFF8B5CF6);
    }
  }
}
