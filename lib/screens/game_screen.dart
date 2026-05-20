import 'dart:math';
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/die_face.dart';
import '../utils/game_engine.dart';
import '../widgets/pulse_widget.dart';

class GameScreen extends StatefulWidget {
  final List<String> playerNames;
  final String packId;
  const GameScreen({super.key, required this.playerNames, required this.packId});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState _state;
  late AnimationController _dieCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _cardRevealCtrl;

  // Die animation state
  DieFace? _dieFinalFace;
  bool _isDieRolling = false;
  bool _cardRevealed = false;

  @override
  void initState() {
    super.initState();
    _state = GameEngine.initializeGame(widget.playerNames, widget.packId);
    _dieCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _cardRevealCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() { _dieCtrl.dispose(); _pulseCtrl.dispose(); _cardRevealCtrl.dispose(); super.dispose(); }

  void _drawCard() {
    setState(() {
      _state = GameEngine.drawCard(_state);
      _cardRevealed = false;
    });
    _cardRevealCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _cardRevealed = true);
    });
  }

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
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1A0808), Color(0xFF0F0505), Color(0xFF0A0A0A)],
          ),
        ),
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
    decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
    child: Row(children: [
      IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white38), onPressed: () => Navigator.pop(context)),
      const Spacer(),
      _badge('${_state.remainingCards} بطاقة', const Color(0xFFE94560), Icons.style_rounded),
      const SizedBox(width: 8),
      _badge('${_state.players.length} لاعب', const Color(0xFFE94560), Icons.people_rounded),
    ]),
  );

  Widget _badge(String text, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
    child: Row(children: [Icon(icon, color: color, size: 14), const SizedBox(width: 4), Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))]),
  );

  // ─── Current Player ───
  Widget _playerIndicator() {
    final p = _state.currentPlayer;
    if (p == null) return const SizedBox.shrink();
    return PulseWidget(animation: _pulseCtrl, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE94560).withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE94560).withOpacity(0.2), width: 1),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Avatar circle
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(colors: [Color(0xFFE94560), Color(0xFFC23152)]),
            boxShadow: [BoxShadow(color: const Color(0xFFE94560).withOpacity(0.3), blurRadius: 8)],
          ),
          child: Center(child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ),
        const SizedBox(width: 12),
        Text('دور: ${p.name}', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Text('${p.abHashCards} AB#', style: const TextStyle(color: Color(0xFFE94560), fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ]),
    ));
  }

  // ─── Draw Pile ───
  Widget _drawPile() => GestureDetector(onTap: _drawCard, child: Container(
    height: 280,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: const Color(0xFF1A1A1A),
      border: Border.all(color: const Color(0xFFE94560).withOpacity(0.15), width: 1.5),
      boxShadow: [BoxShadow(color: const Color(0xFFE94560).withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10))],
    ),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE94560).withOpacity(0.3), width: 1.5),
        ),
        child: const Icon(Icons.touch_app_rounded, color: Color(0xFFE94560), size: 36),
      ),
      const SizedBox(height: 20),
      const Text('اسحب بطاقة', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('اضغط لسحب البطاقة العلوية', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
    ])),
  ));

  // ─── Revealed Card with slide-up animation ───
  Widget _revealedCard() {
    final card = _state.currentCard;
    if (card == null) return const SizedBox.shrink();

    Color c1, c2;
    IconData icon;
    String label;
    switch (card.type) {
      case CardType.question: c1 = const Color(0xFF1A1A1A); c2 = const Color(0xFF111111); icon = Icons.question_answer_rounded; label = card.category ?? 'سؤال'; break;
      case CardType.free: c1 = const Color(0xFFE94560); c2 = const Color(0xFFC23152); icon = Icons.card_giftcard_rounded; label = 'حرية'; break;
      case CardType.abHash: c1 = const Color(0xFFE94560); c2 = const Color(0xFFC23152); icon = Icons.tag_rounded; label = 'AB# - انفتاح عميق'; break;
    }

    return AnimatedBuilder(
      animation: _cardRevealCtrl,
      builder: (_, __) {
        final progress = Curves.easeOutCubic.transform(_cardRevealCtrl.value);
        return Transform.translate(
          offset: Offset(0, (1 - progress) * 60),
          child: Opacity(
            opacity: progress,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: [c1, c2]),
                border: Border.all(
                  color: card.type == CardType.abHash ? const Color(0xFFE94560).withOpacity(0.6) : Colors.white.withOpacity(0.08),
                  width: card.type == CardType.abHash ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFE94560).withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
                ],
              ),
              child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  // Category pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: card.type == CardType.abHash ? Colors.white.withOpacity(0.15) : const Color(0xFFE94560).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: card.type == CardType.abHash ? Colors.white.withOpacity(0.2) : const Color(0xFFE94560).withOpacity(0.3), width: 0.5),
                    ),
                    child: Row(children: [
                      Icon(icon, color: card.type == CardType.abHash ? Colors.white70 : const Color(0xFFE94560), size: 12),
                      const SizedBox(width: 4),
                      Text(label, style: TextStyle(color: card.type == CardType.abHash ? Colors.white70 : const Color(0xFFE94560), fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const Spacer(),
                  if (card.type == CardType.question) Text('#${card.id.replaceAll('q', '')}', style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 13)),
                ]),
                const SizedBox(height: 20),
                Expanded(child: Center(child: card.type == CardType.abHash
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('AB#', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4)),
                      const SizedBox(height: 12),
                      Text('استخدم قوة هذه البطاقة بحكمة\nللتعبير والانفتاح بشكل أعمق', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.6)),
                    ])
                  : Text(card.text, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, height: 1.6)))),
              ])),
            ),
          ),
        );
      },
    );
  }

  // ─── Action Area ───
  Widget _actionArea() {
    switch (_state.phase) {
      case GamePhase.drawingCard: return const SizedBox.shrink();
      case GamePhase.selectingResponder: return _responderSelection();
      case GamePhase.rollingDie: return _dieRolling3D();
      case GamePhase.responding:
      case GamePhase.discussion: return _dieResult();
    }
  }

  Widget _responderSelection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('اختر الشخص اللي هيجاوب', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: _state.players.where((p) => p.id != _state.currentPlayer?.id).map((p) => GestureDetector(
      onTap: () => _selectResponder(p.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE94560).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE94560).withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFFE94560), Color(0xFFC23152)])),
            child: Center(child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 8),
          Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ]),
      ),
    )).toList()),
    const SizedBox(height: 16),
    if (_state.currentCard?.type == CardType.free) TextField(
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: 'اكتب سؤالك الحر هنا...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE94560), width: 1)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      onChanged: (v) => setState(() => _state = GameEngine.setCustomQuestion(_state, v)),
    ),
  ]);

  // ─── 3D Die Rolling Animation ───
  Widget _dieRolling3D() {
    return AnimatedBuilder(
      animation: _dieCtrl,
      builder: (_, __) {
        final progress = _dieCtrl.value;

        // Determine displayed face based on progress
        DieFace displayFace;
        if (progress < 0.5) {
          final speed = 12.0;
          final idx = (progress * speed).floor() % DieFace.values.length;
          displayFace = DieFace.values[idx];
        } else if (progress < 0.85) {
          final slowSpeed = 4.0;
          final idx = ((progress - 0.5) * slowSpeed + 6).floor() % DieFace.values.length;
          displayFace = DieFace.values[idx];
        } else {
          displayFace = _dieFinalFace ?? DieFace.values.first;
        }

        // 3D rotation: rotate around X and Y axes simultaneously
        // Fast at start, decelerating (easeOutCubic)
        double easedProgress = Curves.easeOutCubic.transform(progress);
        double rotX = easedProgress * pi * 4; // 2 full rotations around X
        double rotY = easedProgress * pi * 6; // 3 full rotations around Y

        // Scale: slight bounce at the end
        double scale = 1.0;
        if (progress > 0.85) {
          final bounceProgress = (progress - 0.85) / 0.15;
          scale = 1.0 + sin(bounceProgress * pi) * 0.08;
        }

        // Shadow scale during roll
        double shadowScale = 0.6 + (1.0 - progress) * 0.4;
        double shadowOpacity = 0.15 + (1.0 - progress) * 0.15;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D Die with perspective
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002) // perspective
                ..scale(scale)
                ..rotateX(rotX)
                ..rotateY(rotY),
              child: _build3dDieFace(displayFace),
            ),
            const SizedBox(height: 16),
            // Animated shadow beneath die
            Transform.scale(
              scale: shadowScale,
              child: Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: const Color(0xFFE94560).withOpacity(shadowOpacity),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE94560).withOpacity(shadowOpacity * 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Build a single 3D die face ───
  Widget _build3dDieFace(DieFace face) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE94560), Color(0xFFC23152), Color(0xFFB71C1C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: const Color(0xFFE94560).withOpacity(0.2),
            blurRadius: 60,
            spreadRadius: 8,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Stack(
        children: [
          // Subtle inner highlight
          Positioned(
            top: 4, left: 4, right: 4, bottom: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Die face content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(face.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 4),
                Text(face.label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Die Result ───
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
      // 3D die showing result
      _build3dDieFace(face),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE94560).withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE94560).withOpacity(0.15)),
        ),
        child: Column(children: [
          Text('${face.emoji}  ${face.label}  ${face.emoji}', style: const TextStyle(color: Color(0xFFE94560), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(face.description, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, height: 1.5)),
          if (responder != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(face == DieFace.everyone ? 'الجميع يجاوبون!' : '${responder.name} يجاوب', style: const TextStyle(color: Color(0xFFE94560), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
          if (_state.isAbHashActive) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(abHashUserName != null ? '$abHashUserName استخدم AB# - عايز يتكلم أكتر!' : 'AB# نشطة - انفتاح عميق!', style: const TextStyle(color: Color(0xFFE94560), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ]),
      ),
    ]);
  }

  // ─── Bottom Bar ───
  Widget _bottomBar() {
    final p = _state.currentPlayer;
    final isRespondingOrDiscussion = _state.phase == GamePhase.responding || _state.phase == GamePhase.discussion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A).withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Player list as rounded chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _state.players.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final pl = _state.players[i];
              final isCur = pl.id == p?.id;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCur ? const Color(0xFFE94560).withOpacity(0.15) : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isCur ? const Color(0xFFE94560).withOpacity(0.5) : Colors.white.withOpacity(0.06)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  // Mini avatar
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCur ? const Color(0xFFE94560).withOpacity(0.3) : Colors.white.withOpacity(0.06),
                    ),
                    child: Center(
                      child: Text(
                        pl.name.isNotEmpty ? pl.name[0].toUpperCase() : '?',
                        style: TextStyle(color: isCur ? const Color(0xFFE94560) : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(pl.name, style: TextStyle(color: isCur ? const Color(0xFFE94560) : Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: isCur ? FontWeight.bold : FontWeight.normal)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFE94560).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text('${pl.abHashCards}', style: const TextStyle(color: Color(0xFFE94560), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ]),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // AB# buttons for ALL players during responding/discussion phase
        if (isRespondingOrDiscussion) ...[
          Wrap(spacing: 6, runSpacing: 6, children: _state.players.where((pl) => pl.hasAbHashCards).map((pl) => GestureDetector(
            onTap: () => _useAbHashAsPlayer(pl.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE94560).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE94560).withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.tag_rounded, color: Color(0xFFE94560), size: 14),
                const SizedBox(width: 4),
                Text('${pl.name} AB#', style: const TextStyle(color: Color(0xFFE94560), fontSize: 12, fontWeight: FontWeight.bold)),
              ]),
            ),
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
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFC23152), Color(0xFFE94560)]),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: const Color(0xFFE94560).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))]),
  ));

  void _showGameOver() => showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
    backgroundColor: const Color(0xFF111111),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: const Color(0xFFE94560).withOpacity(0.2))),
    title: const Center(child: Text('انتهت اللعبة! 🎉', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('شكراً لكم على هذه اللحظات الرائعة\nتحدثوا بصراحة، عرفوا أنفسكم أكتر', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 15, height: 1.6)),
      const SizedBox(height: 20),
      ..._state.players.map((p) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.04))),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFFE94560), Color(0xFFC23152)])),
            child: Center(child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 10),
          Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 15)),
          const Spacer(),
          Text('${p.abHashCards} AB# متبقية', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
        ]),
      )),
    ]),
    actions: [
      TextButton(
        onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFC23152), Color(0xFFE94560)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(child: Text('العودة للرئيسية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ),
      ),
    ],
  ));
}
