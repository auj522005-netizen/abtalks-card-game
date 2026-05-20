import 'package:flutter/material.dart';

enum CardType { question, free, abHash }

class GameCard {
  final String id;
  final String text;
  final CardType type;
  final String? category;
  final bool isUsed;

  const GameCard({
    required this.id,
    required this.text,
    required this.type,
    this.category,
    this.isUsed = false,
  });

  GameCard copyWith({bool? isUsed}) {
    return GameCard(
      id: id,
      text: text,
      type: type,
      category: category,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  Color get cardColor {
    switch (type) {
      case CardType.question:
        return const Color(0xFF1A1A2E);
      case CardType.free:
        return const Color(0xFF533483);
      case CardType.abHash:
        return const Color(0xFFE94560);
    }
  }
}
