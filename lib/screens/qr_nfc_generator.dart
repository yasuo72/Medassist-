import 'package:flutter/material.dart';

class QRNFCGenerator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR & NFC Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generated QR Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(child: Text('QR Code Placeholder')),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Set as Lock Screen QR'),
            ),
            SizedBox(height: 20),
            Text('NFC Tag Write', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {},
              child: Text('Write NFC Tag'),
            ),
          ],
        ),
      ),
    );
  }
}
