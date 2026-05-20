import 'package:flutter/material.dart';

enum CardType { question, free, abHash }

class GameCard {
  final String id;
  final String text;
  final CardType type;
  final String? category;
  final String? packId;
  final bool isUsed;

  const GameCard({
    required this.id,
    required this.text,
    required this.type,
    this.category,
    this.packId,
    this.isUsed = false,
  });

  GameCard copyWith({bool? isUsed}) {
    return GameCard(
      id: id,
      text: text,
      type: type,
      category: category,
      packId: packId,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  Color get cardColor {
    switch (type) {
      case CardType.question:
        return const Color(0xFF1A1A1A);
      case CardType.free:
        return const Color(0xFFD32F2F);
      case CardType.abHash:
        return const Color(0xFFD32F2F);
    }
  }
}

// ─── Question Pack Model ───

class QuestionPack {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<GameCard> cards;

  const QuestionPack({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.cards,
  });

  int get questionCount => cards.where((c) => c.type == CardType.question).length;
  int get freeCount => cards.where((c) => c.type == CardType.free).length;
  int get abHashCount => cards.where((c) => c.type == CardType.abHash).length;
  int get totalCards => cards.length;
}
