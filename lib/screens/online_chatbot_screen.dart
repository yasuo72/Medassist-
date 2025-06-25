import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Very basic placeholder for online mode – displays animated backdrop and a note.
class OnlineChatbotScreen extends StatelessWidget {
  static const String routeName = '/chatbot-online';

  const OnlineChatbotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('MedAssist AI'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CupertinoSlidingSegmentedControl<String>(
              thumbColor: Colors.white.withOpacity(0.15),
              groupValue: 'Online',
              backgroundColor: Colors.white.withOpacity(0.05),
              children: const {
                'Offline': Text('Offline', style: TextStyle(color: Colors.white)),
                'Online': Text('Online', style: TextStyle(color: Colors.white)),
              },
              onValueChanged: (val) {
                if (val == 'Offline') {
                  Navigator.pushReplacementNamed(context, '/chatbot');
                }
              },
            ),
          ),
        ),
      ),
      body: const Stack(
        children: [
          _AnimatedBackdrop(),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Online mode coming soon – this is just a placeholder for server-powered responses.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackdrop extends StatefulWidget {
  const _AnimatedBackdrop({Key? key}) : super(key: key);

  @override
  State<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<_AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF4b134f),
                Color(0xFFc94b4b),
              ],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
        );
      },
    );
  }
}
