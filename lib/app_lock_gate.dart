import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_lock_provider.dart';

/// Wrap any subtree with this widget to enforce biometric auth when the
/// app is resumed or launched.
class AppLockGate extends StatefulWidget {
  final Widget child;
  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final prov = context.read<AppLockProvider>();
    final ok = await prov.authenticate();
    if (mounted) {
      setState(() => _unlocked = ok);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
