import 'package:flutter_test/flutter_test.dart';
import 'package:stock_app/app.dart';

void main() {
  testWidgets('App renders navigation bar', (tester) async {
    await tester.pumpWidget(const StockApp());
    await tester.pump();

    expect(find.text('行情'), findsOneWidget);
    expect(find.text('自选'), findsOneWidget);
    expect(find.text('交易'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
