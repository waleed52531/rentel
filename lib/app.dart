import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/api/app_api_client.dart';
import 'core/preferences/app_preferences_cubit.dart';
import 'core/storage/secure_session_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_bloc.dart';
import 'features/auth/auth_state.dart';
import 'models/entities.dart';
import 'repositories/auth_repository.dart';
import 'repositories/rental_repository.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

const rentraApiBaseUrl = String.fromEnvironment(
  'RENTRA_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

final rentraNavigatorKey = GlobalKey<NavigatorState>();

class RentSettlementApp extends StatelessWidget {
  const RentSettlementApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionStore = SecureSessionStore();
    final apiClient = AppApiClient(baseUrl: rentraApiBaseUrl);
    final authRepository =
        AuthRepository(apiClient: apiClient, sessionStore: sessionStore);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RentalRepository>(
          create: (_) => ApiRentalRepository(
            apiClient: apiClient,
            sessionStore: sessionStore,
          ),
        ),
        RepositoryProvider<AuthRepository>(
          create: (_) => authRepository,
        ),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(authRepository: authRepository),
        child: BlocProvider(
          create: (_) => AppPreferencesCubit(),
          child: BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
            builder: (context, preferences) => MaterialApp(
              navigatorKey: rentraNavigatorKey,
              title: 'Rentra',
              debugShowCheckedModeBanner: false,
              theme: buildAppTheme(),
              darkTheme: buildAppTheme(brightness: Brightness.dark),
              themeMode: preferences.themeMode,
              locale: preferences.language == AppLanguage.urdu
                  ? const Locale('ur')
                  : const Locale('en'),
              supportedLocales: const [
                Locale('en'),
                Locale('ur'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              home: const SplashScreen(),
              builder: (context, child) => BlocListener<AuthBloc, AuthState>(
                listenWhen: (previous, current) =>
                    previous is AuthAuthenticated &&
                    current is AuthUnauthenticated,
                listener: (context, state) =>
                    rentraNavigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                  (_) => false,
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
