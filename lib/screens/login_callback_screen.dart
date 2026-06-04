import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCallbackScreen extends StatefulWidget {
  const LoginCallbackScreen({super.key});

  @override
  State<LoginCallbackScreen> createState() => _LoginCallbackScreenState();
}

class _LoginCallbackScreenState extends State<LoginCallbackScreen> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) {
      if (event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.initialSession ||
          event.event == AuthChangeEvent.tokenRefreshed) {
        _finishLoginFlow();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService().hasActiveSession) {
        _finishLoginFlow();
      }
    });
  }

  Future<void> _finishLoginFlow() async {
    if (_handled || !mounted) return;
    _handled = true;

    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
