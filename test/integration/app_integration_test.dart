import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zonix/main.dart';
import 'package:zonix/shared/providers/user_provider.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('App Integration Tests', () {
    testWidgets('should complete full app initialization flow',
        (WidgetTester tester) async {
      // Arrange
      final userProvider = UserProvider();

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => userProvider),
          ],
          child: const MyApp(),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle authentication flow',
        (WidgetTester tester) async {
      // Arrange
      final userProvider = UserProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => userProvider),
          ],
          child: const MyApp(),
        ),
      );

      // Act - Simulate authentication
      await userProvider.setAuthenticatedForTest(role: 'buyer');
      await tester.pump();

      // Assert
      expect(userProvider.isAuthenticated, isTrue);
      expect(userProvider.userRole, equals('buyer'));
      expect(userProvider.userLevel, equals(0));
    });

    testWidgets('should handle commerce authentication flow',
        (WidgetTester tester) async {
      // Arrange
      final userProvider = UserProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => userProvider),
          ],
          child: const MyApp(),
        ),
      );

      // Act - Simulate commerce authentication
      await userProvider.setAuthenticatedForTest(role: 'commerce');
      await tester.pump();

      // Assert
      expect(userProvider.isAuthenticated, isTrue);
      expect(userProvider.userRole, equals('commerce'));
      expect(userProvider.userLevel, equals(1));
    });

    testWidgets('should handle logout flow', (WidgetTester tester) async {
      // Arrange
      final userProvider = UserProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => userProvider),
          ],
          child: const MyApp(),
        ),
      );

      // Act - Authenticate then logout
      await userProvider.setAuthenticatedForTest(role: 'buyer');
      await tester.pump();

      await userProvider.logout();
      await tester.pump();

      // Assert
      expect(userProvider.isAuthenticated, isFalse);
      expect(userProvider.userRole, isNull);
      expect(userProvider.userLevel, equals(0));
    });

    testWidgets('should handle profile operations',
        (WidgetTester tester) async {
      // Arrange
      final userProvider = UserProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => userProvider),
          ],
          child: const MyApp(),
        ),
      );

      // Act - Test profile operations
      final testProfile = TestUtils.createTestProfile();
      userProvider.setProfile(testProfile);
      await tester.pump();

      userProvider.clearProfile();
      await tester.pump();

      // Assert
      expect(userProvider.profile, isNull);
    });
  });
}
