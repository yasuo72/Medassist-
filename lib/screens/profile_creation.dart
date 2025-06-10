import 'package:flutter/material.dart';

class ProfileCreation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Creation'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text('Face Scan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            height: 200,
            color: Colors.grey[300],
            child: Center(child: Text('Face Scan UI Placeholder')),
          ),
          SizedBox(height: 20),
          Text('Fingerprint Scan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            height: 100,
            color: Colors.grey[300],
            child: Center(child: Text('Fingerprint Scan UI Placeholder')),
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(labelText: 'Blood Group'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Conditions'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Allergies'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Past Surgeries'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Generate Summary'),
          ),
        ],
      ),
    );
  }
}
