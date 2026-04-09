import 'package:flutter/material.dart';

import 'language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LanguageSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.home_work_rounded, size: 84),
            SizedBox(height: 18),
            Text('Rent Settlement App', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Proof • Approval • Frozen History'),
          ],
        ),
      ),
    );
  }
}
