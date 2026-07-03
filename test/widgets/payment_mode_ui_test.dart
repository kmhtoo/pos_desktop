import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pos_desktop/data/app_database.dart';
import 'package:flutter_pos_desktop/data/pos_repository.dart';
import 'package:flutter_pos_desktop/models/shift.dart';
import 'package:flutter_pos_desktop/models/transaction.dart';
import 'package:flutter_pos_desktop/models/user.dart';
import 'package:flutter_pos_desktop/providers/pos_provider.dart';
import 'package:flutter_pos_desktop/widgets/payment_mode_dock.dart';
import 'package:flutter_pos_desktop/widgets/payment_panel.dart';

void main() {
  Future<PosProvider> createReadyProvider() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final provider = PosProvider(repository: PosRepository(db));
    final user = AppUser(
      id: '1001',
      name: 'Alex Chen',
      role: 'Cashier',
      loginTime: DateTime.now(),
    );
    provider.setUser(user);
    await provider.openBusinessDay(user);
    await provider.openShift(ShiftType.breakfast, user);
    provider.addToCart(provider.products.first);
    return provider;
  }

  Future<PosProvider> createProviderWithoutOrder() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final provider = PosProvider(repository: PosRepository(db));
    final user = AppUser(
      id: '1001',
      name: 'Alex Chen',
      role: 'Cashier',
      loginTime: DateTime.now(),
    );
    provider.setUser(user);
    await provider.openBusinessDay(user);
    await provider.openShift(ShiftType.breakfast, user);
    return provider;
  }

  Widget wrapWithProvider(PosProvider provider, Widget child) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('Payment mode UI', () {
    testWidgets('dock switches selected payment mode', (tester) async {
      final provider = await createReadyProvider();

      await tester.pumpWidget(
        wrapWithProvider(provider, const PaymentModeDock()),
      );
      await tester.pumpAndSettle();

      expect(provider.selectedPaymentMode, TenderType.cash);
      await tester.tap(find.byKey(const Key('payment-mode-voucher')));
      await tester.pumpAndSettle();

      expect(provider.selectedPaymentMode, TenderType.voucher);
    });

    testWidgets('payment panel responds to selected mode', (tester) async {
      final provider = await createReadyProvider();

      await tester.pumpWidget(
        wrapWithProvider(
          provider,
          const Column(
            children: [
              PaymentModeDock(),
              Expanded(child: PaymentPanel()),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Exact'), findsOneWidget);

      await tester.tap(find.byKey(const Key('payment-mode-voucher')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('voucher-mode-content')), findsOneWidget);
      expect(find.text('Voucher Options'), findsOneWidget);

      await tester.tap(find.byKey(const Key('payment-mode-card')));
      await tester.pumpAndSettle();
      expect(find.text('Charge to Card'), findsOneWidget);
    });

    testWidgets('payment actions do not create txn when order is empty', (
      tester,
    ) async {
      final provider = await createProviderWithoutOrder();

      await tester.pumpWidget(
        wrapWithProvider(
          provider,
          const Column(
            children: [
              PaymentModeDock(),
              Expanded(child: PaymentPanel()),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(provider.transactions, isEmpty);
      await tester.tap(find.text('Exact'));
      await tester.pumpAndSettle();
      expect(provider.transactions, isEmpty);

      expect(provider.selectedPaymentMode, TenderType.cash);
      await tester.tap(find.byKey(const Key('payment-mode-voucher')));
      await tester.pumpAndSettle();
      expect(provider.selectedPaymentMode, TenderType.cash);
    });
  });
}
