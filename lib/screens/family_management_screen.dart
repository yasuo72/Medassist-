import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// Data model for a family member (defined locally as a workaround)
class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final String medicalTag;
  final String? avatarUrl; // Placeholder for actual image path or URL
  final int? age; 
  final String? gender;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.medicalTag,
    this.avatarUrl,
    this.age,
    this.gender,
  });
}


class FamilyManagementScreen extends StatefulWidget {
  const FamilyManagementScreen({super.key});

  @override
  State<FamilyManagementScreen> createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  // Sample data - this will eventually come from a database or state management
  final List<FamilyMember> _familyMembers = [
    FamilyMember(id: '1', name: 'Aarav Sharma', relation: 'Son', medicalTag: 'Asthma', age: 10, gender: 'Male'),
    FamilyMember(id: '2', name: 'Priya Sharma', relation: 'Spouse', medicalTag: 'Healthy', age: 34, gender: 'Female'),
    FamilyMember(id: '3', name: 'Rohan Sharma', relation: 'Father', medicalTag: 'Diabetes Type 2', age: 65, gender: 'Male'),
  ];

  void _addMember() {
    _showAddMemberModal(context); // For adding a new member
  }

  void _editMember(FamilyMember member) {
    _showAddMemberModal(context, member: member); // For editing an existing member
  }

  void _deleteMember(FamilyMember member, int index) {
    final FamilyMember removedMember = member;
    final int removedMemberIndex = index;

    setState(() {
      _familyMembers.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.name} deleted', style: const TextStyle(fontFamily: 'Poppins')),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFF40C9A2),
          onPressed: () {
            setState(() {
              _familyMembers.insert(removedMemberIndex, removedMember);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDismissibleBackground(AlignmentGeometry alignment, Color color, IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0), // Match card's border radius
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Match card's margin
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: Colors.white),
          if (alignment == Alignment.centerLeft) ...[
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  void _showAddMemberModal(BuildContext context, {FamilyMember? member}) {
    final bool isEditing = member != null;
    final _formKey = GlobalKey<FormState>();
    String _name = isEditing ? member.name : '';
    int? _age = isEditing ? member.age : null;
    String? _selectedGender = isEditing ? member.gender : null;
    String? _selectedRelation = isEditing ? member.relation : null;
    String _medicalTag = isEditing ? member.medicalTag : '';

    final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
    final List<String> _relations = ['Spouse', 'Son', 'Daughter', 'Father', 'Mother', 'Sibling', 'Grandparent', 'Grandchild', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return StatefulBuilder( // Needed to update dropdowns within the modal
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16, right: 16, top: 20
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF005266), const Color(0xFF007991).withOpacity(0.9)], // Darker shade of the screen gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.2))
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(isEditing ? 'Edit Family Member' : 'Add New Family Member', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Poppins')),
                        const SizedBox(height: 20),
                        TextFormField(
                          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                          decoration: _inputDecoration('Full Name', MdiIcons.accountOutline),
                          initialValue: _name,
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                          onSaved: (value) => _name = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                          decoration: _inputDecoration('Age', MdiIcons.calendarAccount),
                          initialValue: _age?.toString(),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter an age';
                            if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Please enter a valid age';
                            return null;
                          },
                          onSaved: (value) => _age = int.parse(value!),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownFormField(
                          hintText: 'Gender',
                          iconData: MdiIcons.genderMaleFemale,
                          value: _selectedGender,
                          items: _genders,
                          onChanged: (value) => modalSetState(() => _selectedGender = value),
                          validator: (value) => value == null ? 'Please select a gender' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownFormField(
                          hintText: 'Relation',
                          iconData: MdiIcons.accountGroupOutline,
                          value: _selectedRelation,
                          items: _relations,
                          onChanged: (value) => modalSetState(() => _selectedRelation = value),
                          validator: (value) => value == null ? 'Please select a relation' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                          decoration: _inputDecoration('Medical Tag (e.g., Asthma, Healthy)', MdiIcons.tagHeartOutline),
                          initialValue: _medicalTag,
                          onSaved: (value) => _medicalTag = value ?? '',
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: Icon(MdiIcons.textRecognition, color: Colors.white70),
                          label: Text('Upload Medical Summary (OCR)', style: TextStyle(fontFamily: 'Poppins', color: Colors.white70)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                          onPressed: () {
                            // TODO: Implement OCR trigger
                            print('OCR Upload Tapped');
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF40C9A2), // Teal accent
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              ),
                              child: Text(isEditing ? 'Update Member' : 'Save Member', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white)),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  
                                  if (isEditing) {
                                    final updatedMember = FamilyMember(
                                      id: member.id, // Keep original ID
                                      name: _name,
                                      relation: _selectedRelation!,
                                      age: _age,
                                      gender: _selectedGender,
                                      medicalTag: _medicalTag,
                                      avatarUrl: member.avatarUrl, // Preserve avatar
                                    );
                                    setState(() {
                                      final index = _familyMembers.indexWhere((m) => m.id == member.id);
                                      if (index != -1) {
                                        _familyMembers[index] = updatedMember;
                                      }
                                    });
                                  } else {
                                    final newMember = FamilyMember(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
                                      name: _name,
                                      relation: _selectedRelation!,
                                      age: _age,
                                      gender: _selectedGender,
                                      medicalTag: _medicalTag,
                                    );
                                    setState(() {
                                      _familyMembers.add(newMember);
                                    });
                                  }
                                  Navigator.of(ctx).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontFamily: 'Poppins'),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF40C9A2), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.red.withOpacity(0.7)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.redAccent),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  Widget _buildDropdownFormField({
    required String hintText,
    required IconData iconData,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String> validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: _inputDecoration(hintText, iconData),
      icon: Icon(MdiIcons.chevronDown, color: Colors.white.withOpacity(0.7)),
      dropdownColor: const Color(0xFF005266), // Darker background for dropdown items
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Profile Management',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.accountPlusOutline),
            onPressed: _addMember,
            tooltip: 'Add Family Member',
          ),
        ],
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
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 80), // Added bottom padding for FAB
          itemCount: _familyMembers.length,
          itemBuilder: (context, index) {
            final member = _familyMembers[index];
            return Dismissible(
              key: Key(member.id),
              background: _buildDismissibleBackground(Alignment.centerLeft, Colors.red.shade700, MdiIcons.trashCanOutline, 'Delete'),
              secondaryBackground: _buildDismissibleBackground(Alignment.centerRight, Colors.blue.shade700, MdiIcons.pencilCircleOutline, 'Edit'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) { // Swipe Right (Edit)
                  _editMember(member);
                  return false; // Do not dismiss, just trigger edit action
                } else { // Swipe Left (Delete)
                  return true; // Allow dismiss for delete
                }
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) { // Swipe Left (Delete)
                  _deleteMember(member, index);
                }
              },
              child: InkWell(
                onTap: () {
                  // Optional: Navigate to a detailed profile view if needed
                  // print('Tapped on ${member.name}');
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  color: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                              ? ClipOval(child: Image.network(member.avatarUrl!, fit: BoxFit.cover, width: 60, height: 60,
                                  errorBuilder: (context, error, stackTrace) => Icon(MdiIcons.imageBrokenVariant, size: 30, color: Colors.white70),
                                ))
                              : Icon(MdiIcons.accountCircleOutline, size: 30, color: Colors.white70),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                member.relation,
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white.withOpacity(0.8)),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                member.medicalTag,
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ), // Closes Card
              ), // Closes InkWell
            ); // Closes Dismissible
          }, // Closes itemBuilder
        ), // Closes ListView.builder
      ), // Closes Container for body
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMember,
        label: const Text('Add Member', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        icon: Icon(MdiIcons.plusCircleOutline),
        backgroundColor: const Color(0xFF40C9A2),
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

