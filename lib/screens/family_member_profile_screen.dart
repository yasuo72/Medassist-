import 'package:flutter/material.dart';
import 'package:medassist_plus/models/family_member.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:url_launcher/url_launcher.dart';
import '../services/family_service.dart';
import 'medical_summary_screen.dart';

class FamilyMemberProfileScreen extends StatefulWidget {
  final FamilyMember member;

  const FamilyMemberProfileScreen({super.key, required this.member});

  @override
  State<FamilyMemberProfileScreen> createState() => _FamilyMemberProfileScreenState();
}

class _FamilyMemberProfileScreenState extends State<FamilyMemberProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.member.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007991), Color(0xFF40C9A2)], // Blue to Teal
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007991), Color(0xFF40C9A2)], // Blue to Teal
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // Changed to ListView for potential future scrolling content
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child:
                    widget.member.avatarUrl != null
                        ? ClipOval(
                          child: Image.network(
                            widget.member.avatarUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                        : Icon(
                          MdiIcons.accountCircleOutline,
                          size: 50,
                          color: Colors.white70,
                        ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDetailRow(
              icon: MdiIcons.cardAccountDetailsOutline,
              label: 'Name',
              value: widget.member.name,
            ),
            _buildDetailRow(
              icon: MdiIcons.humanMaleFemaleChild,
              label: 'Relation',
              value: widget.member.relationship,
            ),
            if (widget.member.age != null)
              _buildDetailRow(
                icon: MdiIcons.calendarAccount,
                label: 'Age',
                value: widget.member.age.toString(),
              ),
            if (widget.member.gender != null)
              _buildDetailRow(
                icon: MdiIcons.genderMaleFemale,
                label: 'Gender',
                value: widget.member.gender!,
              ),
            _buildDetailRow(
              icon: MdiIcons.tagHeartOutline,
              label: 'Medical Tag',
              value: widget.member.medicalTag,
              isMedicalTag: true,
            ),
            // Add more details here as needed
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(
                  MdiIcons.fileDocumentEditOutline,
                  color: Colors.white,
                ),
                label: const Text(
                  'View Full Medical Summary',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () async {
                    final member = widget.member;

                    // If a summary URL exists, open it directly
                    if (member.summaryUrl != null && member.summaryUrl!.isNotEmpty) {
                      final ok = await launchUrl(Uri.parse(member.summaryUrl!));
                      if (!ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open summary')),
                        );
                      }
                      return;
                    }

                    // Otherwise attempt to fetch via emergency ID
                    if (member.emergencyId.isNotEmpty) {
                      try {
                        final data = await FamilyService().getSummaryByEmergencyId(member.emergencyId);
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MedicalSummaryScreen.fromMap(data)),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No summary or emergency ID')),
                      );
                    }
                  

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMedicalTag = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isMedicalTag ? 15 : 17,
                    fontWeight:
                        isMedicalTag ? FontWeight.normal : FontWeight.w500,
                    color: Colors.white,
                    fontStyle:
                        isMedicalTag ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
