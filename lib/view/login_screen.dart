import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/config/localization/app_strings.dart';
import 'package:rent_settlement_app/bloc/auth/auth_bloc.dart';
import 'package:rent_settlement_app/bloc/auth/auth_event.dart';
import 'package:rent_settlement_app/bloc/auth/auth_state.dart';
import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/config/widgets/rentra_dashboard_widgets.dart';
import 'package:rent_settlement_app/view/owner_dashboard.dart';
import 'package:rent_settlement_app/view/tenant_dashboard.dart';

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
          body: _LoginBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .08),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const RentraBrandLockup(),
                              const SizedBox(height: 28),
                              TextFormField(
                                controller: identifier,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.username],
                                decoration: InputDecoration(
                                  labelText: context.tr('Email'),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? context.tr('Enter your email')
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: password,
                                obscureText: obscure,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  labelText: context.tr('Password'),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => obscure = !obscure),
                                    icon: Icon(obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? context.tr('Enter your password')
                                        : null,
                              ),
                              const SizedBox(height: 22),
                              FilledButton(
                                onPressed:
                                    state is AuthLoading ? null : _submit,
                                child: state is AuthLoading
                                    ? const SizedBox.square(
                                        dimension: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(context.tr('Sign in')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  void _submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(AuthLoginSubmitted(
        identifier: identifier.text, password: password.text));
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
                  Color(0xff0f172a),
                  Color(0xff101d33),
                  Color(0xff1e293b),
                ]
              : const [
                  Color(0xfff8fafc),
                  Color(0xffffffff),
                  Color(0xfffff7ed),
                ],
        ),
      ),
      child: child,
    );
  }
}
