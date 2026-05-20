import 'package:flutter/material.dart';
import 'pack_selection_screen.dart';
import '../widgets/pulse_widget.dart';
import '../utils/game_engine.dart';

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
    final totalQuestions = GameEngine.allPacks.fold<int>(0, (sum, p) => sum + p.questionCount);
    final totalFree = GameEngine.allPacks.fold<int>(0, (sum, p) => sum + p.freeCount);
    final totalAbHash = GameEngine.allPacks.fold<int>(0, (sum, p) => sum + p.abHashCount);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 20),
              // Logo
              PulseWidget(animation: _pulse, child: Container(
                width: 140, height: 140,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD32F2F), boxShadow: [BoxShadow(color: Color(0xFFD32F2F), blurRadius: 40, spreadRadius: 5)]),
                child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('AB', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
                  Text('talks', style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 5)),
                ])),
              )),
              const SizedBox(height: 30),
              const Text('لعبة بطاقات الأسئلة', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('تحدث بصراحة.. اعرف نفسك أكتر', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 40),

              // Stats
              Row(children: [
                Expanded(child: _statCard('$totalQuestions', 'سؤال', Icons.help_outline_rounded)),
                const SizedBox(width: 8),
                Expanded(child: _statCard('${GameEngine.allPacks.length}', 'باكدج', Icons.collections_rounded)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _statCard('$totalFree', 'حر', Icons.card_giftcard_rounded)),
                const SizedBox(width: 8),
                Expanded(child: _statCard('$totalAbHash', 'AB#', Icons.tag_rounded)),
              ]),
              const SizedBox(height: 8),
              _statCard('1', 'نرد الأفعال', Icons.casino_rounded),

              const SizedBox(height: 40),

              // Start button
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PackSelectionScreen())),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
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
              Text('v3.0.0', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.3))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFD32F2F).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.help_outline_rounded, color: Color(0xFFD32F2F), size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
        ])),
      ]),
    );
  }

  void _showRules(BuildContext ctx) {
    showModalBottomSheet(context: ctx, backgroundColor: const Color(0xFF1A1A1A), isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.95,
        builder: (_, scroll) => Container(padding: const EdgeInsets.all(24), child: ListView(controller: scroll, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const Text('كيفية اللعب', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _step('1', 'اختر باكدج الأسئلة اللي يعجبك'),
          _step('2', 'أضف أسماء اللاعبين (2-10)'),
          _step('3', 'أعطِ كل لاعب بطاقتي AB#'),
          _step('4', 'اسحب البطاقة واقرأ السؤال'),
          _step('5', 'اختر شخصاً للإجابة'),
          _step('6', 'رمِ نرد الأفعال لمعرفة كيفية الرد'),
          _step('7', 'استخدم AB# عشان تخلي حد يتكلم أكتر'),
          const SizedBox(height: 20),
          const Text('نرد الأفعال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
          const SizedBox(height: 10),
          _rule('قصة', 'أخبرنا بقصة'),
          _rule('اعكس', 'اطلب من السائل الإجابة'),
          _rule('كلمة واحدة', 'أجب بكلمة واحدة فقط'),
          _rule('كن صريحاً', 'أجب بصراحة بدون خوف'),
          _rule('كن منفتحاً', 'أجب بشفافية وانفتاح عاطفي'),
          _rule('الجميع', 'على الجميع الإجابة'),
          const SizedBox(height: 20),
          const Text('بطاقة AB#', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
          const SizedBox(height: 10),
          _rule('AB#', 'لو حد جاوب وحاسس إنه محتاج يتكلم أكتر، أي لاعب يستخدم بطاقة AB# عليه'),
        ])),
      ),
    );
  }

  Widget _step(String n, String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle), child: Center(child: Text(n, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
    const SizedBox(width: 12),
    Expanded(child: Text(t, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15, height: 1.5))),
  ]));

  Widget _rule(String title, String desc) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Container(
    padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFD32F2F).withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.3))),
    child: Row(children: [Text(title, style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 8), Expanded(child: Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)))]),
  ));
}
