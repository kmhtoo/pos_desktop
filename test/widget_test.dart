import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pos_desktop/main.dart';
import 'package:flutter_pos_desktop/data/app_database.dart';
import 'package:flutter_pos_desktop/data/pos_repository.dart';
import 'package:flutter_pos_desktop/providers/pos_provider.dart';

void main() {
  testWidgets('POS app smoke test', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = PosRepository(db);
    final provider = PosProvider(repository: repository);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const POSApp(),
      ),
    );
    await tester.pump();
    expect(find.text('FlutterPOS'), findsOneWidget);
  });
}
