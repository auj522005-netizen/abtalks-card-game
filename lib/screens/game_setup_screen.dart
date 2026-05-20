import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';
import '../utils/game_engine.dart';

class GameSetupScreen extends StatefulWidget {
  final String packId;
  const GameSetupScreen({super.key, required this.packId});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final List<String> _players = [];
  List<String> _savedNames = [];

  @override
  void initState() {
    super.initState();
    _loadSavedNames();
  }

  Future<void> _loadSavedNames() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedNames = prefs.getStringList('abtalks_saved_players') ?? [];
    });
  }

  Future<void> _saveNames() async {
    final prefs = await SharedPreferences.getInstance();
    final allNames = <String>{..._savedNames, ..._players}.toList();
    await prefs.setStringList('abtalks_saved_players', allNames);
    setState(() { _savedNames = allNames; });
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _add() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _players.length >= 10) return;
    if (_players.contains(name)) { _snack('هذا الاسم موجود بالفعل'); return; }
    setState(() { _players.add(name); _nameCtrl.clear(); });
    _saveNames();
  }

  void _addFromSaved(String name) {
    if (_players.contains(name) || _players.length >= 10) return;
    setState(() { _players.add(name); });
  }

  void _remove(int i) => setState(() => _players.removeAt(i));

  void _start() {
    if (_players.length < 2) { _snack('الحد الأدنى 2 لاعبين'); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(playerNames: _players, packId: widget.packId)));
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFD32F2F), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  @override
  Widget build(BuildContext context) {
    final pack = GameEngine.allPacks.firstWhere((p) => p.id == widget.packId, orElse: () => GameEngine.allPacks.first);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)), title: Text('إعداد اللعبة - ${pack.name}', style: const TextStyle(color: Colors.white, fontSize: 16)), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
        child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          // Pack info bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: pack.color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: pack.color.withOpacity(0.3))),
            child: Row(children: [
              Icon(pack.icon, color: pack.color, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pack.name, style: TextStyle(color: pack.color, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('${pack.questionCount} سؤال + ${pack.freeCount} حر + ${pack.abHashCount} AB#', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),

          Text('أضف اللاعبين', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 4),
          Text('الحد الأدنى 2 - الأقصى 10', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 16),

          // Input field
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Row(children: [
              Expanded(child: TextField(controller: _nameCtrl, textDirection: TextDirection.rtl, decoration: InputDecoration(hintText: 'اسم اللاعب...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)), style: const TextStyle(color: Colors.white, fontSize: 16), onSubmitted: (_) => _add())),
              Container(margin: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFD32F2F), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.add_rounded, color: Colors.white), onPressed: _add)),
            ]),
          ),

          // Saved names chips
          if (_savedNames.isNotEmpty && _players.length < 10) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _savedNames.where((n) => !_players.contains(n)).length, separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final available = _savedNames.where((n) => !_players.contains(n)).toList();
                  if (i >= available.length) return const SizedBox.shrink();
                  final name = available[i];
                  return GestureDetector(
                    onTap: () => _addFromSaved(name),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.15))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.add_rounded, color: Color(0xFFD32F2F), size: 14),
                        const SizedBox(width: 4),
                        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ])),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFD32F2F).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_players.length >= 2 ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: const Color(0xFFD32F2F), size: 16), const SizedBox(width: 6), Text('${_players.length} لاعب', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14))])),
          const SizedBox(height: 12),

          Expanded(child: _players.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline_rounded, size: 64, color: Colors.white.withOpacity(0.1)), const SizedBox(height: 16), Text('أضف لاعبين للبدء', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16))])) : ListView.builder(itemCount: _players.length, itemBuilder: (_, i) => _playerTile(i))),
          const SizedBox(height: 16),

          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _players.length >= 2 ? _start : null, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), disabledBackgroundColor: const Color(0xFFD32F2F).withOpacity(0.3), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('ابدأ اللعبة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
        ])),
      ),
    );
  }

  Widget _playerTile(int i) {
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFD32F2F).withOpacity(0.2), shape: BoxShape.circle), child: Center(child: Text(_players[i].isNotEmpty ? _players[i][0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_players[i], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)), Text('2 بطاقة AB#', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12))])),
        IconButton(icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.3), size: 20), onPressed: () => _remove(i)),
      ]));
  }
}
