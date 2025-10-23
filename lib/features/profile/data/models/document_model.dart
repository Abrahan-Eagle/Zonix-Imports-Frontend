class DocumentModel {
  final int? id;
  final int profileId;
  final String type; // 'ci', 'passport', 'rif'
  final String documentNumber;
  final String? rifUrl;
  final String? frontImage;
  final String? backImage;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final bool approved;
  final DateTime? verifiedAt;

  DocumentModel({
    this.id,
    required this.profileId,
    required this.type,
    required this.documentNumber,
    this.rifUrl,
    this.frontImage,
    this.backImage,
    this.issuedAt,
    this.expiresAt,
    this.approved = false,
    this.verifiedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      profileId: json['profile_id'] is int
          ? json['profile_id']
          : int.parse(json['profile_id'].toString()),
      type: json['type'],
      documentNumber: json['document_number'],
      rifUrl: json['rif_url'],
      frontImage: json['front_image'],
      backImage: json['back_image'],
      issuedAt:
          json['issued_at'] != null ? DateTime.parse(json['issued_at']) : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      approved: json['approved'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'type': type,
      'document_number': documentNumber,
      'rif_url': rifUrl,
      'front_image': frontImage,
      'back_image': backImage,
      'issued_at': issuedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'approved': approved,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  DocumentModel copyWith({
    int? id,
    int? profileId,
    String? type,
    String? documentNumber,
    String? rifUrl,
    String? frontImage,
    String? backImage,
    DateTime? issuedAt,
    DateTime? expiresAt,
    bool? approved,
    DateTime? verifiedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      type: type ?? this.type,
      documentNumber: documentNumber ?? this.documentNumber,
      rifUrl: rifUrl ?? this.rifUrl,
      frontImage: frontImage ?? this.frontImage,
      backImage: backImage ?? this.backImage,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      approved: approved ?? this.approved,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
