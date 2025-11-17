import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../monetization/services/monetization_service.dart';
import '../../history/services/history_service.dart';
import '../widgets/lookup_limit_card.dart';
import '../widgets/recent_calls_card.dart';
import '../widgets/quick_actions_card.dart';
import '../../../core/router.dart';

/// Main home screen of the app
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    _loadData();
  }
  
  Future<void> _loadData() async {
    // Load recent calls
    await ref.read(historyServiceProvider.notifier).loadRecentCalls();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monetizationState = ref.watch(monetizationServiceProvider);
    final bannerAd = ref.read(monetizationServiceProvider.notifier).getBannerAdWidget();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Danish Caller Insight'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              context.push(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Banner ad for free users
                  if (bannerAd != null && !monetizationState.isPremium)
                    bannerAd,
                  
                  // Lookup limit card for free users
                  if (!monetizationState.isPremium)
                    LookupLimitCard(),
                  
                  // Quick actions
                  QuickActionsCard(),
                  
                  // Recent calls
                  RecentCallsCard(),
                  
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.manualLookup);
        },
        icon: Icon(Icons.search),
        label: Text('Opslag'),
      ),
    );
  }
}