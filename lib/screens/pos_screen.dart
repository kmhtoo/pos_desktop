import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import 'system_screen.dart';
import '../widgets/product_panel.dart';
import '../widgets/order_panel.dart';

class POSScreen extends StatelessWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();
    if (!provider.canAccessPos) {
      return const SystemScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final orderWidth = constraints.maxWidth / 3;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: ProductPanel()),
              Container(width: 1, color: const Color(0xFF334155)),
              SizedBox(width: orderWidth, child: const OrderPanel()),
            ],
          );
        },
      ),
    );
  }
}
