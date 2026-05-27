import 'package:flutter/material.dart';
import '../widgets/product_panel.dart';
import '../widgets/order_panel.dart';
import '../widgets/payment_panel.dart';

class POSScreen extends StatelessWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(flex: 5, child: ProductPanel()),
          Container(width: 1, color: const Color(0xFF334155)),
          const Expanded(flex: 3, child: OrderPanel()),
          Container(width: 1, color: const Color(0xFF334155)),
          const Expanded(flex: 3, child: PaymentPanel()),
        ],
      ),
    );
  }
}
