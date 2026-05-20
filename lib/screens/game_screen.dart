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

  // Die animation state
  DieFace? _dieFinalFace;
  bool _isDieRolling = false;
  late Animation<double> _dieScale;

  @override
  void initState() {
    super.initState();
    _state = GameEngine.initializeGame(widget.playerNames);
    _dieCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);

    // Scale bounce animation for die
    _dieScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6).chain(CurveTween(curve: Curves.easeIn)), weight: 0.05),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), weight: 0.1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.8).chain(CurveTween(curve: Curves.easeIn)), weight: 0.1),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 0.15),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.92).chain(CurveTween(curve: Curves.easeIn)), weight: 0.15),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.05).chain(CurveTween(curve: Curves.easeOut)), weight: 0.2),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 0.25),
    ]).animate(_dieCtrl);
  }

  @override
  void dispose() { _dieCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  void _drawCard() => setState(() => _state = GameEngine.drawCard(_state));

  void _selectResponder(String id) {
    setState(() => _state = GameEngine.selectResponder(_state, id));
    _rollDie();
  }

  void _rollDie() {
    // Pre-determine the final face
    final faces = DieFace.values;
    _dieFinalFace = faces[Random().nextInt(faces.length)];
    _isDieRolling = true;

    _dieCtrl.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        final nextPhase = (_dieFinalFace == DieFace.everyone) ? GamePhase.discussion : GamePhase.responding;
        _state = _state.copyWith(currentDieFace: _dieFinalFace, phase: nextPhase);
        _isDieRolling = false;
      });
    });
  }

  void _nextTurn() => setState(() => _state = GameEngine.nextTurn(_state));
  void _useAbHash() => setState(() => _state = GameEngine.useAbHashCard(_state));
  void _useAbHashAsPlayer(String playerId) => setState(() => _state = GameEngine.useAbHashAsAnyPlayer(_state, playerId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)])),
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
      _badge('${_state.players.length} لاعب', const Color(0xFFE94560), Icons.people_rounded),
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
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFF1A1A1A), border: Border.all(color: const Color(0xFFE94560).withOpacity(0.3), width: 2), boxShadow: [BoxShadow(color: const Color(0xFFE94560).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
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
      case CardType.question: c1 = const Color(0xFF1A1A1A); c2 = const Color(0xFF0A0A0A); icon = Icons.question_answer_rounded; label = card.category ?? 'سؤال'; break;
      case CardType.free: c1 = const Color(0xFFE94560); c2 = const Color(0xFFC23152); icon = Icons.card_giftcard_rounded; label = 'حرية'; break;
      case CardType.abHash: c1 = const Color(0xFFE94560); c2 = const Color(0xFFC23152); icon = Icons.tag_rounded; label = 'AB# - انفتاح عميق'; break;
    }

    return Container(
      height: 280,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [c1, c2]), border: Border.all(color: card.type == CardType.abHash ? const Color(0xFFE94560) : Colors.white.withOpacity(0.15), width: card.type == CardType.abHash ? 2.5 : 1.5), boxShadow: [BoxShadow(color: const Color(0xFFE94560).withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10))]),
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
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE94560).withOpacity(0.5))),
        child: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 15))),
    )).toList()),
    const SizedBox(height: 16),
    if (_state.currentCard?.type == CardType.free) TextField(
      textDirection: TextDirection.rtl, decoration: InputDecoration(hintText: 'اكتب سؤالك الحر هنا...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      onChanged: (v) => setState(() => _state = GameEngine.setCustomQuestion(_state, v)),
    ),
  ]);

  // ─── Realistic Die Rolling Animation ───
  Widget _dieRolling() {
    return AnimatedBuilder(
      animation: _dieCtrl,
      builder: (_, __) {
        final progress = _dieCtrl.value;

        // Determine displayed face based on progress
        DieFace displayFace;
        if (progress < 0.5) {
          // Phase 1: Rapid random faces (0-1s)
          final speed = 12.0;
          final idx = (progress * speed).floor() % DieFace.values.length;
          displayFace = DieFace.values[idx];
        } else if (progress < 0.85) {
          // Phase 2: Slowing down (1-1.7s)
          final slowSpeed = 4.0;
          final idx = ((progress - 0.5) * slowSpeed + 6).floor() % DieFace.values.length;
          displayFace = DieFace.values[idx];
        } else {
          // Phase 3: Final face locked (1.7-2s)
          displayFace = _dieFinalFace ?? DieFace.values.first;
        }

        // Rotation: fast spin then slow
        double rotation;
        if (progress < 0.5) {
          rotation = progress * pi * 12; // Fast spin
        } else if (progress < 0.85) {
          rotation = pi * 6 + (progress - 0.5) * pi * 6; // Slowing
        } else {
          rotation = pi * 8.1 + (progress - 0.85) * pi * 0.5; // Nearly stopped
        }

        // Scale: bouncing effect
        final scale = _dieScale.value;

        // Shake: rapid small horizontal displacement that decreases
        double shakeX = 0;
        double shakeY = 0;
        if (progress < 0.5) {
          shakeX = sin(progress * 100) * (1 - progress * 2) * 6;
          shakeY = cos(progress * 80) * (1 - progress * 2) * 4;
        } else if (progress < 0.85) {
          shakeX = sin(progress * 60) * (1 - progress) * 3;
          shakeY = cos(progress * 50) * (1 - progress) * 2;
        } else {
          shakeX = sin(progress * 30) * (1 - progress) * 1;
        }

        return Transform.translate(
          offset: Offset(shakeX, shakeY),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: _dieWidget(displayFace),
            ),
          ),
        );
      },
    );
  }

  Widget _dieResult() {
    final face = _state.currentDieFace;
    if (face == null) return const SizedBox.shrink();
    final responder = _state.players.where((p) => p.id == _state.selectedResponderId).firstOrNull;

    // Find AB# user name
    String? abHashUserName;
    if (_state.isAbHashActive && _state.abHashUserId != null) {
      final abHashUser = _state.players.where((p) => p.id == _state.abHashUserId).firstOrNull;
      abHashUserName = abHashUser?.name;
    }

    return Column(children: [
      _dieWidget(face),
      const SizedBox(height: 16),
      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE94560).withOpacity(0.3))),
        child: Column(children: [
          Text('${face.emoji}  ${face.label}  ${face.emoji}', style: const TextStyle(color: Color(0xFFE94560), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(face.description, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.5)),
          if (responder != null) ...[const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(face == DieFace.everyone ? 'الجميع يجاوبون!' : '${responder.name} يجاوب', style: const TextStyle(color: Color(0xFFE94560), fontWeight: FontWeight.bold, fontSize: 14)))],
          if (_state.isAbHashActive) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(abHashUserName != null ? '$abHashUserName استخدم AB# - عايز يتكلم أكتر!' : 'AB# نشطة - انفتاح عميق!', style: const TextStyle(color: Color(0xFFE94560), fontWeight: FontWeight.bold, fontSize: 13)))],
        ])),
    ]);
  }

  Widget _dieWidget(DieFace face) => Container(
    width: 100, height: 100,
    decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFFE94560), const Color(0xFFE94560).withOpacity(0.7)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFFE94560).withOpacity(0.3), blurRadius: 15, spreadRadius: 2)]),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(face.emoji, style: const TextStyle(fontSize: 32)), const SizedBox(height: 4), Text(face.label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)])),
  );

  // ─── Bottom Bar ───
  Widget _bottomBar() {
    final p = _state.currentPlayer;
    final isRespondingOrDiscussion = _state.phase == GamePhase.responding || _state.phase == GamePhase.discussion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Player list
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

        // AB# buttons for ALL players during responding/discussion phase
        if (isRespondingOrDiscussion) ...[
          Wrap(spacing: 6, runSpacing: 6, children: _state.players.where((pl) => pl.hasAbHashCards).map((pl) => GestureDetector(
            onTap: () => _useAbHashAsPlayer(pl.id),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE94560).withOpacity(0.5))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.tag_rounded, color: Color(0xFFE94560), size: 14),
                const SizedBox(width: 4),
                Text('${pl.name} AB#', style: const TextStyle(color: Color(0xFFE94560), fontSize: 12, fontWeight: FontWeight.bold)),
              ])),
          )).toList()),
          const SizedBox(height: 8),
        ],

        // AB# for current player during drawing/selecting phase
        if (p != null && p.hasAbHashCards && (_state.phase == GamePhase.drawingCard || _state.phase == GamePhase.selectingResponder))
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            Expanded(child: _actionBtn('AB# استخدم', Icons.tag_rounded, const Color(0xFFE94560), _useAbHash)),
          ])),

        // Next turn / Game over buttons
        Row(children: [
          if (isRespondingOrDiscussion)
            Expanded(child: _actionBtn('الدور التالي', Icons.arrow_forward_rounded, const Color(0xFFE94560), _nextTurn)),
          if (_state.isGameOver)
            Expanded(child: _actionBtn('انتهت اللعبة', Icons.celebration_rounded, const Color(0xFFE94560), () => _showGameOver())),
        ]),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.5))),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 20), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold))]),
  ));

  void _showGameOver() => showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
    backgroundColor: const Color(0xFF1A1A1A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
