import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medassist_plus/data/daily_tips.dart';
import '../widgets/glassy_panel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:medassist_plus/services/medical_record_service.dart';
import 'package:medassist_plus/providers/user_profile_provider.dart';
import 'package:medassist_plus/screens/chatbot_screen.dart';

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

    // Neon gradient for border
    final gradientBorder = LinearGradient(
      colors: [const Color(0xFF00D1FF), const Color(0xFF7C4DFF)],
    );

    return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient:
                theme.brightness == Brightness.dark
                    ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                    )
                    : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.10),
                      ],
                    ),
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: gradientBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
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
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  // A small curated list of daily health tips
  // Cached future to avoid multiple network calls on rebuilds
  static final Future<int> _reportsCountFuture = MedicalRecordService().fetchReportsCount();

  // Tips list moved to lib/data/daily_tips.dart

  // Deterministically pick a tip from shared data file
  String _getTodayTip() => getTipForDate(DateTime.now());

  Widget _buildDailyTipCard(BuildContext context) {
  final theme = Theme.of(context);
  return GlassyPanel(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(MdiIcons.lightbulbOnOutline,
              color: theme.colorScheme.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getTodayTip(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    ),
  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final userProfile = userProfileProvider.userProfile;
    final Color headerColor = isDark ? Colors.white : theme.colorScheme.onPrimary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    final List<Map<String, dynamic>> actionItems = [
      {
        'icon': MdiIcons.fileDocumentOutline,
        'label': 'Medical Records',
        'route': '/records',
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
        'icon': MdiIcons.carEmergency,
        'label': 'Crash Detection',
        'route': '/crash',
      },
      {
        'icon': MdiIcons.cogOutline,
        'label': loc.actionLabelAppSettings,
        'route': '/settings',
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          loc.homeAppBarTitle,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: headerColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 8.0,
            ), // move a bit left from the edge
            child: IconButton(
              iconSize: 40,
              padding: EdgeInsets.zero,
              icon: Icon(
                MdiIcons.accountCircleOutline,
                color: headerColor,
                size: 40,
              ),
              tooltip: loc.profileTooltip,
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.6, 1.0],
                  colors:
                      isDark
                          ? [
                            const Color(0xFF041B5F), // deep space blue
                            const Color(0xFF122E91), // royal indigo
                            const Color(0xFF4732A0), // cosmic purple
                          ]
                          : [
                            const Color(0xFF006CFF), // electric blue
                            const Color(0xFF00D1FF), // aqua neon
                            const Color(0xFF00FFC6), // mint glow
                          ],
                ),
              ),
            ),
          ),
          // Subtle animated Lottie background (medical icons)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.3, // increased visibility
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Transform.scale(
                    scale: 0.92, // 20% larger than previous 0.6
                    child: Lottie.asset(
                      'assets/animations/medical_bg.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stack) => const SizedBox(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -60,
            left: -40,
            child: _circle(
              120,
              isDark ? Colors.blueAccent : Colors.lightBlueAccent,
            ),
          ),
          Positioned(
            bottom: -40,
            right: -50,
            child: _circle(160, isDark ? Colors.indigo : Colors.blue.shade200),
          ),
          // Main grid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 32, 16, 16),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Section (glass card for better placement)
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(isDark ? 0.10 : 0.25),
                              Colors.white.withOpacity(isDark ? 0.04 : 0.12),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: onSurfaceColor,
                                ),
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      loc.homeGreeting(
                                        userProfile.name.isNotEmpty
                                            ? userProfile.name
                                            : 'User',
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: onSurfaceColor,
                                      ),
                                      speed: const Duration(milliseconds: 120),
                                    ),
                                  ],
                                  totalRepeatCount: 1,
                                  displayFullTextOnTap: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse('https://sos-view.vercel.app/');
                                Future<bool> _launch(Uri u, LaunchMode m) async {
                                  try {
                                    return await launchUrl(u, mode: m);
                                  } catch (_) {
                                    return false;
                                  }
                                }

                                bool launched = await _launch(uri, LaunchMode.externalApplication);
                                if (!launched) {
                                  // Try with an in-app browser as fallback
                                  launched = await _launch(uri, LaunchMode.inAppBrowserView);
                                }
                                if (!launched && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Could not open the website',
                                        style: TextStyle(fontFamily: 'Poppins'),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: Lottie.asset(
                                  'assets/animations/qr_code_animation.json',
                                  repeat: true,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // spacing
                      
                      const SizedBox(height: 20),

                      // Daily Tip
                      _buildDailyTipCard(context),

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
                                color: theme.colorScheme.onSurface,
                                shadows: [
                                  Shadow(
                                    color: theme.colorScheme.shadow.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12.0,
                              runSpacing: 12.0,
                              children: [
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                      22,
                                  child: _buildStatItem(
                                    context,
                                    MdiIcons.waterOutline,
                                    loc.statLabelBloodType,
                                    userProfile.bloodGroup.isNotEmpty
                                        ? userProfile.bloodGroup
                                        : loc.notSet,
                                    theme.colorScheme.error,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                      22,
                                  child: _buildStatItem(
                                    context,
                                    MdiIcons.flowerTulipOutline,
                                    loc.statLabelAllergies,
                                    userProfile.allergies.isNotEmpty
                                        ? userProfile.allergies.join(', ')
                                        : loc.notSet,
                                    theme.colorScheme.tertiary,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                      22,
                                  child: _buildStatItem(
                                    context,
                                    MdiIcons.pill,
                                    loc.statLabelMedication,
                                    userProfile.currentMedications.isNotEmpty
                                        ? userProfile.currentMedications.join(
                                          ', ',
                                        )
                                        : loc.notSet,
                                    theme.colorScheme.primary,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                      22,
                                  child: _buildStatItem(
                                    context,
                                    MdiIcons.heartPulse,
                                    loc.statLabelConditions,
                                    userProfile.medicalConditions.isNotEmpty
                                        ? userProfile.medicalConditions.join(
                                          ', ',
                                        )
                                        : loc.notSet,
                                    theme
                                        .colorScheme
                                        .secondary, // Purple/Teal for conditions
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                      22,
                                  child: FutureBuilder<int>(
                                    future: _reportsCountFuture,
                                    builder: (context, snapshot) {
                                      final count = snapshot.hasData ? snapshot.data! : userProfile.reportFilePaths.length;
                                      return _buildStatItem(
                                        context,
                                        MdiIcons.fileDocumentMultipleOutline,
                                        loc.statLabelMedicalReports,
                                        '$count ${loc.filesSuffix}',
                                        theme.colorScheme.surfaceVariant,
                                      );
                                    },
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
                          color: theme.colorScheme.onSurface,
                          shadows: [
                            Shadow(
                              color: theme.colorScheme.shadow.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Quick Actions Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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

                      return _DashboardTile(
                            icon: item['icon'] as IconData,
                            label: item['label'] as String,
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  item['route'] as String,
                                ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: (index * 120).ms)
                          .scaleXY(begin: 0.9, duration: 400.ms);
                    }, childCount: actionItems.length),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: double.infinity,
        height: 120,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton.extended(
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
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: _AiChatFab(),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
    );
  }
}

class _AiChatFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      heroTag: 'aiChat',
      onPressed: () => Navigator.pushNamed(context, ChatbotScreen.routeName),
      tooltip: 'Ask AI Doctor',
      backgroundColor: theme.colorScheme.primary,
      elevation: 6,
      child: Icon(MdiIcons.robot, color: theme.colorScheme.onPrimary),
    )
        .animate()
        .scale(duration: 600.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 500.ms, curve: Curves.easeOut);
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ThemeData theme = Theme.of(context);

    final borderGradient = LinearGradient(
      colors: const [Color(0xFF00D1FF), Color(0xFF7C4DFF)],
    );

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          splashColor: theme.colorScheme.primary.withOpacity(0.25),
          borderRadius: BorderRadius.circular(32),
          child: Container(
            decoration: BoxDecoration(gradient: borderGradient),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(isDark ? 0.10 : 0.25),
                    Colors.white.withOpacity(isDark ? 0.04 : 0.12),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 38, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
