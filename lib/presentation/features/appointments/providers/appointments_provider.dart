import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasources/remote/appointments_remote_datasource.dart';
import '../../../../data/repositories/appointments_repository_impl.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/usecases/appointments/book_appointment_usecase.dart';
import '../../../../domain/usecases/appointments/cancel_appointment_usecase.dart';
import '../../../features/auth/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

final appointmentsRemoteDsProvider = Provider<AppointmentsRemoteDataSource>((ref) {
  return AppointmentsRemoteDataSource(ref.read(apiClientProvider));
});

final appointmentsRepositoryProvider = Provider<AppointmentsRepositoryImpl>((ref) {
  return AppointmentsRepositoryImpl(ref.read(appointmentsRemoteDsProvider));
});

final bookAppointmentUseCaseProvider = Provider<BookAppointmentUseCase>((ref) {
  return BookAppointmentUseCase(ref.read(appointmentsRepositoryProvider));
});

final cancelAppointmentUseCaseProvider = Provider<CancelAppointmentUseCase>((ref) {
  return CancelAppointmentUseCase(ref.read(appointmentsRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Appointments list
// ---------------------------------------------------------------------------

class AppointmentsNotifier extends AsyncNotifier<List<AppointmentEntity>> {
  @override
  Future<List<AppointmentEntity>> build() async {
    final repo = ref.read(appointmentsRepositoryProvider);
    final result = await repo.listAppointments();
    return result.fold((f) => throw f, (list) => list);
  }

  Future<void> cancelAppointment(String id) async {
    final useCase = ref.read(cancelAppointmentUseCaseProvider);
    final result = await useCase(id);
    result.fold(
      (f) => throw f,
      (_) => ref.invalidateSelf(),
    );
  }
}

final appointmentsProvider =
    AsyncNotifierProvider<AppointmentsNotifier, List<AppointmentEntity>>(
  AppointmentsNotifier.new,
);

// ---------------------------------------------------------------------------
// Appointment booking state
// ---------------------------------------------------------------------------

class BookingNotifier extends StateNotifier<AsyncValue<AppointmentEntity?>> {
  BookingNotifier(this._useCase) : super(const AsyncData(null));

  final BookAppointmentUseCase _useCase;

  Future<void> book({
    required String serviceProviderId,
    required String serviceId,
    required DateTime scheduledAt,
    String? clientId,
    String notes = '',
  }) async {
    state = const AsyncLoading();
    final result = await _useCase(
      serviceProviderId: serviceProviderId,
      serviceId: serviceId,
      scheduledAt: scheduledAt,
      clientId: clientId,
      notes: notes,
    );
    state = result.fold(
      (f) => AsyncError(f, StackTrace.current),
      (appointment) => AsyncData(appointment),
    );
  }

  void reset() => state = const AsyncData(null);
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<AppointmentEntity?>>((ref) {
  return BookingNotifier(ref.read(bookAppointmentUseCaseProvider));
});
