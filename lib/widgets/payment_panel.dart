import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/transaction.dart';
import '../services/esc_pos_preview_renderer.dart';
import '../services/receipt_printer.dart';

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

  Future<void> _onCashDenominationTap(
    PosProvider provider,
    double amount,
  ) async {
    if (_isProcessing || provider.cartIsEmpty || !provider.hasActiveShift) {
      return;
    }
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
        visible.sublist(i, (i + 3) > visible.length ? visible.length : i + 3),
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
                                  ? () =>
                                        _onCashDenominationTap(provider, amount)
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: Key('review-receipt-${t.id}'),
              onPressed: () => _showReceiptReview(context, t),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF38BDF8),
                side: const BorderSide(color: Color(0xFF38BDF8)),
                textStyle: const TextStyle(fontSize: 11),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.receipt_long_outlined, size: 15),
              label: const Text('Review Receipt'),
            ),
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

  Future<void> _showReceiptReview(
    BuildContext context,
    Transaction transaction,
  ) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ReceiptReviewDialog(transaction: transaction),
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

enum _ReceiptReviewMode { detail, paper }

class _ReceiptReviewDialog extends StatefulWidget {
  const _ReceiptReviewDialog({required this.transaction});

  final Transaction transaction;

  @override
  State<_ReceiptReviewDialog> createState() => _ReceiptReviewDialogState();
}

class _ReceiptReviewDialogState extends State<_ReceiptReviewDialog> {
  static const double _receiptPaperWidthPx = 332;
  final GlobalKey _paperPreviewKey = GlobalKey();
  _ReceiptReviewMode _mode = _ReceiptReviewMode.detail;

  String _formatDateTime(DateTime dt) {
    final date =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  List<EscPosPreviewLine> _buildReceiptPreviewLines(Transaction transaction) {
    final template = context.read<PosProvider>().receiptTemplateSettings;
    final bytes = const BasicEscPosEncoder().buildReceipt(
      transaction,
      template: template,
    );
    return const EscPosPreviewRenderer().parse(bytes);
  }

  Future<Uint8List> _capturePaperPreviewPng() async {
    if (_mode != _ReceiptReviewMode.paper) {
      setState(() => _mode = _ReceiptReviewMode.paper);
      await WidgetsBinding.instance.endOfFrame;
    }
    final boundary =
        _paperPreviewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('Paper preview is not ready for export.');
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to convert preview to PNG bytes.');
    }
    return byteData.buffer.asUint8List();
  }

  Future<void> _viewPngPreview() async {
    final bytes = await _capturePaperPreviewPng();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        key: const Key('receipt-png-preview-dialog'),
        backgroundColor: const Color(0xFF0F172A),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'PNG Preview',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('receipt-png-preview-close'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF334155)),
              Expanded(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: Image.memory(
                      bytes,
                      key: const Key('receipt-png-preview-image'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _buildPdfBytes() async {
    final lines = _buildReceiptPreviewLines(widget.transaction);
    final contentHeightMm = lines.fold<double>(
      0,
      (sum, line) => sum + (line.doubleSize ? 7.2 : 4.2),
    );
    final pageHeightMm = (contentHeightMm + 18).clamp(100, 400);
    final doc = pw.Document();
    final courier = pw.Font.courier();
    final courierBold = pw.Font.courierBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          88 * PdfPageFormat.mm,
          pageHeightMm * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              for (final line in lines)
                line.text.isEmpty
                    ? pw.SizedBox(height: (line.doubleSize ? 7.2 : 4.2))
                    : pw.Align(
                        alignment: switch (line.align) {
                          TextAlign.center => pw.Alignment.center,
                          TextAlign.right => pw.Alignment.centerRight,
                          _ => pw.Alignment.centerLeft,
                        },
                        child: pw.Text(
                          line.text,
                          textAlign: switch (line.align) {
                            TextAlign.center => pw.TextAlign.center,
                            TextAlign.right => pw.TextAlign.right,
                            _ => pw.TextAlign.left,
                          },
                          style: pw.TextStyle(
                            font: line.bold ? courierBold : courier,
                            fontSize: line.doubleSize ? 10.8 : 8.2,
                            lineSpacing: 0,
                          ),
                        ),
                      ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  Future<void> _viewPdfPreview() async {
    final pdfBytes = await _buildPdfBytes();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        key: const Key('receipt-pdf-preview-dialog'),
        backgroundColor: const Color(0xFF0F172A),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SizedBox(
          width: 760,
          height: 760,
          child: PdfPreview(
            key: const Key('receipt-pdf-preview-widget'),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: false,
            allowSharing: false,
            build: (_) async => pdfBytes,
          ),
        ),
      ),
    );
  }

  Future<void> _viewReceiptAsPng() async {
    try {
      await _viewPngPreview();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB91C1C),
          duration: const Duration(seconds: 5),
          content: Text('Failed to open PNG preview: $error'),
        ),
      );
    }
  }

  Future<void> _viewReceiptAsPdf() async {
    try {
      await _viewPdfPreview();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB91C1C),
          duration: const Duration(seconds: 5),
          content: Text('Failed to open PDF preview: $error'),
        ),
      );
    }
  }

  Widget _buildPaperReceipt(Transaction transaction) {
    const baseSize = 10.8;
    const baseHeight = 1.22;
    final previewLines = _buildReceiptPreviewLines(transaction);

    return Center(
      child: RepaintBoundary(
        key: _paperPreviewKey,
        child: Container(
          key: const Key('receipt-paper-preview'),
          width: _receiptPaperWidthPx,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD1D5DB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: previewLines.map((line) {
                final fontSize = line.doubleSize ? baseSize * 1.95 : baseSize;
                final style = TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: fontSize,
                  height: baseHeight,
                  letterSpacing: 0.05,
                  fontFamily: 'Courier',
                  fontWeight: line.bold ? FontWeight.w700 : FontWeight.w500,
                );

                if (line.text.isEmpty) {
                  return SizedBox(height: fontSize * baseHeight);
                }

                final alignment = switch (line.align) {
                  TextAlign.center => Alignment.center,
                  TextAlign.right => Alignment.centerRight,
                  _ => Alignment.centerLeft,
                };

                return Align(
                  alignment: alignment,
                  child: Text(line.text, style: style, textAlign: line.align),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    return Dialog(
      key: const Key('receipt-review-dialog'),
      backgroundColor: const Color(0xFF0F172A),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFF38BDF8),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Receipt Review',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('receipt-review-close'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF334155)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('receipt-view-png'),
                        onPressed: _viewReceiptAsPng,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF38BDF8),
                          side: const BorderSide(color: Color(0xFF38BDF8)),
                          textStyle: const TextStyle(fontSize: 11),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.image_outlined, size: 14),
                        label: const Text('View PNG'),
                      ),
                      OutlinedButton.icon(
                        key: const Key('receipt-view-pdf'),
                        onPressed: _viewReceiptAsPdf,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF22C55E),
                          side: const BorderSide(color: Color(0xFF22C55E)),
                          textStyle: const TextStyle(fontSize: 11),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 14,
                        ),
                        label: const Text('View PDF'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        key: const Key('receipt-view-mode-detail'),
                        label: const Text('Detail View'),
                        selected: _mode == _ReceiptReviewMode.detail,
                        onSelected: (_) =>
                            setState(() => _mode = _ReceiptReviewMode.detail),
                        labelStyle: TextStyle(
                          color: _mode == _ReceiptReviewMode.detail
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFCBD5E1),
                          fontSize: 11,
                        ),
                        selectedColor: const Color(0xFF38BDF8),
                        backgroundColor: const Color(0xFF1E293B),
                      ),
                      ChoiceChip(
                        key: const Key('receipt-view-mode-paper'),
                        label: const Text('Paper View'),
                        selected: _mode == _ReceiptReviewMode.paper,
                        onSelected: (_) =>
                            setState(() => _mode = _ReceiptReviewMode.paper),
                        labelStyle: TextStyle(
                          color: _mode == _ReceiptReviewMode.paper
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFCBD5E1),
                          fontSize: 11,
                        ),
                        selectedColor: const Color(0xFF38BDF8),
                        backgroundColor: const Color(0xFF1E293B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _mode == _ReceiptReviewMode.paper
                    ? _buildPaperReceipt(transaction)
                    : ListView(
                        children: [
                          _ReceiptInfoRow(
                            label: 'Receipt ID',
                            value: transaction.id,
                          ),
                          _ReceiptInfoRow(
                            label: 'Time',
                            value: _formatDateTime(transaction.timestamp),
                          ),
                          _ReceiptInfoRow(
                            label: 'Cashier',
                            value: transaction.cashierName ?? '—',
                          ),
                          _ReceiptInfoRow(
                            label: 'Payment',
                            value:
                                '${transaction.tenderType.emoji} ${transaction.tenderType.label}',
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Items',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...transaction.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '\$${item.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(color: Color(0xFF334155)),
                          _ReceiptInfoRow(
                            label: 'Subtotal',
                            value:
                                '\$${transaction.subtotal.toStringAsFixed(2)}',
                          ),
                          _ReceiptInfoRow(
                            label: 'Tax',
                            value: '\$${transaction.tax.toStringAsFixed(2)}',
                          ),
                          _ReceiptInfoRow(
                            label: 'Total',
                            value: '\$${transaction.total.toStringAsFixed(2)}',
                            valueColor: const Color(0xFF14B8A6),
                            bold: true,
                          ),
                          if (transaction.tenderType == TenderType.cash)
                            _ReceiptInfoRow(
                              label: 'Cash',
                              value:
                                  '\$${transaction.cashAmount.toStringAsFixed(2)}',
                            ),
                          if (transaction.tenderType == TenderType.card)
                            _ReceiptInfoRow(
                              label: 'Card',
                              value:
                                  '\$${transaction.cardAmount.toStringAsFixed(2)}',
                            ),
                          if (transaction.tenderType == TenderType.cash &&
                              transaction.change > 0)
                            _ReceiptInfoRow(
                              label: 'Change',
                              value:
                                  '\$${transaction.change.toStringAsFixed(2)}',
                              valueColor: const Color(0xFF22C55E),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptInfoRow extends StatelessWidget {
  const _ReceiptInfoRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFFE2E8F0),
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
