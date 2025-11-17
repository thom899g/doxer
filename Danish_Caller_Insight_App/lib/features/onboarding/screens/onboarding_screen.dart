import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../privacy/services/privacy_service.dart';
import '../../../core/router.dart';

/// Onboarding screen for GDPR consent and initial setup
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentPage = 0;
  bool _gdprConsent = false;
  bool _dataSharingConsent = false;
  bool _analyticsConsent = false;
  bool _adsConsent = false;
  
  final PageController _pageController = PageController();
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  Future<void> _completeOnboarding() async {
    final privacyService = ref.read(privacyServiceProvider.notifier);
    
    if (_gdprConsent) {
      await privacyService.grantGDPRConsent();
    }
    
    if (_dataSharingConsent) {
      await privacyService.grantDataSharingConsent();
    }
    
    if (_analyticsConsent) {
      await privacyService.grantAnalyticsConsent();
    }
    
    if (_adsConsent) {
      await privacyService.grantAdsConsent();
    }
    
    // Navigate to home screen
    context.go(AppRoutes.home);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 4,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(theme),
                  _buildGDPRPage(theme),
                  _buildDataSharingPage(theme),
                  _buildConsentsPage(theme),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text('Tilbage'),
                    )
                  else
                    SizedBox(width: 48),
                  
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage == 3 ? 'Start' : 'Næste'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomePage(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_android,
            size: 120,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 32),
          Text(
            'Velkommen til\nDanish Caller Insight',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Identificér ukendte opkald med åbne datakilder',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildFeatureRow(
                    Icons.shield,
                    'GDPR-sikker',
                    'Alle numre hashes for privatliv',
                    theme,
                  ),
                  SizedBox(height: 12),
                  _buildFeatureRow(
                    Icons.business,
                    'CVR-integration',
                    'Identificér danske virksomheder',
                    theme,
                  ),
                  SizedBox(height: 12),
                  _buildFeatureRow(
                    Icons.block,
                    'Spam-beskyttelse',
                    'Bloker automatisk mistænkelige opkald',
                    theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGDPRPage(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.privacy_tip,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 24),
          Text(
            'GDPR & Privatliv',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Dit privatliv er vigtigt for os. Vi følger GDPR og beskytter dine data.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrivacyPoint(
                    'Hasher alle numre',
                    'Telefonnumre hashes med SHA-256 - vi gemmer aldrig originale numre',
                    theme,
                  ),
                  SizedBox(height: 12),
                  _buildPrivacyPoint(
                    'Åbne datakilder',
                    'Bruger kun offentlige datakilder (CVR, OpenStreetMap)',
                    theme,
                  ),
                  SizedBox(height: 12),
                  _buildPrivacyPoint(
                    'Ingen sporing',
                    'Ingen personlig sporing eller profilering',
                    theme,
                  ),
                  SizedBox(height: 12),
                  _buildPrivacyPoint(
                    'Dine rettigheder',
                    'Du kan altid slette alle dine data eller eksportere dem',
                    theme,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          CheckboxListTile(
            value: _gdprConsent,
            onChanged: (value) {
              setState(() {
                _gdprConsent = value ?? false;
              });
            },
            title: Text('Jeg accepterer GDPR-privatlivspolitikken'),
            subtitle: Text('Påkrævet for at bruge appen'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataSharingPage(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 24),
          Text(
            'Fællesskabsdatabase',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Hjælp med at forbedre appen ved at dele anonyme spam-rapporter',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDataSharingPoint(
                    Icons.security,
                    'Anonym deling',
                    'Kun hashede numre deles - aldrig personlige oplysninger',
                    theme,
                  ),
                  SizedBox(height: 12),
                  _buildDataSharingPoint(
                    Icons.handshake,
                    'Hjælp andre',
                    'Dine rapporter hjælper andre brugere med at undgå spam',
                    theme,
                  ),
                  SizedBox(height: 12),
                  _buildDataSharingPoint(
                    Icons.control_point,
                    'Du har kontrol',
                    'Du kan til enhver tid stoppe deling og slette dine bidrag',
                    theme,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          CheckboxListTile(
            value: _dataSharingConsent,
            onChanged: (value) {
              setState(() {
                _dataSharingConsent = value ?? false;
              });
            },
            title: Text('Jeg accepterer anonym datadeling (kun hashede numre)'),
            subtitle: Text('Valgfrit - hjælper med at forbedre appen'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
  
  Widget _buildConsentsPage(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 24),
          Text(
            'Yderligere indstillinger',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Vælg hvilke funktioner du vil aktivere',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _analyticsConsent,
                    onChanged: (value) {
                      setState(() {
                        _analyticsConsent = value ?? false;
                      });
                    },
                    title: Text('Analytics'),
                    subtitle: Text('Hjælp os med at forbedre appen (anonymt)'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  Divider(),
                  CheckboxListTile(
                    value: _adsConsent,
                    onChanged: (value) {
                      setState(() {
                        _adsConsent = value ?? false;
                      });
                    },
                    title: Text('Annoncer'),
                    subtitle: Text('Støt udviklingen ved at vise annoncer'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Du kan altid ændre disse indstillinger senere',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureRow(IconData icon, String title, String subtitle, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPrivacyPoint(String title, String description, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(description, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDataSharingPoint(IconData icon, String title, String description, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(description, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}