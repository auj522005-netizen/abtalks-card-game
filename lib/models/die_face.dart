import 'package:flutter/material.dart';

enum DieFace {
  story(
    label: 'قصة',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFFE94560),
    description: 'أخبرنا بقصة',
    emoji: '📖',
  ),
  reverse(
    label: 'اعكس',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFFE94560),
    description: 'اطلب من السائل الإجابة',
    emoji: '🔄',
  ),
  oneWord(
    label: 'كلمة واحدة',
    icon: Icons.text_fields_rounded,
    color: Color(0xFFE94560),
    description: 'أجب بكلمة واحدة فقط',
    emoji: '💬',
  ),
  honest(
    label: 'كن صريحاً',
    icon: Icons.favorite_rounded,
    color: Color(0xFFE94560),
    description: 'أجب بصراحة وبدون خوف',
    emoji: '💎',
  ),
  open(
    label: 'كن منفتحاً',
    icon: Icons.lock_open_rounded,
    color: Color(0xFFE94560),
    description: 'أجب بشفافية وانفتاح عاطفي',
    emoji: '🔓',
  ),
  everyone(
    label: 'الجميع',
    icon: Icons.groups_rounded,
    color: Color(0xFFE94560),
    description: 'على الجميع الإجابة',
    emoji: '👥',
  );

  final String label;
  final IconData icon;
  final Color color;
  final String description;
  final String emoji;

  const DieFace({
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
    required this.emoji,
  });
}
