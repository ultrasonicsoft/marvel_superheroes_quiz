
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guess_superheroes/main.dart';

void main() {
  testWidgets('Marvel Super Hero Quiz smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('Marvel Super Heroes'), findsOneWidget);
  });
}
