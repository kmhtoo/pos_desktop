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

    test('defaults to cash and exposes all modes including voucher', () {
      expect(provider.selectedPaymentMode, TenderType.cash);
      expect(provider.paymentModes, containsAll(TenderType.values));
      expect(provider.paymentModes, contains(TenderType.voucher));
    });

    test('selectPaymentMode updates selected mode', () {
      provider.selectPaymentMode(TenderType.voucher);
      expect(provider.selectedPaymentMode, TenderType.voucher);
    });
  });
}
