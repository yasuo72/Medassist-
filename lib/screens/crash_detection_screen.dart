import 'package:flutter/material.dart';

class CrashDetectionSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crash Detection Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Crash Detection'),
            value: true,
            onChanged: (bool value) {},
          ),
          ListTile(
            title: Text('Test Crash Trigger'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: Text('Test'),
            ),
          ),
          ListTile(
            title: Text('Add Emergency Numbers'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: Text('Add'),
            ),
          ),
        ],
      ),
    );
  }
}
