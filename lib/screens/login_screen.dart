import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/app_strings.dart';
import '../features/auth/auth_bloc.dart';
import '../features/auth/auth_event.dart';
import '../features/auth/auth_state.dart';
import '../models/entities.dart';
import 'owner_dashboard.dart';
import 'tenant_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final identifier = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    identifier.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                    builder: (_) => state.user.role == AppRole.owner
                        ? const OwnerDashboardScreen()
                        : const RenterDashboardScreen()),
                (_) => false);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) => Scaffold(
          body: SafeArea(
              child: Center(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Form(
                            key: formKey,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Icon(Icons.home_work_rounded, size: 82),
                                  const SizedBox(height: 16),
                                  Text(context.tr('Rentra login'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 8),
                                  Text(
                                      context.tr(
                                          'Sign in with your email and password. Rentra will open the right workspace for your account.'),
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 28),
                                  TextFormField(
                                      controller: identifier,
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: const [
                                        AutofillHints.username
                                      ],
                                      decoration: InputDecoration(
                                          labelText: context.tr('Email'),
                                          prefixIcon:
                                              const Icon(Icons.email_outlined)),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? context.tr('Enter your email')
                                              : null),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                      controller: password,
                                      obscureText: obscure,
                                      autofillHints: const [
                                        AutofillHints.password
                                      ],
                                      decoration: InputDecoration(
                                          labelText: context.tr('Password'),
                                          prefixIcon:
                                              const Icon(Icons.lock_outline),
                                          suffixIcon: IconButton(
                                              onPressed: () => setState(
                                                  () => obscure = !obscure),
                                              icon: Icon(obscure
                                                  ? Icons.visibility
                                                  : Icons.visibility_off))),
                                      validator: (value) => value == null ||
                                              value.isEmpty
                                          ? context.tr('Enter your password')
                                          : null),
                                  const SizedBox(height: 20),
                                  FilledButton(
                                      onPressed:
                                          state is AuthLoading ? null : _submit,
                                      child: state is AuthLoading
                                          ? const SizedBox.square(
                                              dimension: 22,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2))
                                          : Text(context.tr('Sign in'))),
                                ])),
                      )))),
        ),
      );

  void _submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(AuthLoginSubmitted(
        identifier: identifier.text, password: password.text));
  }
}
