import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/app_strings.dart';
import '../features/auth/auth_bloc.dart';
import '../features/auth/auth_event.dart';
import '../features/auth/auth_state.dart';
import '../models/entities.dart';
import 'login_screen.dart';
import 'owner_dashboard.dart';
import 'tenant_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    _sessionTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthSessionChecked());
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => state.user.role == AppRole.owner
                  ? const OwnerDashboardScreen()
                  : const RenterDashboardScreen(),
            ),
          );
          return;
        }

        if (state is AuthUnauthenticated || state is AuthError) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const LoginScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_work_rounded, size: 84),
              const SizedBox(height: 18),
              const Text('Rentra',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(strings.text('Proof • Approval • Frozen History')),
            ],
          ),
        ),
      ),
    );
  }
}
