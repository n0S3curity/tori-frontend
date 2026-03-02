import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/remote/api_client.dart';
import '../../../../data/models/business_model.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';

class SpJoinScreen extends ConsumerStatefulWidget {
  const SpJoinScreen({super.key});

  @override
  ConsumerState<SpJoinScreen> createState() => _SpJoinScreenState();
}

class _SpJoinScreenState extends ConsumerState<SpJoinScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  List<BusinessModel> _businesses = [];
  bool _loading = false;
  bool _hasSearched = false;
  Timer? _debounce;
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _search('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get<Map<String, dynamic>>(
        '/businesses',
        queryParameters: {'q': query, 'limit': '30'},
      );
      final list =
          (response.data!['data'] as Map<String, dynamic>)['businesses'] as List;
      setState(() {
        _businesses = list
            .map((e) => BusinessModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _hasSearched = true;
      });
    } catch (_) {
      setState(() => _hasSearched = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _requestJoin(BusinessModel business) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SpJoinSheet(business: business),
    );

    if (confirmed == true && mounted) {
      try {
        final client = ref.read(apiClientProvider);
        // SP join request endpoint
        await client.post<void>(
          '/businesses/${business.id}/join-requests',
          data: {},
        );
        if (mounted) {
          context.showSnackBar('הבקשה נשלחה! הבעל עסק יאשר אותה בקרוב');
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar('שגיאה בשליחת הבקשה', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'לאיזה עסק',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            'ברצונך להצטרף?',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text(
                        'לדלג',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'חפש שם עסק...',
                    hintTextDirection: TextDirection.rtl,
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      )
                    : _businesses.isEmpty && _hasSearched
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.store_outlined,
                                      size: 40, color: AppColors.textHint),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'לא נמצאו עסקים',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            itemCount: _businesses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _SpBusinessCard(
                              business: _businesses[i],
                              onTap: () => _requestJoin(_businesses[i]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpBusinessCard extends StatelessWidget {
  const _SpBusinessCard({required this.business, required this.onTap});
  final BusinessModel business;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = business.name.isNotEmpty ? business.name[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successDark,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (business.address?.formatted != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      business.address!.formatted!,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'הגש בקשה',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpJoinSheet extends StatelessWidget {
  const _SpJoinSheet({required this.business});
  final BusinessModel business;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.badge_rounded, color: AppColors.successDark, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'להגיש בקשה ל${business.name}?',
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'בעל העסק יקבל התראה ויאשר את בקשתך',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('שלח בקשה'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ביטול'),
            ),
          ),
        ],
      ),
    );
  }
}
