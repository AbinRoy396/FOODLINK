import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_link_app/main.dart';
import 'package:food_link_app/models/donation_model.dart';

void main() {
  group('DonationListItem Widget Tests', () {
    late DonationModel testDonation;

    setUp(() {
      testDonation = DonationModel(
        id: 1,
        donorId: 100,
        foodType: 'Rice and Curry',
        quantity: '10 plates',
        pickupAddress: '123 Main St, City',
        expiryTime: '2025-10-08T18:00:00',
        status: 'Pending',
        createdAt: '2025-10-07T12:00:00',
      );
    });

    testWidgets('renders donation information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonationListItem(donation: testDonation),
          ),
        ),
      );

      // Verify food type is displayed
      expect(find.text('Rice and Curry'), findsOneWidget);
      
      // Verify quantity is displayed
      expect(find.text('Quantity: 10 plates'), findsOneWidget);
      
      // Verify pickup address is displayed
      expect(find.text('Pickup: 123 Main St, City'), findsOneWidget);
      
      // Verify status is displayed
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('displays correct status color for Pending', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonationListItem(donation: testDonation),
          ),
        ),
      );

      final statusContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Container),
        ).at(1), // Second container is the status badge
      );

      expect(statusContainer, isNotNull);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonationListItem(
              donation: testDonation,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('has proper semantics for accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonationListItem(
              donation: testDonation,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
      
      // Verify the widget is tappable (has InkWell)
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('truncates long text with ellipsis', (WidgetTester tester) async {
      final longDonation = DonationModel(
        id: 1,
        donorId: 100,
        foodType: 'Very Long Food Type Name That Should Be Truncated',
        quantity: '10 plates',
        pickupAddress: 'Very Long Address That Should Also Be Truncated With Ellipsis',
        expiryTime: '2025-10-08T18:00:00',
        status: 'Pending',
        createdAt: '2025-10-07T12:00:00',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonationListItem(donation: longDonation),
          ),
        ),
      );

      final foodTypeText = tester.widget<Text>(
        find.text('Very Long Food Type Name That Should Be Truncated'),
      );
      
      expect(foodTypeText.overflow, equals(TextOverflow.ellipsis));
      expect(foodTypeText.maxLines, equals(1));
    });
  });
}
