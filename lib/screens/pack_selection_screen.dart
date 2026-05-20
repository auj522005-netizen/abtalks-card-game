import 'package:flutter/material.dart';
import 'game_setup_screen.dart';
import '../models/card_model.dart';
import '../utils/game_engine.dart';

class PackSelectionScreen extends StatefulWidget {
  const PackSelectionScreen({super.key});
  @override
  State<PackSelectionScreen> createState() => _PackSelectionScreenState();
}

class _PackSelectionScreenState extends State<PackSelectionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final packs = GameEngine.allPacks;

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
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text('اختر الباكدج', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const Spacer(),
                const SizedBox(width: 48),
              ]),
            ),
            // Packs grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  itemCount: packs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.68,
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
            colors: [
              pack.color.withOpacity(0.12),
              pack.color.withOpacity(0.04),
              const Color(0xFF0A0A0A).withOpacity(0.9),
            ],
          ),
          border: Border.all(color: pack.color.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: pack.color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Icon + color dot
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: pack.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: pack.color.withOpacity(0.3), width: 1),
                ),
                child: Icon(pack.icon, color: pack.color, size: 20),
              ),
              const Spacer(),
              // Color indicator dot
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: pack.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: pack.color.withOpacity(0.5), blurRadius: 6),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 14),
            // Name
            Text(pack.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            // Description
            Text(pack.description, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            // Bottom stats strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A).withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pillStat('${pack.questionCount}Q', pack.color),
                  _pillStat('${pack.freeCount}F', pack.color),
                  _pillStat('${pack.abHashCount}AB', pack.color),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _pillStat(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
    );
  }
}
