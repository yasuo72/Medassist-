import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:medassist_plus/providers/user_profile_provider.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withAlpha(180),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: iconColor),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final userProfile = userProfileProvider.userProfile;
    final Color onPrimaryColor = theme.colorScheme.onPrimary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    final List<Map<String, dynamic>> actionItems = [
      {
        'icon': MdiIcons.fileDocumentOutline,
        'label': loc.actionLabelMedicalSummary,
        'route': '/medical',
      },
      {
        'icon': MdiIcons.accountMultiplePlusOutline,
        'label': loc.actionLabelFamilyManagement,
        'route': '/family',
      },
      {
        'icon': MdiIcons.phoneAlertOutline,
        'label': loc.actionLabelEmergencyContacts,
        'route': '/emergency',
      },
      {
        'icon': MdiIcons.cogOutline,
        'label': loc.actionLabelAppSettings,
        'route': '/settings',
      },
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 120.0,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                loc.homeAppBarTitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: onPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  MdiIcons.accountCircleOutline,
                  color: onPrimaryColor,
                ),
                tooltip: loc.profileTooltip,
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: onSurfaceColor,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            loc.homeGreeting(userProfile.name.isNotEmpty ? userProfile.name : 'User'),
                            textStyle: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: onSurfaceColor,
                            ),
                            speed: const Duration(milliseconds: 150),
                          ),
                        ],
                        totalRepeatCount: 1,
                        displayFullTextOnTap: true,
                      ),
                    ),
                  ),

                  // Lottie Animation
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Lottie.asset(
                        'assets/animations/qr_code_animation.json',
                        height: 110,
                        repeat: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Key Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.homeSectionTitleKeyStats,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12.0,
                          runSpacing: 12.0,
                          children: [
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 22,
                              child: _buildStatItem(
                                context,
                                MdiIcons.waterOutline,
                                loc.statLabelBloodType,
                                userProfile.bloodGroup.isNotEmpty ? userProfile.bloodGroup : loc.notSet,
                                theme.colorScheme.error,
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 22,
                              child: _buildStatItem(
                                context,
                                MdiIcons.flowerTulipOutline,
                                loc.statLabelAllergies,
                                userProfile.allergies.isNotEmpty ? userProfile.allergies.join(', ') : loc.notSet,
                                theme.colorScheme.tertiary,
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 22,
                              child: _buildStatItem(
                                context,
                                MdiIcons.pill,
                                loc.statLabelMedication,
                                userProfile.currentMedications.isNotEmpty ? userProfile.currentMedications.join(', ') : loc.notSet,
                                theme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 22,
                              child: _buildStatItem(
                                context,
                                MdiIcons.heartPulse,
                                loc.statLabelConditions,
                                userProfile.medicalConditions.isNotEmpty ? userProfile.medicalConditions.join(', ') : loc.notSet,
                                theme.colorScheme.secondary, // Purple/Teal for conditions
                              ),
                            ),
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 22,
                              child: _buildStatItem(
                                context,
                                MdiIcons.fileDocumentMultipleOutline,
                                loc.statLabelMedicalReports,
                                '${userProfile.reportFilePaths.length} ${loc.filesSuffix}',
                                theme.colorScheme.surfaceVariant, // A neutral color for reports count
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions Header
                  Text(
                    loc.homeSectionTitleQuickActions,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: onSurfaceColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Quick Actions Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final item = actionItems[index];
                final cardColor =
                    index % 2 == 0
                        ? theme.colorScheme.secondaryContainer.withOpacity(0.7)
                        : theme.colorScheme.tertiaryContainer.withOpacity(0.7);
                final onCardColor =
                    index % 2 == 0
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onTertiaryContainer;

                return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: onCardColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                item['route'] as String,
                              ),
                          borderRadius: BorderRadius.circular(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: onCardColor.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: onCardColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  size: 40.0,
                                  color: onCardColor,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  item['label'] as String,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: onCardColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (200 * (index % 2)).ms, duration: 500.ms)
                    .slideY(begin: 0.2, duration: 400.ms);
              }, childCount: actionItems.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/qr'),
            icon: Icon(
              MdiIcons.qrcodeScan,
              color: theme.colorScheme.onErrorContainer,
            ),
            label: Text(
              loc.homeFabLabelEmergencyId,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: theme.colorScheme.errorContainer,
            elevation: 4.0,
            tooltip: 'Emergency QR/NFC ID',
          )
          .animate()
          .scale(delay: 800.ms, duration: 500.ms)
          .slideY(begin: 0.5, curve: Curves.easeInOutCubic),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
