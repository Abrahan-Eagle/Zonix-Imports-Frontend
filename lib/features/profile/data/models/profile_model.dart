// profile_model.dart
import 'phone_model.dart';
import 'address_model.dart';
import 'document_model.dart';
import 'commerce_model.dart';

// Clase para información del usuario
class UserInfo {
  int id;
  String name;
  String email;
  String? profilePic;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.profilePic,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      profilePic: json['profile_pic'],
    );
  }
}

class Profile {
  int id;
  int userId; // Clave foránea
  String? firstName;
  String? middleName;
  String? lastName;
  String? secondLastName;
  String? photoUsers; // Cambiado para coincidir con el template
  DateTime? dateOfBirth;
  String? maritalStatus;
  String? sex;
  String status; // Estado del perfil
  String? phone; // Teléfono
  String? address; // Dirección
  String role; // 'buyer', 'seller', 'admin'
  bool isVerified;

  // Campos específicos para comercios
  String? businessName; // Nombre del negocio
  String? businessType; // Tipo de negocio
  String? taxId; // RFC

  // Información del usuario asociado
  UserInfo? user;

  // Relaciones
  List<PhoneModel> phones;
  List<AddressModel> addresses;
  List<DocumentModel> documents;
  CommerceModel? commerce;

  // Constructor
  Profile({
    required this.id,
    required this.userId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.secondLastName,
    this.photoUsers,
    this.dateOfBirth,
    this.maritalStatus,
    this.sex,
    this.status = 'notverified', // Valor por defecto
    this.phone,
    this.address,
    this.role = 'buyer',
    this.isVerified = false,
    this.businessName,
    this.businessType,
    this.taxId,
    this.user,
    this.phones = const [],
    this.addresses = const [],
    this.documents = const [],
    this.commerce,
  });

  // Getters útiles
  String get fullName => [firstName, middleName, lastName, secondLastName]
      .where((name) => name != null && name.isNotEmpty)
      .join(' ');

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      secondLastName: json['secondLastName'],
      photoUsers: json['photo_users'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      maritalStatus: json['maritalStatus'],
      sex: json['sex'],
      status: json['status'] ?? 'notverified',
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? 'buyer',
      isVerified: json['is_verified'] ?? false,
      businessName: json['business_name'],
      businessType: json['business_type'],
      taxId: json['tax_id'],
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      phones: json['phones'] != null && (json['phones'] as List).isNotEmpty
          ? (json['phones'] as List)
              .map((phone) => PhoneModel.fromJson(phone))
              .toList()
          : [],
      addresses:
          json['addresses'] != null && (json['addresses'] as List).isNotEmpty
              ? (json['addresses'] as List)
                  .map((address) => AddressModel.fromJson(address))
                  .toList()
              : [],
      documents:
          json['documents'] != null && (json['documents'] as List).isNotEmpty
              ? (json['documents'] as List)
                  .map((document) => DocumentModel.fromJson(document))
                  .toList()
              : [],
      commerce: json['commerce'] != null
          ? CommerceModel.fromJson(json['commerce'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'secondLastName': secondLastName,
      'photo_users': photoUsers,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'maritalStatus': maritalStatus,
      'sex': sex,
      'status': status,
      'phone': phone,
      'address': address,
      'role': role,
      'is_verified': isVerified,
      'business_name': businessName,
      'business_type': businessType,
      'tax_id': taxId,
    };
  }

  // Método para crear una copia con algunos campos modificados
  Profile copyWith({
    int? id,
    int? userId,
    String? firstName,
    String? middleName,
    String? lastName,
    String? secondLastName,
    String? photoUsers,
    DateTime? dateOfBirth,
    String? maritalStatus,
    String? sex,
    String? status,
    String? phone,
    String? address,
    String? role,
    bool? isVerified,
    String? businessName,
    String? businessType,
    String? taxId,
    UserInfo? user,
    List<PhoneModel>? phones,
    List<AddressModel>? addresses,
    List<DocumentModel>? documents,
    CommerceModel? commerce,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      secondLastName: secondLastName ?? this.secondLastName,
      photoUsers: photoUsers ?? this.photoUsers,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      sex: sex ?? this.sex,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      taxId: taxId ?? this.taxId,
      user: user ?? this.user,
      phones: phones ?? this.phones,
      addresses: addresses ?? this.addresses,
      documents: documents ?? this.documents,
      commerce: commerce ?? this.commerce,
    );
  }
}
