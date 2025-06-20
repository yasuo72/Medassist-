import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:medassist_plus/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

class EmergencyInfoScreen extends StatelessWidget {
  final String userId;
  final double confidence;

  const EmergencyInfoScreen({
    super.key,
    required this.userId,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Information'),
        actions: [
          IconButton(
            icon: const Icon(MdiIcons.shareVariant),
            onPressed: () {
              // TODO: Implement sharing functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Confidence indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(MdiIcons.checkCircleOutline, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Match Confidence: ${confidence.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Patient Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Consumer<UserProfileProvider>(
                      builder: (context, provider, _) {
                        final userProfile = provider.userProfile;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${userProfile.name}',
                              style: Theme.of(context).textTheme.titleMedium),
                            Text('Blood Group: ${userProfile.bloodGroup}',
                              style: Theme.of(context).textTheme.titleMedium),
                            if (userProfile.allergies.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Allergies:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...userProfile.allergies.map((allergy) => Text(
                                    '• $allergy',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  )),
                                ],
                              ),
                            if (userProfile.medicalConditions.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Medical Conditions:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...userProfile.medicalConditions.map((condition) => Text(
                                    '• $condition',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  )),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Emergency Contacts
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Consumer<UserProfileProvider>(
                      builder: (context, provider, _) {
                        final contacts = provider.emergencyContacts;
                        
                        return Column(
                          children: contacts.map((contact) => ListTile(
                            leading: const Icon(MdiIcons.phone),
                            title: Text(contact['name'] ?? 'Unknown'),
                            subtitle: Text(contact['phone'] ?? 'Unknown'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(MdiIcons.phone),
                                  onPressed: () {
                                    // TODO: Implement phone call
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(MdiIcons.message),
                                  onPressed: () {
                                    // TODO: Implement message
                                  },
                                ),
                              ],
                            ),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
