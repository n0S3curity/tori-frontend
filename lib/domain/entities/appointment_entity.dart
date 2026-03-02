class AppointmentEntity {
  const AppointmentEntity({
    required this.id,
    required this.businessId,
    required this.serviceProviderId,
    required this.serviceId,
    required this.clientId,
    required this.bookedBy,
    required this.scheduledAt,
    required this.endsAt,
    this.status = 'pending',
    this.notes = '',
    this.service,
    this.client,
  });

  final String id;
  final String businessId;
  final String serviceProviderId;
  final String serviceId;
  final String clientId;
  final String bookedBy;
  final DateTime scheduledAt;
  final DateTime endsAt;
  final String status;
  final String notes;
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? client;

  bool get isCanceled => status == 'canceled';
  bool get isCompleted => status == 'completed';
  bool get isUpcoming =>
      scheduledAt.isAfter(DateTime.now()) && !isCanceled;

  String get serviceName => service?['name'] as String? ?? '';
  String get clientName {
    final c = client;
    if (c == null) return '';
    return '${c['firstName']} ${c['lastName']}';
  }
}
