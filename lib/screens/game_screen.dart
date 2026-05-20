import 'dart:math';
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/die_face.dart';
import '../utils/game_engine.dart';
import '../widgets/pulse_widget.dart';

class GameScreen extends StatefulWidget {
  final List<String> playerNames;
  const GameScreen({super.key, required this.playerNames});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState _state;
  late AnimationController _dieCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _state = GameEngine.initializeGame(widget.playerNames);
    _dieCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() { _dieCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  void _drawCard() => setState(() => _state = GameEngine.drawCard(_state));

  void _selectResponder(String id) {
    setState(() => _state = GameEngine.selectResponder(_state, id));
    _rollDie();
  }

  void _rollDie() {
    _dieCtrl.forward(from: 0).then((_) => setState(() => _state = GameEngine.rollDie(_state)));
  }

  void _nextTurn() => setState(() => _state = GameEngine.nextTurn(_state));
  void _useAbHash() => setState(() => _state = GameEngine.useAbHashCard(_state));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)])),
        child: SafeArea(child: Column(children: [
          _topBar(),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
            _playerIndicator(),
            const SizedBox(height: 16),
            _state.phase == GamePhase.drawingCard ? _drawPile() : _revealedCard(),
            const SizedBox(height: 16),
            _actionArea(),
          ]))),
          _bottomBar(),
        ])),
      ),
    );
  }

  // ─── Top Bar ───
  Widget _topBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
    child: Row(children: [
      IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white54), onPressed: () => Navigator.pop(context)),
      const Spacer(),
      _badge('${_state.remainingCards} بطاقة', const Color(0xFFE94560), Icons.style_rounded),
      const SizedBox(width: 8),
      _badge('${_state.players.length} لاعب', const Color(0xFFE9B044), Icons.people_rounded),
    ]),
  );

  Widget _badge(String text, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
    child: Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 4), Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600))]),
  );

  // ─── Current Player ───
  Widget _playerIndicator() {
    final p = _state.currentPlayer;
    if (p == null) return const SizedBox.shrink();
    return PulseWidget(animation: _pulseCtrl, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE94560).withOpacity(0.3), width: 1.5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.person_rounded, color: Color(0xFFE94560)), const SizedBox(width: 8),
        Text('دور: ${p.name}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFE94560), borderRadius: BorderRadius.circular(10)),
          child: Text('${p.abHashCards} AB#', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
      ]),
    ));
  }

  // ─── Draw Pile ───
  Widget _drawPile() => GestureDetector(onTap: _drawCard, child: Container(
    height: 280,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [const Color(0xFF533483).withOpacity(0.8), const Color(0xFF1A1A2E).withOpacity(0.9)]), border: Border.all(color: const Color(0xFF533483).withOpacity(0.5), width: 2), boxShadow: [BoxShadow(color: const Color(0xFF533483).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE94560).withOpacity(0.5), width: 2)),
        child: const Icon(Icons.touch_app_rounded, color: Color(0xFFE94560), size: 40)),
      const SizedBox(height: 20),
      const Text('اسحب بطاقة', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('اضغط لسحب البطاقة العلوية', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
    ])),
  ));

  // ─── Revealed Card ───
  Widget _revealedCard() {
    final card = _state.currentCard;
    if (card == null) return const SizedBox.shrink();

    Color c1, c2;
    IconData icon;
    String label;
    switch (card.type) {
      case CardType.question: c1 = const Color(0xFF1A1A2E); c2 = const Color(0xFF16213E); icon = Icons.question_answer_rounded; label = card.category ?? 'سؤال'; break;
      case CardType.free: c1 = const Color(0xFF533483); c2 = const Color(0xFF3A1078); icon = Icons.card_giftcard_rounded; label = 'حرية'; break;
      case CardType.abHash: c1 = const Color(0xFFE94560); c2 = const Color(0xFFC23152); icon = Icons.tag_rounded; label = 'AB# - انفتاح عميق'; break;
    }

    return Container(
      height: 280,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [c1, c2]), border: Border.all(color: card.type == CardType.abHash ? const Color(0xFFE94560) : Colors.white.withOpacity(0.15), width: card.type == CardType.abHash ? 2.5 : 1.5), boxShadow: [BoxShadow(color: (card.type == CardType.abHash ? const Color(0xFFE94560) : const Color(0xFF533483)).withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10))]),
      child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: card.type == CardType.abHash ? Colors.white.withOpacity(0.2) : const Color(0xFFE94560).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [Icon(icon, color: card.type == CardType.abHash ? Colors.white : const Color(0xFFE94560), size: 14), const SizedBox(width: 4), Text(label, style: TextStyle(color: card.type == CardType.abHash ? Colors.white : const Color(0xFFE94560), fontSize: 12, fontWeight: FontWeight.bold))])),
          const Spacer(),
          if (card.type == CardType.question) Text('#${card.id.replaceAll('q', '')}', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14)),
        ]),
        const SizedBox(height: 16),
        Expanded(child: Center(child: card.type == CardType.abHash
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('AB#', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4)),
              const SizedBox(height: 12),
              Text('استخدم قوة هذه البطاقة بحكمة\nللتعبير والانفتاح بشكل أعمق', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.6)),
            ])
          : Text(card.text, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, height: 1.6)))),
      ])),
    );
  }

  // ─── Action Area ───
  Widget _actionArea() {
    switch (_state.phase) {
      case GamePhase.drawingCard: return const SizedBox.shrink();
      case GamePhase.selectingResponder: return _responderSelection();
      case GamePhase.rollingDie: return _dieRolling();
      case GamePhase.responding:
      case GamePhase.discussion: return _dieResult();
    }
  }

  Widget _responderSelection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('اختر الشخص اللي هيجاوب', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: _state.players.where((p) => p.id != _state.currentPlayer?.id).map((p) => GestureDetector(
      onTap: () => _selectResponder(p.id),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: const Color(0xFF533483).withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF533483).withOpacity(0.5))),
        child: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 15))),
    )).toList()),
    const SizedBox(height: 16),
    if (_state.currentCard?.type == CardType.free) TextField(
      textDirection: TextDirection.rtl, decoration: InputDecoration(hintText: 'اكتب سؤالك الحر هنا...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      style: const TextStyle(color: Colors.white, fontSize: 15), onChanged: (v) => setState(() => _state = GameEngine.setCustomQuestion(_state, v))),
    ),
  ]);

  Widget _dieRolling() {
    final faces = DieFace.values;
    final idx = (_dieCtrl.value * faces.length * 3).floor() % faces.length;
    return AnimatedBuilder(animation: _dieCtrl, builder: (_, __) => Transform.rotate(angle: _dieCtrl.value * pi * 4, child: _dieWidget(faces[idx])));
  }

  Widget _dieResult() {
    final face = _state.currentDieFace;
    if (face == null) return const SizedBox.shrink();
    final responder = _state.players.where((p) => p.id == _state.selectedResponderId).firstOrNull;
    return Column(children: [
      _dieWidget(face),
      const SizedBox(height: 16),
      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: face.color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: face.color.withOpacity(0.3))),
        child: Column(children: [
          Text('${face.emoji}  ${face.label}  ${face.emoji}', style: TextStyle(color: face.color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(face.description, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.5)),
          if (responder != null) ...[const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: face.color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(face == DieFace.everyone ? 'الجميع يجاوبون!' : '${responder.name} يجاوب', style: TextStyle(color: face.color, fontWeight: FontWeight.bold, fontSize: 14)))],
          if (_state.isAbHashActive) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('AB# نشطة - انفتاح عميق!', style: TextStyle(color: Color(0xFFE94560), fontWeight: FontWeight.bold, fontSize: 13)))],
        ])),
    ]);
  }

  Widget _dieWidget(DieFace face) => Container(
    width: 100, height: 100,
    decoration: BoxDecoration(gradient: LinearGradient(colors: [face.color, face.color.withOpacity(0.7)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: face.color.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)]),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(face.emoji, style: const TextStyle(fontSize: 32)), const SizedBox(height: 4), Text(face.label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)])),
  );

  // ─── Bottom Bar ───
  Widget _bottomBar() {
    final p = _state.currentPlayer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: 50, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _state.players.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final pl = _state.players[i];
            final isCur = pl.id == p?.id;
            return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isCur ? const Color(0xFFE94560).withOpacity(0.3) : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: isCur ? const Color(0xFFE94560) : Colors.white.withOpacity(0.1))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (isCur) const Icon(Icons.arrow_back_rounded, color: Color(0xFFE94560), size: 14),
                const SizedBox(width: 4),
                Text(pl.name, style: TextStyle(color: isCur ? const Color(0xFFE94560) : Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: isCur ? FontWeight.bold : FontWeight.normal)),
                const SizedBox(width: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text('${pl.abHashCards}', style: const TextStyle(color: Color(0xFFE94560), fontSize: 10, fontWeight: FontWeight.bold))),
              ]));
          })),
        const SizedBox(height: 12),
        Row(children: [
          if (p != null && p.hasAbHashCards && (_state.phase == GamePhase.drawingCard || _state.phase == GamePhase.selectingResponder))
            Expanded(child: _actionBtn('AB# استخدم', Icons.tag_rounded, const Color(0xFFE94560), _useAbHash)),
          if (p != null && p.hasAbHashCards && (_state.phase == GamePhase.drawingCard || _state.phase == GamePhase.selectingResponder))
            const SizedBox(width: 10),
          if (_state.phase == GamePhase.responding || _state.phase == GamePhase.discussion)
            Expanded(child: _actionBtn('الدور التالي', Icons.arrow_forward_rounded, const Color(0xFF06D6A0), _nextTurn)),
          if (_state.isGameOver)
            Expanded(child: _actionBtn('انتهت اللعبة', Icons.celebration_rounded, const Color(0xFFE9B044), () => _showGameOver())),
        ]),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.5))),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 20), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold))]),
  ));

  void _showGameOver() => showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
    backgroundColor: const Color(0xFF1A1A2E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: const Center(child: Text('انتهت اللعبة! 🎉', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('شكراً لكم على هذه اللحظات الرائعة\nتحدثوا بصراحة، عرفوا أنفسكم أكتر', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6)),
      const SizedBox(height: 20),
      ..._state.players.map((p) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [const Icon(Icons.person_rounded, color: Color(0xFFE94560), size: 18), const SizedBox(width: 8), Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 15)), const Spacer(), Text('${p.abHashCards} AB# متبقية', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12))]))),
    ]),
    actions: [
      TextButton(
        onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: const Color(0xFFE94560), borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Text('العودة للرئيسية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ),
      ),
    ],
  ));
}
