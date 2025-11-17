import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../privacy/services/privacy_service.dart';
import '../../monetization/services/monetization_service.dart';
import '../../../core/router.dart';

/// Settings screen with GDPR controls and app preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDeletingData = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final privacyState = ref.watch(privacyServiceProvider);
    final monetizationState = ref.watch(monetizationServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Indstillinger'),
      ),
      body: ListView(
        children: [
          // Premium section
          if (!monetizationState.isPremium)
            _buildPremiumSection(theme),
          
          // Privacy and GDPR section
          _buildPrivacySection(theme, privacyState),
          
          // App preferences
          _buildAppPreferences(theme),
          
          // Data management
          _buildDataManagement(theme),
          
          // About section
          _buildAboutSection(theme),
          
          SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildPremiumSection(ThemeData theme) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Få ubegrænsede opslag og fjern annoncer',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showPremiumDialog();
              },
              child: Text('Opgrader til Premium - 29 kr/måned'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPrivacySection(ThemeData theme, PrivacyState privacyState) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Privatliv & GDPR',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // GDPR Consent
          SwitchListTile(
            title: Text('GDPR Samtykke'),
            subtitle: Text('Påkrævet for at bruge appen'),
            value: privacyState.gdprConsentGiven,
            onChanged: (value) async {
              if (value) {
                await ref.read(privacyServiceProvider.notifier).grantGDPRConsent();
              } else {
                await ref.read(privacyServiceProvider.notifier).revokeGDPRConsent();
              }
            },
          ),
          
          // Data Sharing Consent
          SwitchListTile(
            title: Text('Datadeling'),
            subtitle: Text('Del anonyme spam-rapporter'),
            value: privacyState.dataSharingConsentGiven,
            onChanged: (value) async {
              if (value) {
                await ref.read(privacyServiceProvider.notifier).grantDataSharingConsent();
              } else {
                await ref.read(privacyServiceProvider.notifier).revokeDataSharingConsent();
              }
            },
          ),
          
          // Analytics Consent
          SwitchListTile(
            title: Text('Analytics'),
            subtitle: Text('Hjælp med at forbedre appen'),
            value: privacyState.analyticsConsentGiven,
            onChanged: (value) async {
              if (value) {
                await ref.read(privacyServiceProvider.notifier).grantAnalyticsConsent();
              } else {
                await ref.read(privacyServiceProvider.notifier).revokeAnalyticsConsent();
              }
            },
          ),
          
          // Ads Consent
          SwitchListTile(
            title: Text('Annoncer'),
            subtitle: Text('Vis relevante annoncer'),
            value: privacyState.adsConsentGiven,
            onChanged: (value) async {
              if (value) {
                await ref.read(privacyServiceProvider.notifier).grantAdsConsent();
              } else {
                await ref.read(privacyServiceProvider.notifier).revokeAdsConsent();
              }
            },
          ),
          
          Divider(),
          
          // Privacy Policy
          ListTile(
            title: Text('Privatlivspolitik'),
            subtitle: Text('Læs vores fulde privatlivspolitik'),
            trailing: Icon(Icons.open_in_new),
            onTap: () {
              _showPrivacyPolicy();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppPreferences(ThemeData theme) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'App-indstillinger',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          ListTile(
            title: Text('Sprog'),
            subtitle: Text('Dansk'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Show language selection
            },
          ),
          
          ListTile(
            title: Text('Notifikationer'),
            subtitle: Text('Administrér notifikationer'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              context.push(AppRoutes.notificationSettings);
            },
          ),
          
          ListTile(
            title: Text('Automatisk blokering'),
            subtitle: Text('Bloker opkald med spam-score over 80%'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Toggle auto-blocking
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataManagement(ThemeData theme) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Datahåndtering',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          ListTile(
            title: Text('Eksporter data'),
            subtitle: Text('Download alle dine data'),
            trailing: Icon(Icons.download),
            onTap: () {
              _exportUserData();
            },
          ),
          
          ListTile(
            title: Text('Slet alle mine data'),
            subtitle: Text('Permanent sletning af alle dine data'),
            trailing: _isDeletingData
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              _confirmDeleteData();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutSection(ThemeData theme) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Om appen',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          
          ListTile(
            title: Text('Udvikler'),
            subtitle: Text('Danish Caller Insight Team'),
          ),
          
          ListTile(
            title: Text('Support'),
            subtitle: Text('support@danishcallerinsight.com'),
            trailing: Icon(Icons.email),
            onTap: () {
              _launchEmail();
            },
          ),
          
          ListTile(
            title: Text('Vurder appen'),
            subtitle: Text('Del din feedback på Google Play'),
            trailing: Icon(Icons.star),
            onTap: () {
              _launchAppStore();
            },
          ),
        ],
      ),
    );
  }
  
  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Opgrader til Premium'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.all_inclusive),
                title: Text('Ubegrænsede opslag'),
                subtitle: Text('Ingen daglige begrænsninger'),
              ),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Ingen annoncer'),
                subtitle: Text('Få en ren og hurtig oplevelse'),
              ),
              ListTile(
                leading: Icon(Icons.priority_high),
                title: Text('Prioritet support'),
                subtitle: Text('Få hurtig hjælp når du har brug for det'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuller'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(monetizationServiceProvider.notifier).purchasePremium();
              },
              child: Text('Køb for 29 kr/måned'),
            ),
          ],
        );
      },
    );
  }
  
  void _showPrivacyPolicy() {
    final privacyPolicy = ref.read(privacyServiceProvider.notifier).getPrivacyPolicy();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Privatlivspolitik'),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(privacyPolicy),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Luk'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _exportUserData() async {
    try {
      final userData = await ref.read(privacyServiceProvider.notifier).exportUserData();
      
      // Show export success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data eksporteret - ${userData.length} poster')),
      );
      
      // In a real app, you would share the file or send it via email
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved eksport: ${e.toString()}')),
      );
    }
  }
  
  void _confirmDeleteData() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Slet alle data'),
          content: Text(
            'Dette vil permanent slette alle dine data fra appen og vores servere. '
            'Denne handling kan ikke fortrydes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuller'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isDeletingData = true;
                });
                
                try {
                  await ref.read(privacyServiceProvider.notifier).deleteAllUserData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Alle data slettet')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fejl ved sletning: ${e.toString()}')),
                  );
                } finally {
                  setState(() {
                    _isDeletingData = false;
                  });
                }
              },
              child: Text('Slet alt'),
            ),
          ],
        );
      },
    );
  }
  
  void _launchEmail() async {
    final uri = Uri.parse('mailto:support@danishcallerinsight.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
  
  void _launchAppStore() async {
    // In a real app, this would open the Google Play Store
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('App Store åbnes')),
    );
  }
}