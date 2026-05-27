import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/transaction.dart';

class PaymentPanel extends StatefulWidget {
  const PaymentPanel({super.key});

  @override
  State<PaymentPanel> createState() => _PaymentPanelState();
}

class _PaymentPanelState extends State<PaymentPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  TenderType _tenderType = TenderType.cash;
  String _cashInput = '';
  String _cardInput = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _cashAmount => double.tryParse(_cashInput) ?? 0.0;
  double get _cardAmount => double.tryParse(_cardInput) ?? 0.0;

  void _onNumpadKey(String key, {bool isSplit = false}) {
    setState(() {
      final current = isSplit ? _cardInput : _cashInput;
      String updated;

      if (key == '⌫') {
        updated = current.isEmpty ? '' : current.substring(0, current.length - 1);
      } else if (key == '.') {
        if (current.contains('.')) return;
        updated = current.isEmpty ? '0.' : '$current.';
      } else {
        final dotIdx = current.indexOf('.');
        if (dotIdx >= 0 && current.length - dotIdx > 2) return;
        if (current.length >= 7) return;
        updated = (current == '0') ? key : '$current$key';
      }

      if (isSplit) {
        _cardInput = updated;
      } else {
        _cashInput = updated;
      }
    });
  }

  void _setQuickAmount(double amount) {
    setState(() {
      _cashInput = amount == amount.truncateToDouble()
          ? amount.toInt().toString()
          : amount.toStringAsFixed(2);
    });
  }

  void _changeTender(TenderType type) {
    setState(() {
      _tenderType = type;
      _cashInput = '';
      _cardInput = '';
    });
  }

  bool _canProcess(PosProvider provider) {
    if (provider.cartIsEmpty) return false;
    switch (_tenderType) {
      case TenderType.cash:
        return _cashAmount >= provider.total && _cashInput.isNotEmpty;
      case TenderType.card:
        return true;
      case TenderType.split:
        return _cardAmount > 0 &&
            _cardAmount < provider.total &&
            _cardInput.isNotEmpty;
    }
  }

  void _processPayment(PosProvider provider) {
    double cashAmount;
    double cardAmount;

    switch (_tenderType) {
      case TenderType.cash:
        cashAmount = _cashAmount;
        cardAmount = 0.0;
        break;
      case TenderType.card:
        cashAmount = 0.0;
        cardAmount = provider.total;
        break;
      case TenderType.split:
        cardAmount = _cardAmount;
        cashAmount = provider.total - cardAmount;
        break;
    }

    final txn = provider.processPayment(
      tenderType: _tenderType,
      cashAmount: cashAmount,
      cardAmount: cardAmount,
    );

    setState(() {
      _cashInput = '';
      _cardInput = '';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(transaction: txn),
    );
  }

  List<double> _quickAmounts(double total) {
    final amounts = <double>[total];
    for (final bill in [10.0, 20.0, 50.0, 100.0]) {
      if (bill >= total && !amounts.contains(bill)) amounts.add(bill);
    }
    return amounts.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPayTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 60,
      color: const Color(0xFF1E293B),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF14B8A6),
        labelColor: const Color(0xFF14B8A6),
        unselectedLabelColor: const Color(0xFF94A3B8),
        tabs: const [
          Tab(icon: Icon(Icons.payment, size: 18), text: 'Payment'),
          Tab(icon: Icon(Icons.history, size: 18), text: 'History'),
        ],
      ),
    );
  }

  Widget _buildPayTab() {
    return Consumer<PosProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            _buildTotalBanner(provider),
            _buildTenderSelector(),
            Expanded(child: _buildTenderContent(provider)),
            _buildProcessButton(provider),
          ],
        );
      },
    );
  }

  Widget _buildTotalBanner(PosProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: const Color(0xFF0F172A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Amount Due',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          Text(
            '\$${provider.total.toStringAsFixed(2)}',
            style: TextStyle(
              color: provider.cartIsEmpty
                  ? const Color(0xFF475569)
                  : Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenderSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: TenderType.values.map((type) {
          final selected = _tenderType == type;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => _changeTender(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF14B8A6)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF14B8A6)
                          : const Color(0xFF334155),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(type.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        type.label,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTenderContent(PosProvider provider) {
    switch (_tenderType) {
      case TenderType.cash:
        return _buildCashContent(provider);
      case TenderType.card:
        return _buildCardContent(provider);
      case TenderType.split:
        return _buildSplitContent(provider);
    }
  }

  Widget _buildCashContent(PosProvider provider) {
    final change = _cashAmount - provider.total;
    final hasEnough = _cashInput.isNotEmpty && _cashAmount >= provider.total;
    return Column(
      children: [
        _buildAmountDisplay('Cash Tendered', _cashInput),
        _buildQuickAmounts(provider.total),
        Expanded(child: _buildNumpad()),
        if (_cashInput.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
                Text(
                  hasEnough
                      ? '\$${change.toStringAsFixed(2)}'
                      : 'Insufficient',
                  style: TextStyle(
                    color: hasEnough
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCardContent(PosProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.credit_card,
            color: Color(0xFF14B8A6),
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Charge to Card',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
        ),
        const SizedBox(height: 6),
        Text(
          '\$${provider.total.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tap_and_play, color: Color(0xFF14B8A6), size: 20),
              SizedBox(width: 10),
              Text(
                'Tap, insert, or swipe card',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSplitContent(PosProvider provider) {
    final cardAmount = _cardAmount;
    final cashNeeded = cardAmount > 0 ? provider.total - cardAmount : 0.0;
    final validSplit = cardAmount > 0 && cardAmount < provider.total;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Card Amount',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  _cardInput.isEmpty ? '0.00' : _cardInput,
                  style: TextStyle(
                    color: _cardInput.isEmpty
                        ? const Color(0xFF475569)
                        : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_cardInput.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cash Required',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                    Text(
                      validSplit
                          ? '\$${cashNeeded.toStringAsFixed(2)}'
                          : 'Invalid amount',
                      style: TextStyle(
                        color: validSplit
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Expanded(child: _buildNumpad(isSplit: true)),
      ],
    );
  }

  Widget _buildAmountDisplay(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Text(
              value.isEmpty ? '0.00' : value,
              style: TextStyle(
                color: value.isEmpty ? const Color(0xFF475569) : Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts(double total) {
    final suggestions = _quickAmounts(total);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: suggestions.map((amount) {
          final isExact = amount == total;
          final label = isExact ? 'Exact' : '\$${amount.toInt()}';
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => _setQuickAmount(amount),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: isExact
                        ? const Color(0xFF14B8A6).withValues(alpha: 0.2)
                        : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isExact
                          ? const Color(0xFF14B8A6)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isExact
                          ? const Color(0xFF14B8A6)
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumpad({bool isSplit = false}) {
    const rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['.', '0', '⌫'],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(
        children: rows.map((row) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: row.map((key) {
                  final isBackspace = key == '⌫';
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Material(
                        color: isBackspace
                            ? const Color(0xFF334155)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => _onNumpadKey(key, isSplit: isSplit),
                          borderRadius: BorderRadius.circular(10),
                          child: Center(
                            child: Text(
                              key,
                              style: TextStyle(
                                color: isBackspace
                                    ? const Color(0xFF94A3B8)
                                    : Colors.white,
                                fontSize: isBackspace ? 20 : 22,
                                fontWeight: FontWeight.w600,
                              ),
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
    );
  }

  Widget _buildProcessButton(PosProvider provider) {
    final canProcess = _canProcess(provider);
    final label = switch (_tenderType) {
      TenderType.cash => 'Process Cash Payment',
      TenderType.card => 'Process Card Payment',
      TenderType.split => 'Process Split Payment',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: canProcess ? () => _processPayment(provider) : null,
          icon: const Icon(Icons.check_circle_outline, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14B8A6),
            disabledBackgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            disabledForegroundColor: const Color(0xFF475569),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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
    }
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.id,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 24),
            _DialogRow(
              'Items',
              '${t.itemCount} item${t.itemCount != 1 ? 's' : ''}',
            ),
            _DialogRow('Subtotal', '\$${t.subtotal.toStringAsFixed(2)}'),
            _DialogRow('Tax', '\$${t.tax.toStringAsFixed(2)}'),
            const Divider(color: Color(0xFF334155), height: 20),
            _DialogRow(
              'Total',
              '\$${t.total.toStringAsFixed(2)}',
              bold: true,
            ),
            const SizedBox(height: 8),
            _DialogRow(
              'Tender',
              '${t.tenderType.emoji} ${t.tenderType.label}',
            ),
            if (t.tenderType == TenderType.cash || t.tenderType == TenderType.split) ...[
              if (t.cashAmount > 0)
                _DialogRow('Cash', '\$${t.cashAmount.toStringAsFixed(2)}'),
              if (t.cardAmount > 0)
                _DialogRow('Card', '\$${t.cardAmount.toStringAsFixed(2)}'),
              if (t.change > 0)
                _DialogRow(
                  'Change',
                  '\$${t.change.toStringAsFixed(2)}',
                  valueColor: const Color(0xFF22C55E),
                ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'New Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow(
    this.label,
    this.value, {
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? Colors.white : const Color(0xFF94A3B8),
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ??
                  (bold ? const Color(0xFF14B8A6) : Colors.white),
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
