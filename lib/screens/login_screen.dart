import 'package:flutter/material.dart';

import '../models/entities.dart';
import 'owner_dashboard.dart';
import 'tenant_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.role});

  final AppRole role;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthMethod method = AuthMethod.phoneOtp;

  @override
  Widget build(BuildContext context) {
    final roleText = widget.role == AppRole.tenant ? 'Tenant' : 'Owner';

    return Scaffold(
      appBar: AppBar(title: Text('$roleText Login')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Authentication', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SegmentedButton<AuthMethod>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<AuthMethod>(value: AuthMethod.phoneOtp, label: Text('Phone + OTP')),
              ButtonSegment<AuthMethod>(value: AuthMethod.emailPassword, label: Text('Email + Password')),
            ],
            selected: {method},
            onSelectionChanged: (value) => setState(() => method = value.first),
          ),
          const SizedBox(height: 14),
          TextField(
            keyboardType: method == AuthMethod.phoneOtp ? TextInputType.phone : TextInputType.emailAddress,
            decoration: InputDecoration(labelText: method == AuthMethod.phoneOtp ? 'Phone Number' : 'Email'),
          ),
          const SizedBox(height: 10),
          if (method == AuthMethod.emailPassword)
            const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => widget.role == AppRole.tenant
                      ? const TenantDashboardScreen()
                      : const OwnerDashboardScreen(),
                ),
                (_) => false,
              );
            },
            child: Text(method == AuthMethod.phoneOtp ? 'Send OTP' : 'Login'),
          ),
        ],
      ),
    );
  }
}
