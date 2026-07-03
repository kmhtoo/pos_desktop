import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import '../screens/info_screen.dart';
import '../screens/system_screen.dart';
import '../utils/app_navigation.dart';
import 'payment_mode_dock.dart';

class ProductPanel extends StatelessWidget {
  const ProductPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Header(),
        _CategoryBar(),
        Expanded(child: _ProductGrid()),
        PaymentModeDock(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    final user = provider.currentUser;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFF1E293B),
      child: Row(
        children: [
          const Icon(Icons.point_of_sale, color: Color(0xFF14B8A6), size: 28),
          const SizedBox(width: 12),
          const Text(
            'FlutterPOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 16),
          _ShiftBadge(provider: provider),
          const Spacer(),
          if (user != null) ...[
            // System info button
            IconButton(
              onPressed: () =>
                  pushAppRoute(context, builder: (_) => const SystemScreen()),
              icon: const Icon(Icons.store_outlined, size: 20),
              color: const Color(0xFF94A3B8),
              tooltip: 'System Info',
            ),
            const SizedBox(width: 4),
            // User avatar / session info button
            GestureDetector(
              onTap: () =>
                  pushAppRoute(context, builder: (_) => const InfoScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF14B8A6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF64748B),
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          const _ClockWidget(),
        ],
      ),
    );
  }
}

class _ShiftBadge extends StatelessWidget {
  const _ShiftBadge({required this.provider});
  final PosProvider provider;

  @override
  Widget build(BuildContext context) {
    final hasDay = provider.hasActiveBusinessDay;
    final shift = provider.currentShift;
    final hasShift = provider.hasActiveShift;

    Color bg;
    Color fg;
    String label;

    if (!hasDay) {
      bg = const Color(0xFFEF4444).withValues(alpha: 0.15);
      fg = const Color(0xFFEF4444);
      label = '● Closed';
    } else if (!hasShift) {
      bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      fg = const Color(0xFFF59E0B);
      label = '⚠ No Shift';
    } else {
      bg = const Color(0xFF14B8A6).withValues(alpha: 0.15);
      fg = const Color(0xFF14B8A6);
      label = '${shift!.emoji} ${shift.name}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ClockWidget extends StatefulWidget {
  const _ClockWidget();

  @override
  State<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<_ClockWidget> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    final d =
        '${_now.day.toString().padLeft(2, '0')}/'
        '${_now.month.toString().padLeft(2, '0')}/'
        '${_now.year}';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$h:$m:$s',
          style: const TextStyle(
            color: Color(0xFF14B8A6),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(d, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
      ],
    );
  }
}

const _categoryMeta = {
  'All': (Icons.apps_rounded, Color(0xFF14B8A6)),
  'Beverages': (Icons.local_cafe_rounded, Color(0xFF2196F3)),
  'Food': (Icons.lunch_dining, Color(0xFFFF8F00)),
  'Snacks': (Icons.cookie_outlined, Color(0xFFFFCA28)),
  'Desserts': (Icons.cake_outlined, Color(0xFFE91E63)),
};

class _CategoryBar extends StatelessWidget {
  const _CategoryBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    return Container(
      height: 76,
      color: const Color(0xFF1E293B),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: PosProvider.categories.map((cat) {
          final selected = cat == provider.selectedCategory;
          final meta = _categoryMeta[cat]!;
          final icon = meta.$1;
          final color = meta.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => provider.selectCategory(cat),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.15)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? color : const Color(0xFF334155),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: selected ? color : const Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cat,
                      style: TextStyle(
                        color: selected ? color : const Color(0xFF94A3B8),
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context) {
    final products = context.watch<PosProvider>().filteredProducts;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _ProductCard(product: products[index]),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.read<PosProvider>().addToCart(product),
        borderRadius: BorderRadius.circular(12),
        splashColor: product.color.withValues(alpha: 0.3),
        highlightColor: product.color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: product.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    product.emoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF14B8A6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
