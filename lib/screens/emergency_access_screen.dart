import 'package:flutter/material.dart';
import 'package:medassist_plus/screens/emergency_qr_screen.dart'; // Added for QR screen navigation

class EmergencyAccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Emergency Access')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            'Patient Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Patient Name'),
            subtitle: Text('Blood Group, Allergies, Conditions'),
          ),
          ElevatedButton(onPressed: () {}, child: Text('Emergency Contact')),
          SizedBox(height: 20),
          Text(
            'Scan Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(onPressed: () {}, child: Text('Scan Face')),
          ElevatedButton(onPressed: () {}, child: Text('Scan QR')),
          ElevatedButton(onPressed: () {}, child: Text('Scan Fingerprint')),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmergencyQrScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text(
              'View Emergency QR',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
