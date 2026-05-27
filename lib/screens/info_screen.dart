import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import 'login_screen.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 26),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign Out?',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your session data will be cleared.\nAre you sure you want to sign out?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<PosProvider>().logout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiptHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _ReceiptHistoryDialog(),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes < 1) return 'Just started';
    if (d.inHours < 1) return '${d.inMinutes}m';
    final h = d.inHours;
    final m = d.inMinutes - h * 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    final user = provider.currentUser;

    if (user == null) {
      return const Scaffold(backgroundColor: Color(0xFF0F172A));
    }

    final receiptCount = provider.activeReceiptCount;
    final totalSales = provider.activeTotalSales;
    final duration = _now.difference(user.loginTime);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: _buildAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            children: [
              _buildAvatar(user),
              const SizedBox(height: 28),
              _buildStatsRow(context, receiptCount, totalSales),
              const SizedBox(height: 16),
              _buildSessionCard(user, duration),
              const SizedBox(height: 32),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E293B),
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ),
      title: const Text(
        'Session Info',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFF334155), height: 1),
      ),
    );
  }

  Widget _buildAvatar(AppUser user) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(color: Color(0xFF14B8A6), shape: BoxShape.circle),
          child: Center(
            child: Text(
              user.initials,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.3)),
              ),
              child: Text(
                user.role,
                style: const TextStyle(color: Color(0xFF14B8A6), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            Text('ID: ${user.id}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, int receiptCount, double totalSales) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long,
            label: 'Receipts',
            value: '$receiptCount',
            color: const Color(0xFF14B8A6),
            onTap: () => _showReceiptHistory(context),
            hint: 'View history',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.attach_money,
            label: 'Total Sales',
            value: '\$${totalSales.toStringAsFixed(2)}',
            color: const Color(0xFF22C55E),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(AppUser user, Duration duration) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Details',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          _SessionRow(icon: Icons.login, label: 'Logged in at', value: _formatTime(user.loginTime)),
          const SizedBox(height: 10),
          _SessionRow(icon: Icons.timer_outlined, label: 'Session duration', value: _formatDuration(duration)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
          foregroundColor: const Color(0xFFEF4444),
          elevation: 0,
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ── Receipt History Dialog ────────────────────────────────────────────────────

class _ReceiptHistoryDialog extends StatelessWidget {
  const _ReceiptHistoryDialog();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    final txns = provider.transactions;

    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 580,
        height: 620,
        child: Column(
          children: [
            _buildHeader(context, txns),
            const Divider(color: Color(0xFF334155), height: 1),
            Expanded(
              child: txns.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_outlined, size: 52, color: Color(0xFF334155)),
                          SizedBox(height: 12),
                          Text('No receipts yet', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: txns.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) => _ReceiptTile(
                        transaction: txns[i],
                        onVoid: () => _confirmVoid(context, provider, txns[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Transaction> txns) {
    final voided = txns.where((t) => t.isVoided).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Color(0xFF14B8A6), size: 20),
          const SizedBox(width: 10),
          const Text(
            'Receipt History',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          if (txns.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${txns.length} total${voided > 0 ? ' · $voided voided' : ''}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _confirmVoid(BuildContext context, PosProvider provider, Transaction txn) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.block, color: Color(0xFFEF4444), size: 24),
              ),
              const SizedBox(height: 16),
              const Text(
                'Void Transaction?',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This will void ${txn.id} (\$${txn.total.toStringAsFixed(2)}).\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        provider.voidTransaction(txn.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Void Transaction'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Receipt Tile ──────────────────────────────────────────────────────────────

class _ReceiptTile extends StatelessWidget {
  const _ReceiptTile({required this.transaction, required this.onVoid});

  final Transaction transaction;
  final VoidCallback onVoid;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.isVoided
            ? const Color(0xFFEF4444).withValues(alpha: 0.05)
            : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: t.isVoided
              ? const Color(0xFFEF4444).withValues(alpha: 0.25)
              : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.id,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 8),
              _badge(
                '${t.tenderType.emoji} ${t.tenderType.label}',
                bgColor: const Color(0xFF334155),
                textColor: const Color(0xFF94A3B8),
              ),
              if (t.isVoided) ...[
                const SizedBox(width: 6),
                _badge(
                  'VOIDED',
                  bgColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  textColor: const Color(0xFFEF4444),
                  borderColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  bold: true,
                ),
              ],
              const Spacer(),
              Text(
                '\$${t.total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: t.isVoided ? const Color(0xFF64748B) : const Color(0xFF14B8A6),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  decoration: t.isVoided ? TextDecoration.lineThrough : null,
                  decorationColor: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFF64748B), size: 12),
              const SizedBox(width: 4),
              Text(_fmtTime(t.timestamp), style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              const SizedBox(width: 12),
              const Icon(Icons.shopping_bag_outlined, color: Color(0xFF64748B), size: 12),
              const SizedBox(width: 4),
              Text('${t.itemCount} items', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ],
          ),
          if (t.isVoided && t.voidedByName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Color(0xFFEF4444), size: 13),
                  const SizedBox(width: 6),
                  Text(
                    'Voided by ${t.voidedByName} (ID: ${t.voidedById})',
                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
                  ),
                  if (t.voidedAt != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      'at ${_fmtTime(t.voidedAt!)}',
                      style: TextStyle(color: const Color(0xFFEF4444).withValues(alpha: 0.7), fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (!t.isVoided) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onVoid,
                icon: const Icon(Icons.block, size: 13),
                label: const Text('Void', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(
    String label, {
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
    bool bold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
    this.hint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: onTap != null ? color.withValues(alpha: 0.35) : const Color(0xFF334155),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6), size: 18),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              if (hint != null) ...[
                const SizedBox(height: 2),
                Text(hint!, style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 11)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 16),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
