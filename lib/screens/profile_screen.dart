import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/app_strings.dart';
import '../core/preferences/app_preferences_cubit.dart';
import '../features/auth/auth_bloc.dart';
import '../features/auth/auth_event.dart';
import '../features/auth/auth_state.dart';
import '../models/entities.dart';
import '../widgets/network_media.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const appVersion = '0.1.0+1';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final preferences = context.watch<AppPreferencesCubit>().state;

    if (auth is! AuthAuthenticated) {
      return Scaffold(
        body: Center(child: Text(context.tr('No active profile'))),
      );
    }

    final user = auth.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Profile'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            _ProfileAvatar(user: user),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name.isEmpty
                                        ? context.tr('Rentra user')
                                        : user.name,
                                    style: theme.textTheme.titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(user.email),
                                  if (user.phone.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(user.phone),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(context.tr(user.role == AppRole.owner
                                      ? 'Owner'
                                      : 'Renter')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.language_outlined),
                            title: Text(context.tr('Language')),
                            trailing: DropdownButton<AppLanguage>(
                              value: preferences.language,
                              underline: const SizedBox.shrink(),
                              items: [
                                DropdownMenuItem(
                                  value: AppLanguage.english,
                                  child: Text(context.tr('English')),
                                ),
                                DropdownMenuItem(
                                  value: AppLanguage.urdu,
                                  child: Text(context.tr('Urdu')),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                context
                                    .read<AppPreferencesCubit>()
                                    .setLanguage(value);
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.contrast_outlined),
                            title: Text(context.tr('Theme')),
                            subtitle:
                                Text(context.tr('Choose how Rentra looks')),
                            trailing: DropdownButton<ThemeMode>(
                              value: preferences.themeMode,
                              underline: const SizedBox.shrink(),
                              items: [
                                DropdownMenuItem(
                                  value: ThemeMode.system,
                                  child: Text(context.tr('System')),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.light,
                                  child: Text(context.tr('Light')),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.dark,
                                  child: Text(context.tr('Dark')),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                context
                                    .read<AppPreferencesCubit>()
                                    .setThemeMode(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text(context.tr('App version')),
                            trailing: const Text(appVersion),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.privacy_tip_outlined),
                            title: Text(context.tr('Privacy policy')),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => showDialog<void>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(context.tr('Privacy policy')),
                                content: Text(
                                  context.tr(
                                      'Rentra uses your account, property, tenancy, payment-record, maintenance, and notification data only to operate the rental management workflows provided by the connected Laravel API.'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(context.tr('Close')),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.read<AuthBloc>().add(const AuthLogoutRequested()),
                  icon: const Icon(Icons.logout),
                  label: Text(context.tr('Logout')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.profileImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: SizedBox.square(
          dimension: 68,
          child: NetworkMediaImage(
            url: imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 34,
      child: Text(
        _initials(user),
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  String _initials(AppUser user) {
    final source = user.name.trim().isNotEmpty ? user.name : user.email;
    final parts = source
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'R';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}
