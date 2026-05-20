import 'package:flutter/material.dart';
import 'game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});
  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final List<String> _players = [];

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _add() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _players.length >= 10) return;
    if (_players.contains(name)) { _snack('هذا الاسم موجود بالفعل'); return; }
    setState(() { _players.add(name); _nameCtrl.clear(); });
  }

  void _remove(int i) => setState(() => _players.removeAt(i));

  void _start() {
    if (_players.length < 2) { _snack('الحد الأدنى 2 لاعبين'); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(playerNames: _players)));
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFE94560), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)), title: const Text('إعداد اللعبة', style: TextStyle(color: Colors.white, fontSize: 18)), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)])),
        child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          const SizedBox(height: 10),
          Text('أضف اللاعبين', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 6),
          Text('الحد الأدنى 2 - الأقصى 10', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Row(children: [
              Expanded(child: TextField(controller: _nameCtrl, textDirection: TextDirection.rtl, decoration: InputDecoration(hintText: 'اسم اللاعب...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)), style: const TextStyle(color: Colors.white, fontSize: 16), onSubmitted: (_) => _add())),
              Container(margin: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFE94560), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.add_rounded, color: Colors.white), onPressed: _add)),
            ]),
          ),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: _players.length >= 2 ? const Color(0xFF06D6A0).withOpacity(0.15) : const Color(0xFFE94560).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_players.length >= 2 ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: _players.length >= 2 ? const Color(0xFF06D6A0) : const Color(0xFFE94560), size: 16), const SizedBox(width: 6), Text('${_players.length} لاعب', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14))])),
          const SizedBox(height: 16),
          Expanded(child: _players.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline_rounded, size: 64, color: Colors.white.withOpacity(0.1)), const SizedBox(height: 16), Text('أضف لاعبين للبدء', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16))])) : ListView.builder(itemCount: _players.length, itemBuilder: (_, i) => _playerTile(i))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _players.length >= 2 ? _start : null, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560), disabledBackgroundColor: const Color(0xFFE94560).withOpacity(0.3), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('ابدأ اللعبة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
        ])),
      ),
    );
  }

  final _colors = const [Color(0xFFE94560), Color(0xFF533483), Color(0xFF0F3460), Color(0xFFE9B044), Color(0xFF00B4D8), Color(0xFF06D6A0), Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFFA8E6CF), Color(0xFFFFD93D)];

  Widget _playerTile(int i) {
    final c = _colors[i % _colors.length];
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.3))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(0.3), shape: BoxShape.circle), child: Center(child: Text(_players[i].isNotEmpty ? _players[i][0].toUpperCase() : '?', style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_players[i], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)), Text('2 بطاقة AB#', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12))])),
        IconButton(icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.3), size: 20), onPressed: () => _remove(i)),
      ]));
  }
}
