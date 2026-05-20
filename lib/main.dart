import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD32F2F), brightness: Brightness.dark),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
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
        decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ScaleTransition(scale: _scale, child: FadeTransition(opacity: _fade, child: Container(
              width: 160, height: 160,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD32F2F), boxShadow: [BoxShadow(color: Color(0xFFD32F2F), blurRadius: 30, spreadRadius: 5)]),
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
