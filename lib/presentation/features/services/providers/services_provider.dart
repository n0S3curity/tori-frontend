import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasources/remote/services_remote_datasource.dart';
import '../../../../data/repositories/services_repository_impl.dart';
import '../../../../domain/entities/service_entity.dart';
import '../../../features/auth/providers/auth_provider.dart';

final servicesRemoteDsProvider = Provider<ServicesRemoteDataSource>((ref) {
  return ServicesRemoteDataSource(ref.read(apiClientProvider));
});

final servicesRepositoryProvider = Provider<ServicesRepositoryImpl>((ref) {
  return ServicesRepositoryImpl(ref.read(servicesRemoteDsProvider));
});

// Family provider: services for a given SP
final servicesProvider = AsyncNotifierProviderFamily<ServicesNotifier, List<ServiceEntity>, String>(
  ServicesNotifier.new,
);

class ServicesNotifier extends FamilyAsyncNotifier<List<ServiceEntity>, String> {
  @override
  Future<List<ServiceEntity>> build(String spId) async {
    final repo = ref.read(servicesRepositoryProvider);
    final result = await repo.listServices(spId);
    return result.fold((f) => throw f, (list) => list);
  }
}
