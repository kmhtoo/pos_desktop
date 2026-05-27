import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pos_desktop/main.dart';
import 'package:flutter_pos_desktop/providers/pos_provider.dart';

void main() {
  testWidgets('POS app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PosProvider(),
        child: const POSApp(),
      ),
    );
    await tester.pump();
    expect(find.text('FlutterPOS'), findsOneWidget);
  });
}
