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
  String _cashInput = '';
  String _cardInput = '';
  String _voucherCode = '';
  bool _isProcessing = false;
  int _quickAmountPage = 0;

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

  void _syncDrafts(PosProvider provider) {
    provider.setCashTenderedDraft(_cashAmount);
    provider.setCardTenderedDraft(_cardAmount);
    provider.setVoucherCodeDraft(_voucherCode.trim());
  }

  void _onNumpadKey(String key, {bool isSplit = false}) {
    final provider = context.read<PosProvider>();
    if (provider.cartIsEmpty) return;

    setState(() {
      final current = isSplit ? _cardInput : _cashInput;
      String updated;

      if (key == '⌫') {
        updated = current.isEmpty
            ? ''
            : current.substring(0, current.length - 1);
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
    _syncDrafts(provider);
  }

  Future<void> _setQuickAmount(PosProvider provider, double amount) async {
    if (provider.cartIsEmpty) return;

    setState(() {
      _cashInput = amount == amount.truncateToDouble()
          ? amount.toInt().toString()
          : amount.toStringAsFixed(2);
    });
    _syncDrafts(provider);
    if (!provider.oneTapPaymentEnabled) return;
    if (amount < provider.total) return;
    await _processPayment(
      provider,
      tenderType: TenderType.cash,
      cashAmountOverride: amount,
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
        cashAmount = cashAmountOverride ?? _cashAmount;
        cardAmount = 0.0;
        break;
      case TenderType.card:
        cashAmount = 0.0;
        cardAmount = cardAmountOverride ?? provider.total;
        break;
      case TenderType.split:
        cardAmount = cardAmountOverride ?? _cardAmount;
        cashAmount = cashAmountOverride ?? (provider.total - cardAmount);
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
        _cashInput = '';
        _cardInput = '';
        _voucherCode = '';
      });
      provider.clearPaymentDrafts();

      _showPaymentSuccessToast(txn);
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
          duration: const Duration(seconds: 2),
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
            children: [_buildPayTab(), _buildHistoryTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 46,
      color: const Color(0xFF1E293B),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF14B8A6),
        indicatorWeight: 2,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        labelColor: const Color(0xFF14B8A6),
        unselectedLabelColor: const Color(0xFF94A3B8),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 16),
                SizedBox(width: 4),
                Text('Payment', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 16),
                SizedBox(width: 4),
                Text('History', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayTab() {
    return Consumer<PosProvider>(
      builder: (context, provider, _) {
        final mode = provider.selectedPaymentMode;
        return Column(
          children: [
            _buildShortcutActions(provider, mode),
            Expanded(child: _buildModeContent(provider, mode)),
          ],
        );
      },
    );
  }

  Widget _buildModeContent(PosProvider provider, TenderType mode) {
    switch (mode) {
      case TenderType.cash:
        return _buildCashContent(provider);
      case TenderType.card:
        return _buildCardContent(provider);
      case TenderType.split:
        return _buildSplitContent(provider);
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
      TenderType.cash => Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isProcessing
                ? null
                : () => _processPayment(
                    provider,
                    tenderType: TenderType.cash,
                    cashAmountOverride: provider.total,
                  ),
            icon: const Icon(Icons.flash_on, size: 14),
            label: Text('Exact Cash • \$${provider.total.toStringAsFixed(2)}'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF14B8A6),
              side: const BorderSide(color: Color(0xFF14B8A6)),
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
    return Column(
      children: [
        _buildQuickAmounts(provider, provider.total),
        Expanded(child: _buildNumpad()),
      ],
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

  Widget _buildSplitContent(PosProvider provider) {
    final cardAmount = _cardAmount;
    final cashNeeded = cardAmount > 0 ? provider.total - cardAmount : 0.0;
    final validSplit = cardAmount > 0 && cardAmount < provider.total;

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
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
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
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
        ),
        Flexible(flex: 1, child: _buildNumpad(isSplit: true)),
      ],
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

  Widget _buildQuickAmounts(PosProvider provider, double total) {
    final suggestions = _quickAmounts(total);
    return SizedBox(
      height: 72,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final perPage = constraints.maxWidth < 420 ? 3 : 4;
          final pages = <List<double>>[];
          for (var i = 0; i < suggestions.length; i += perPage) {
            pages.add(
              suggestions.sublist(
                i,
                (i + perPage) > suggestions.length
                    ? suggestions.length
                    : i + perPage,
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  onPageChanged: (index) =>
                      setState(() => _quickAmountPage = index),
                  itemCount: pages.length,
                  itemBuilder: (_, pageIndex) {
                    final amounts = pages[pageIndex];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                      child: Row(
                        children: amounts.map((amount) {
                          final isExact = amount == total;
                          final label = isExact
                              ? 'Exact'
                              : '\$${amount.toInt()}';
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: GestureDetector(
                                onTap: () => _setQuickAmount(provider, amount),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isExact
                                        ? const Color(
                                            0xFF14B8A6,
                                          ).withValues(alpha: 0.2)
                                        : const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isExact
                                          ? const Color(0xFF14B8A6)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      label,
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
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              if (pages.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (i) {
                      final active = i == _quickAmountPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: active ? 14 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF14B8A6)
                              : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          );
        },
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
