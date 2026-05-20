import 'package:flutter/material.dart';
import 'pack_selection_screen.dart';
import '../widgets/pulse_widget.dart';
import '../utils/game_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulse;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
  }

  @override
  void dispose() { _pulse.dispose(); _shimmerCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = GameEngine.allPacks.fold<int>(0, (sum, p) => sum + p.questionCount);
    final totalFree = GameEngine.allPacks.fold<int>(0, (sum, p) => sum + p.freeCount);
    final totalAbHash = GameEngine.allPacks.fold<int>(0, (sum, p) => sum + p.abHashCount);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1A0808), Color(0xFF0F0505), Color(0xFF0A0A0A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 40),

              // ─── AB Logo with glow ───
              PulseWidget(
                animation: _pulse,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => Container(
                        width: 160 + _pulse.value * 12,
                        height: 160 + _pulse.value * 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD32F2F).withOpacity(0.15 + _pulse.value * 0.1),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Second ring
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => Container(
                        width: 148 + _pulse.value * 6,
                        height: 148 + _pulse.value * 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE94560).withOpacity(0.1 + _pulse.value * 0.08),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    // Glow shadow layer
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD32F2F).withOpacity(0.5),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: const Color(0xFFE94560).withOpacity(0.25),
                            blurRadius: 80,
                            spreadRadius: 25,
                          ),
                        ],
                      ),
                    ),
                    // Main circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          center: Alignment(0.3, -0.3),
                          radius: 0.8,
                          colors: [Color(0xFFE94560), Color(0xFFC23152), Color(0xFF880E4F)],
                        ),
                        border: Border.all(color: const Color(0xFFE94560).withOpacity(0.4), width: 1),
                      ),
                      child: const Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('AB', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
                          Text('talks', style: TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 6)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ─── Title ───
              const Text('لعبة بطاقات الأسئلة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text('تحدث بصراحة.. اعرف نفسك أكتر', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4), letterSpacing: 0.3)),

              const SizedBox(height: 36),

              // ─── Stats as horizontal pill chips ───
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _statChip('$totalQuestions', 'سؤال', Icons.help_outline_rounded),
                    const SizedBox(width: 8),
                    _statChip('${GameEngine.allPacks.length}', 'باكدج', Icons.collections_rounded),
                    const SizedBox(width: 8),
                    _statChip('$totalFree', 'حر', Icons.card_giftcard_rounded),
                    const SizedBox(width: 8),
                    _statChip('$totalAbHash', 'AB#', Icons.tag_rounded),
                    const SizedBox(width: 8),
                    _statChip('1', 'نرد', Icons.casino_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ─── Shimmer Start Button ───
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PackSelectionScreen())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFC23152), Color(0xFFE94560), Color(0xFFD32F2F)],
                    ),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8)),
                      BoxShadow(color: const Color(0xFFE94560).withOpacity(0.2), blurRadius: 50, offset: const Offset(0, 16)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer effect
                      AnimatedBuilder(
                        animation: _shimmerCtrl,
                        builder: (_, __) {
                          final shimmerPos = _shimmerCtrl.value;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Align(
                              alignment: Alignment((-1.0 + shimmerPos * 3.0), 0.0),
                              widthFactor: 0.3,
                              child: Container(
                                width: 200,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.15),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Button content
                      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text('ابدأ اللعب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ─── How to play text link ───
              GestureDetector(
                onTap: () => _showRules(context),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.help_outline_rounded, color: Colors.white.withOpacity(0.35), size: 16),
                  const SizedBox(width: 6),
                  Text('كيفية اللعب', style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13, decoration: TextDecoration.underline, decorationColor: Colors.white.withOpacity(0.2))),
                ]),
              ),

              const SizedBox(height: 40),

              // ─── Version ───
              Text('v3.0.0', style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 11, letterSpacing: 2)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _statChip(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: const Color(0xFFE94560), size: 14),
        const SizedBox(width: 6),
        Text(number, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE94560))),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
      ]),
    );
  }

  void _showRules(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scroll) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(controller: scroll, children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(2))),
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
            const Text('نرد الأفعال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE94560))),
            const SizedBox(height: 10),
            _rule('قصة', 'أخبرنا بقصة'),
            _rule('اعكس', 'اطلب من السائل الإجابة'),
            _rule('كلمة واحدة', 'أجب بكلمة واحدة فقط'),
            _rule('كن صريحاً', 'أجب بصراحة بدون خوف'),
            _rule('كن منفتحاً', 'أجب بشفافية وانفتاح عاطفي'),
            _rule('الجميع', 'على الجميع الإجابة'),
            const SizedBox(height: 20),
            const Text('بطاقة AB#', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE94560))),
            const SizedBox(height: 10),
            _rule('AB#', 'لو حد جاوب وحاسس إنه محتاج يتكلم أكتر، أي لاعب يستخدم بطاقة AB# عليه'),
          ]),
        ),
      ),
    );
  }

  Widget _step(String n, String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 26, height: 26, decoration: BoxDecoration(color: const Color(0xFFD32F2F).withOpacity(0.2), border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.5)), shape: BoxShape.circle), child: Center(child: Text(n, style: const TextStyle(color: Color(0xFFE94560), fontSize: 11, fontWeight: FontWeight.bold)))),
    const SizedBox(width: 12),
    Expanded(child: Text(t, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.5))),
  ]));

  Widget _rule(String title, String desc) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.15)),
    ),
    child: Row(children: [
      Text(title, style: const TextStyle(color: Color(0xFFE94560), fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(width: 8),
      Expanded(child: Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13))),
    ]),
  ));
}
