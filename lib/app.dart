import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'state/app_state.dart';

class RentSettlementApp extends StatelessWidget {
  const RentSettlementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: AppController(),
      child: MaterialApp(
        title: 'Rent Settlement App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
