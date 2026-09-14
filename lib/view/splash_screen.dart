import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/bloc/auth/auth_bloc.dart';
import 'package:rent_settlement_app/bloc/auth/auth_event.dart';
import 'package:rent_settlement_app/bloc/auth/auth_state.dart';
import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/config/widgets/rentra_dashboard_widgets.dart';
import 'package:rent_settlement_app/view/login_screen.dart';
import 'package:rent_settlement_app/view/owner_dashboard.dart';
import 'package:rent_settlement_app/view/tenant_dashboard.dart';

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
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? const [
                      Color(0xff0f172a),
                      Color(0xff10213c),
                      Color(0xff1e293b),
                    ]
                  : const [
                      Color(0xfff8fafc),
                      Color(0xffffffff),
                      Color(0xfffff7ed),
                    ],
            ),
          ),
          child: Center(
            child: const RentraBrandLockup(),
          ),
        ),
      ),
    );
  }
}
