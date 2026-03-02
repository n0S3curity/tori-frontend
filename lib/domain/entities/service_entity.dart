class TimeRangeEntity {
  const TimeRangeEntity({
    required this.day,
    required this.start,
    required this.end,
  });

  final String day;
  final String start;
  final String end;
}

class ServiceEntity {
  const ServiceEntity({
    required this.id,
    required this.serviceProviderId,
    required this.businessId,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.availableDays = const [],
    this.timeRanges = const [],
    this.notes = '',
    this.image,
    this.icon,
    this.isActive = true,
  });

  final String id;
  final String serviceProviderId;
  final String businessId;
  final String name;
  final int durationMinutes;
  final double price;
  final List<String> availableDays;
  final List<TimeRangeEntity> timeRanges;
  final String notes;
  final String? image;
  final String? icon;
  final bool isActive;
}
