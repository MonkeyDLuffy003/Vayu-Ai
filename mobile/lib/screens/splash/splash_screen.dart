import 'package:flutter/material.dart';
import '../../widgets/orb/holographic_orb.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0E14),
      body: Center(child: HolographicOrb(size: 140)),
    );
  }
}
