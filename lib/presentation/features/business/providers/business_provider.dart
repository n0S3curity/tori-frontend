import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasources/remote/businesses_remote_datasource.dart';
import '../../../../data/repositories/businesses_repository_impl.dart';
import '../../../../domain/entities/business_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/usecases/businesses/join_business_usecase.dart';
import '../../../features/auth/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// Simple data class for SP display in booking / management screens
// ---------------------------------------------------------------------------
class SpBasicInfo {
  const SpBasicInfo({
    required this.spId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.specialty,
    this.isActive = true,
  });

  final String spId;
  final String userId;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? specialty;
  final bool isActive;

  String get fullName => '$firstName $lastName';
}

// ---------------------------------------------------------------------------
// SP list for a business
// ---------------------------------------------------------------------------
final serviceProvidersListProvider =
    FutureProvider.family<List<SpBasicInfo>, String>((ref, businessId) async {
  final client = ref.read(apiClientProvider);
  final response = await client
      .get<Map<String, dynamic>>('/businesses/$businessId/service-providers');
  final data = response.data!['data'] as Map<String, dynamic>;
  final list = (data['serviceProviders'] as List? ?? data['sps'] as List? ?? []);
  return list.map((item) {
    final sp = item as Map<String, dynamic>;
    final user = (sp['userId'] is Map ? sp['userId'] : {}) as Map<String, dynamic>;
    return SpBasicInfo(
      spId: sp['_id'] as String? ?? '',
      userId: user['_id'] as String? ?? '',
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String? ?? '',
      profileImage: user['profileImage'] as String?,
      specialty: user['specialty'] as String?,
      isActive: sp['isActive'] as bool? ?? true,
    );
  }).toList();
});

final businessesRemoteDsProvider = Provider<BusinessesRemoteDataSource>((ref) {
  return BusinessesRemoteDataSource(ref.read(apiClientProvider));
});

final businessesRepositoryProvider = Provider<BusinessesRepositoryImpl>((ref) {
  return BusinessesRepositoryImpl(ref.read(businessesRemoteDsProvider));
});

final joinBusinessUseCaseProvider = Provider<JoinBusinessUseCase>((ref) {
  return JoinBusinessUseCase(ref.read(businessesRepositoryProvider));
});

// All businesses list (for client to join)
final businessesListProvider = AsyncNotifierProvider<BusinessesListNotifier, List<BusinessEntity>>(
  BusinessesListNotifier.new,
);

class BusinessesListNotifier extends AsyncNotifier<List<BusinessEntity>> {
  @override
  Future<List<BusinessEntity>> build() async {
    final repo = ref.read(businessesRepositoryProvider);
    final result = await repo.listBusinesses();
    return result.fold((f) => throw f, (list) => list);
  }
}

// Pending registrations for a business
final pendingRegistrationsProvider =
    FutureProviderFamily<List<UserEntity>, String>((ref, businessId) async {
  final repo = ref.read(businessesRepositoryProvider);
  final result = await repo.listPendingRegistrations(businessId);
  return result.fold((f) => throw f, (list) => list);
});

// Single business
final businessProvider = FutureProviderFamily<BusinessEntity, String>((ref, id) async {
  final repo = ref.read(businessesRepositoryProvider);
  final result = await repo.getBusiness(id);
  return result.fold((f) => throw f, (b) => b);
});
