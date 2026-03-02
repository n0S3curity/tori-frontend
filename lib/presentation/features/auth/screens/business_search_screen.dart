import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/remote/api_client.dart';
import '../../../../data/models/business_model.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';

class BusinessSearchScreen extends ConsumerStatefulWidget {
  const BusinessSearchScreen({super.key});

  @override
  ConsumerState<BusinessSearchScreen> createState() =>
      _BusinessSearchScreenState();
}

class _BusinessSearchScreenState extends ConsumerState<BusinessSearchScreen>
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
    // Load all businesses on start
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
      final list = (response.data!['data'] as Map<String, dynamic>)['businesses'] as List;
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
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _requestJoin(BusinessModel business) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JoinConfirmSheet(business: business),
    );

    if (confirmed == true && mounted) {
      try {
        final client = ref.read(apiClientProvider);
        await client.post<void>(
          '/businesses/${business.id}/registrations',
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'עם איזה עסק',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            'תרצה לקבוע תורים?',
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

              // Search bar
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
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textHint),
                            onPressed: () {
                              _searchController.clear();
                              _search('');
                            },
                          )
                        : null,
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

              // List
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      )
                    : _businesses.isEmpty && _hasSearched
                        ? _EmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            itemCount: _businesses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _BusinessCard(
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

// ---------------------------------------------------------------------------
// Business card
// ---------------------------------------------------------------------------
class _BusinessCard extends StatelessWidget {
  const _BusinessCard({required this.business, required this.onTap});
  final BusinessModel business;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = business.name.isNotEmpty
        ? business.name.substring(0, 1).toUpperCase()
        : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate900.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.amber100,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.amber700,
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
                color: AppColors.amber100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'הצטרף',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.amber700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Join confirmation bottom sheet
// ---------------------------------------------------------------------------
class _JoinConfirmSheet extends StatelessWidget {
  const _JoinConfirmSheet({required this.business});
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
            decoration: BoxDecoration(
              color: AppColors.amber100,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              business.name.isNotEmpty ? business.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.amber700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'להצטרף ל${business.name}?',
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
            'הבקשה תישלח לבעל העסק ותאושר בקרוב',
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

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_outlined,
              size: 40,
              color: AppColors.textHint,
            ),
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
          const SizedBox(height: 6),
          const Text(
            'נסה לחפש בשם אחר',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
