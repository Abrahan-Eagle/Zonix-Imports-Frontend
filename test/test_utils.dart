import 'package:zonix/features/profile/data/models/profile_model.dart';

/// Utilidades para tests
class TestUtils {
  /// Crea un perfil de prueba válido
  static Profile createTestProfile({
    int id = 1,
    int userId = 1,
    String firstName = 'Test',
    String middleName = 'User',
    String lastName = 'Profile',
    String secondLastName = 'Example',
  }) {
    return Profile(
      id: id,
      userId: userId,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      secondLastName: secondLastName,
      dateOfBirth: DateTime.parse('1990-01-01'),
      maritalStatus: 'single',
      sex: 'male',
      status: 'verified',
      phone: '+1234567890',
      address: 'Test Address',
    );
  }

  /// Crea un perfil de comercio de prueba
  static Profile createTestCommerceProfile({
    int id = 2,
    int userId = 2,
    String firstName = 'Commerce',
    String middleName = 'Business',
    String lastName = 'Owner',
    String secondLastName = 'Test',
  }) {
    return Profile(
      id: id,
      userId: userId,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      secondLastName: secondLastName,
      dateOfBirth: DateTime.parse('1985-05-15'),
      maritalStatus: 'married',
      sex: 'female',
      status: 'verified',
      phone: '+0987654321',
      address: 'Commerce Address',
      businessName: 'Test Business',
      businessType: 'retail',
      taxId: 'RFC123456789',
    );
  }
}
