import 'package:flutter/material.dart';

import '../models/entities.dart';
import '../state/app_state.dart';
import 'role_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Language')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Select app language',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                app.setLanguage(AppLanguage.english);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const RoleSelectionScreen()),
                );
              },
              child: const Text('English'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                app.setLanguage(AppLanguage.urdu);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const RoleSelectionScreen()),
                );
              },
              child: const Text('اردو'),
            ),
          ],
        ),
      ),
    );
  }
}
