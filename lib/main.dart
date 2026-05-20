import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_setup_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const ABtalksApp());
}

class ABtalksApp extends StatelessWidget {
  const ABtalksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABtalks Card Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A1A2E), brightness: Brightness.dark),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F23),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)]),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ScaleTransition(scale: _scale, child: FadeTransition(opacity: _fade, child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFE94560), Color(0xFF533483)]), boxShadow: [BoxShadow(color: const Color(0xFFE94560).withOpacity(0.5), blurRadius: 30, spreadRadius: 5)]),
              child: const Center(child: Text('AB', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2))),
            ))),
            const SizedBox(height: 30),
            FadeTransition(opacity: _fade, child: const Text('ABtalks Card Game', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3))),
            const SizedBox(height: 10),
            FadeTransition(opacity: _fade, child: Text('.تحدث بصراحة، اعرف نفسك أكثر', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)))),
          ]),
        ),
      ),
    );
  }
}
