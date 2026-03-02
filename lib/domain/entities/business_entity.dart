class BusinessEntity {
  const BusinessEntity({
    required this.id,
    required this.name,
    this.logo,
    required this.ownerId,
    this.isDisabled = false,
    this.usersDisabled = false,
    this.remindersEnabled = true,
    this.formattedAddress,
    this.lat,
    this.lng,
  });

  final String id;
  final String name;
  final String? logo;
  final String ownerId;
  final bool isDisabled;
  final bool usersDisabled;
  final bool remindersEnabled;
  final String? formattedAddress;
  final double? lat;
  final double? lng;
}
