// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:food_link_app/main.dart';
import 'package:food_link_app/user_state.dart';

void main() {
  testWidgets('App boots and shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => UserState())],
        child: const FoodLinkApp(),
      ),
    );
    await tester.pump();
    expect(find.text('FoodLink'), findsWidgets);
  });
}
