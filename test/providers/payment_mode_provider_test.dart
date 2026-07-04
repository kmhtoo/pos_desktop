import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos_desktop/data/app_database.dart';
import 'package:flutter_pos_desktop/data/pos_repository.dart';
import 'package:flutter_pos_desktop/models/transaction.dart';
import 'package:flutter_pos_desktop/providers/pos_provider.dart';

void main() {
  group('Payment mode provider state', () {
    late AppDatabase database;
    late PosProvider provider;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      provider = PosProvider(repository: PosRepository(database));
    });

    test('defaults to cash and exposes supported modes including voucher', () {
      expect(provider.selectedPaymentMode, TenderType.cash);
      expect(provider.paymentModes, isNot(contains(TenderType.split)));
      expect(provider.paymentModes, contains(TenderType.voucher));
    });

    test('selectPaymentMode updates selected mode', () {
      provider.selectPaymentMode(TenderType.voucher);
      expect(provider.selectedPaymentMode, TenderType.voucher);
      expect(provider.showPaymentHistory, isFalse);
    });

    test('history view toggles and resets when selecting payment mode', () {
      provider.showPaymentHistoryView();
      expect(provider.showPaymentHistory, isTrue);

      provider.selectPaymentMode(TenderType.card);
      expect(provider.selectedPaymentMode, TenderType.card);
      expect(provider.showPaymentHistory, isFalse);
    });

    test('cash denomination drafts accumulate into tender lines', () {
      provider.addCashDenominationDraft(10.0);
      provider.addCashDenominationDraft(10.0);
      provider.addCashDenominationDraft(5.0);

      expect(provider.cashTenderedDraft, 25.0);
      expect(provider.cashTenderCountFor(10.0), 2);
      expect(provider.cashTenderCountFor(5.0), 1);
      expect(provider.cashTenderLinesDraft.length, 2);
      expect(provider.cashTenderLinesDraft.first.key, 10.0);
      expect(provider.cashTenderLinesDraft.first.value, 2);

      provider.clearPaymentDrafts();
      expect(provider.cashTenderedDraft, 0.0);
      expect(provider.cashTenderLinesDraft, isEmpty);
    });

    test('removeCashDenominationDraft decrements one tender unit', () {
      provider.addCashDenominationDraft(10.0);
      provider.addCashDenominationDraft(10.0);
      provider.addCashDenominationDraft(5.0);

      provider.removeCashDenominationDraft(10.0);
      expect(provider.cashTenderedDraft, 15.0);
      expect(provider.cashTenderCountFor(10.0), 1);

      provider.removeCashDenominationDraft(10.0);
      expect(provider.cashTenderedDraft, 5.0);
      expect(provider.cashTenderCountFor(10.0), 0);
      expect(provider.cashTenderLinesDraft.map((e) => e.key), [5.0]);
    });

    test('cash denomination visibility and enabled settings can be updated', () {
      expect(provider.isCashDenominationVisible(10000.0), isTrue);
      expect(provider.isCashDenominationEnabled(10000.0), isTrue);

      provider.setCashDenominationVisibility(10000.0, false);
      provider.setCashDenominationEnabled(10000.0, false);

      expect(provider.isCashDenominationVisible(10000.0), isFalse);
      expect(provider.isCashDenominationEnabled(10000.0), isFalse);
      expect(provider.visibleCashDenominations, isNot(contains(10000.0)));
    });
  });
}
