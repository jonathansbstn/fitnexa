import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uasfitnexa/main.dart';

void main() {
  testWidgets('FITNEXA app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitnexaApp());

    // Verify the app loads without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
