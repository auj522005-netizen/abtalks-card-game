import 'package:flutter/material.dart';
import 'game_setup_screen.dart';
import '../widgets/pulse_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 20),
              PulseWidget(animation: _pulse, child: Container(
                width: 140, height: 140,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFE94560), Color(0xFF533483)]), boxShadow: [BoxShadow(color: const Color(0xFFE94560).withOpacity(0.4), blurRadius: 40, spreadRadius: 5)]),
                child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('AB', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
                  Text('talks', style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 5)),
                ])),
              )),
              const SizedBox(height: 30),
              const Text('لعبة بطاقات الأسئلة', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('تحدث بصراحة.. اعرف نفسك أكتر', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 50),
              _infoCard('67', 'بطاقة سؤال', Icons.question_answer_rounded, const Color(0xFFE94560)),
              const SizedBox(height: 12),
              _infoCard('3', 'بطاقات حرة', Icons.card_giftcard_rounded, const Color(0xFF533483)),
              const SizedBox(height: 12),
              _infoCard('20', 'بطاقة AB#', Icons.tag_rounded, const Color(0xFF0F3460)),
              const SizedBox(height: 12),
              _infoCard('1', 'نرد الأفعال', Icons.casino_rounded, const Color(0xFFE9B044)),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameSetupScreen())),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE94560), Color(0xFFC23152)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFFE94560).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28), SizedBox(width: 8),
                    Text('ابدأ اللعب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(onPressed: () => _showRules(context), child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.help_outline_rounded, color: Colors.white.withOpacity(0.5), size: 18), const SizedBox(width: 6),
                Text('كيفية اللعب', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
              ])),
              const SizedBox(height: 20),
              Text('v1.0.0', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String number, String label, IconData icon, Color color) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(number, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
        ])),
      ]),
    );
  }

  void _showRules(BuildContext ctx) {
    showModalBottomSheet(context: ctx, backgroundColor: const Color(0xFF1A1A2E), isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.95,
        builder: (_, scroll) => Container(padding: const EdgeInsets.all(24), child: ListView(controller: scroll, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const Text('كيفية اللعب', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _step('1', 'أعطِ كل لاعب بطاقتي AB#'),
          _step('2', 'اخلط باقي البطاقات وضعها في المنتصف'),
          _step('3', 'آخر شخص تواصل مع شخص عزيز يبدأ'),
          _step('4', 'اسحب البطاقة العلوية واقرأ السؤال'),
          _step('5', 'اختر شخصاً للإجابة'),
          _step('6', 'رمِ نرد الأفعال لمعرفة كيفية الرد'),
          const SizedBox(height: 20),
          const Text('نرد الأفعال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE9B044))),
          const SizedBox(height: 10),
          _rule('📖 قصة', 'أخبرنا بقصة', const Color(0xFFE94560)),
          _rule('🔄 اعكس', 'اطلب من السائل الإجابة', const Color(0xFF533483)),
          _rule('💬 كلمة واحدة', 'أجب بكلمة واحدة فقط', const Color(0xFF0F3460)),
          _rule('💎 كن صريحاً', 'أجب بصراحة بدون خوف', const Color(0xFFE9B044)),
          _rule('🔓 كن منفتحاً', 'أجب بشفافية وانفتاح عاطفي', const Color(0xFF00B4D8)),
          _rule('👥 الجميع', 'على الجميع الإجابة', const Color(0xFF06D6A0)),
        ])),
      ),
    );
  }

  Widget _step(String n, String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFFE94560), shape: BoxShape.circle), child: Center(child: Text(n, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
    const SizedBox(width: 12),
    Expanded(child: Text(t, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15, height: 1.5))),
  ]));

  Widget _rule(String title, String desc, Color color) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Container(
    padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
    child: Row(children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 8), Expanded(child: Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)))]),
  ));
}
