import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/shared/providers/user_provider.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('UserProvider Tests', () {
    late UserProvider userProvider;

    setUp(() {
      userProvider = UserProvider();
    });

    test('should initialize with default values', () {
      expect(userProvider.isAuthenticated, isFalse);
      expect(userProvider.userRole, isNull);
      expect(userProvider.userId, isNull);
      expect(userProvider.userLevel, equals(0));
      expect(userProvider.profile, isNull);
    });

    test('should have correct data types for user properties', () {
      expect(userProvider.isAuthenticated, isA<bool>());
      expect(userProvider.userLevel, isA<int>());
    });

    test('should set authentication state correctly', () async {
      await userProvider.setAuthenticatedForTest(role: 'buyer');

      expect(userProvider.isAuthenticated, isTrue);
      expect(userProvider.userRole, equals('buyer'));
      expect(userProvider.userLevel, equals(0));
    });

    test('should set commerce role correctly', () async {
      await userProvider.setAuthenticatedForTest(role: 'commerce');

      expect(userProvider.isAuthenticated, isTrue);
      expect(userProvider.userRole, equals('commerce'));
      expect(userProvider.userLevel, equals(1));
    });

    test('should reset to default values after logout', () async {
      // Primero autenticar
      await userProvider.setAuthenticatedForTest(role: 'buyer');

      // Luego hacer logout
      await userProvider.logout();

      expect(userProvider.isAuthenticated, isFalse);
      expect(userProvider.userRole, isNull);
      expect(userProvider.userId, isNull);
      expect(userProvider.userLevel, equals(0));
      expect(userProvider.profile, isNull);
    });

    test('should handle profile operations', () {
      // Test setProfile with valid profile
      final testProfile = TestUtils.createTestProfile();
      userProvider.setProfile(testProfile);
      expect(userProvider.profile, equals(testProfile));

      // Test setProfileForTest with null
      userProvider.setProfileForTest(null);
      expect(userProvider.profile, isNull);

      // Test clearProfile
      userProvider.clearProfile();
      expect(userProvider.profile, isNull);
    });
  });
}
