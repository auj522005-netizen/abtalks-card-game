class Player {
  final String id;
  final String name;
  int abHashCards;

  Player({
    required this.id,
    required this.name,
    this.abHashCards = 2,
  });

  bool get hasAbHashCards => abHashCards > 0;
}
