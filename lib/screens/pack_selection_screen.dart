import 'package:flutter/material.dart';
import 'game_setup_screen.dart';
import '../utils/game_engine.dart';
import '../widgets/pulse_widget.dart';

class PackSelectionScreen extends StatefulWidget {
  const PackSelectionScreen({super.key});
  @override
  State<PackSelectionScreen> createState() => _PackSelectionScreenState();
}

class _PackSelectionScreenState extends State<PackSelectionScreen> with SingleTickerProviderStateMixin {
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
    final packs = GameEngine.allPacks;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
        child: SafeArea(
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                const Spacer(),
                const Text('اختر الباكدج', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                const SizedBox(width: 48),
              ]),
            ),
            // Packs grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: packs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final pack = packs[index];
                    return _packCard(pack);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _packCard(QuestionPack pack) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GameSetupScreen(packId: pack.id))),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [pack.color.withOpacity(0.15), pack.color.withOpacity(0.05)],
          ),
          border: Border.all(color: pack.color.withOpacity(0.4), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Icon
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: pack.color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(pack.icon, color: pack.color, size: 22),
            ),
            const SizedBox(height: 12),
            // Name
            Text(pack.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            // Description
            Text(pack.description, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            // Stats
            Row(children: [
              _miniStat('${pack.questionCount}', Icons.help_outline_rounded, pack.color),
              const SizedBox(width: 8),
              _miniStat('${pack.freeCount}', Icons.card_giftcard_rounded, pack.color),
              const SizedBox(width: 8),
              _miniStat('${pack.abHashCount}', Icons.tag_rounded, pack.color),
            ]),
            const SizedBox(height: 8),
            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: pack.color, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('${pack.totalCards} بطاقة', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _miniStat(String value, IconData icon, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 12),
      const SizedBox(width: 2),
      Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    ]);
  }
}
