class UserEntity {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.phoneVerified = false,
    this.profileImage,
    required this.role,
    this.language = 'he',
    this.isDisabled = false,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final bool phoneVerified;
  final String? profileImage;
  final String role;
  final String language;
  final bool isDisabled;

  String get fullName => '$firstName $lastName';

  bool get isClient => role == 'client';
  bool get isServiceProvider => role == 'serviceProvider';
  bool get isBusinessOwner => role == 'businessOwner';
  bool get isCompanyOwner => role == 'companyOwner';
}
