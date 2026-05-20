import 'dart:math';
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../models/die_face.dart';
import '../data/pack_data.dart';

// ─────────── State ───────────

class GameState {
  final List<Player> players;
  final List<GameCard> drawPile;
  final int currentPlayerIndex;
  final GameCard? currentCard;
  final DieFace? currentDieFace;
  final String? selectedResponderId;
  final GamePhase phase;
  final bool isAbHashActive;
  final String? abHashUserId;
  final String? customQuestion;
  final String? selectedPackId;

  const GameState({
    required this.players,
    required this.drawPile,
    required this.currentPlayerIndex,
    this.currentCard,
    this.currentDieFace,
    this.selectedResponderId,
    required this.phase,
    this.isAbHashActive = false,
    this.abHashUserId,
    this.customQuestion,
    this.selectedPackId,
  });

  Player? get currentPlayer => players.isNotEmpty ? players[currentPlayerIndex % players.length] : null;
  int get remainingCards => drawPile.where((c) => !c.isUsed).length;
  bool get isGameOver => remainingCards == 0;

  GameState copyWith({
    List<Player>? players,
    List<GameCard>? drawPile,
    int? currentPlayerIndex,
    GameCard? currentCard,
    bool clearCard = false,
    DieFace? currentDieFace,
    bool clearDie = false,
    String? selectedResponderId,
    bool clearResponder = false,
    GamePhase? phase,
    bool? isAbHashActive,
    bool clearAbHash = false,
    String? abHashUserId,
    bool clearAbHashUser = false,
    String? customQuestion,
    bool clearCustomQuestion = false,
    String? selectedPackId,
    bool clearPack = false,
  }) {
    return GameState(
      players: players ?? this.players,
      drawPile: drawPile ?? this.drawPile,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      currentCard: clearCard ? null : (currentCard ?? this.currentCard),
      currentDieFace: clearDie ? null : (currentDieFace ?? this.currentDieFace),
      selectedResponderId: clearResponder ? null : (selectedResponderId ?? this.selectedResponderId),
      phase: phase ?? this.phase,
      isAbHashActive: clearAbHash ? false : (isAbHashActive ?? this.isAbHashActive),
      abHashUserId: clearAbHashUser ? null : (abHashUserId ?? this.abHashUserId),
      customQuestion: clearCustomQuestion ? null : (customQuestion ?? this.customQuestion),
      selectedPackId: clearPack ? null : (selectedPackId ?? this.selectedPackId),
    );
  }
}

enum GamePhase {
  drawingCard,
  selectingResponder,
  rollingDie,
  responding,
  discussion,
}

// ─────────── Engine ───────────

class GameEngine {
  static List<QuestionPack> get allPacks => PackData.allPacks();

  static GameState initializeGame(List<String> playerNames, String packId) {
    final players = playerNames.asMap().entries.map((e) => Player(id: 'p${e.key}', name: e.value)).toList();
    final pack = allPacks.firstWhere((p) => p.id == packId, orElse: () => allPacks.first);
    final shuffledCards = List<GameCard>.from(pack.cards)..shuffle(Random());
    return GameState(players: players, drawPile: shuffledCards, currentPlayerIndex: 0, phase: GamePhase.drawingCard, selectedPackId: packId);
  }

  static GameState drawCard(GameState state) {
    if (state.isGameOver) return state;
    final available = state.drawPile.where((c) => !c.isUsed).toList();
    if (available.isEmpty) return state;
    final card = available.first;
    final updatedPile = state.drawPile.map((c) => c.id == card.id ? c.copyWith(isUsed: true) : c).toList();
    final nextPhase = (card.type == CardType.abHash) ? GamePhase.responding : GamePhase.selectingResponder;
    return state.copyWith(drawPile: updatedPile, currentCard: card, phase: nextPhase, clearDie: true, clearResponder: true, clearAbHash: true, clearAbHashUser: true, clearCustomQuestion: true);
  }

  static GameState selectResponder(GameState state, String responderId) {
    return state.copyWith(selectedResponderId: responderId, phase: GamePhase.rollingDie);
  }

  static GameState rollDie(GameState state) {
    final faces = DieFace.values;
    final face = faces[Random().nextInt(faces.length)];
    final nextPhase = (face == DieFace.everyone) ? GamePhase.discussion : GamePhase.responding;
    return state.copyWith(currentDieFace: face, phase: nextPhase);
  }

  static GameState useAbHashCard(GameState state) {
    final player = state.currentPlayer;
    if (player == null || !player.hasAbHashCards) return state;
    final updatedPlayers = state.players.map((p) => p.id == player.id ? Player(id: p.id, name: p.name, abHashCards: p.abHashCards - 1) : p).toList();
    return state.copyWith(players: updatedPlayers, isAbHashActive: true, abHashUserId: player.id, phase: GamePhase.responding);
  }

  static GameState useAbHashAsAnyPlayer(GameState state, String playerId) {
    final player = state.players.where((p) => p.id == playerId).firstOrNull;
    if (player == null || !player.hasAbHashCards) return state;
    final updatedPlayers = state.players.map((p) => p.id == playerId ? Player(id: p.id, name: p.name, abHashCards: p.abHashCards - 1) : p).toList();
    return state.copyWith(players: updatedPlayers, isAbHashActive: true, abHashUserId: playerId, phase: GamePhase.responding);
  }

  static GameState setCustomQuestion(GameState state, String question) {
    return state.copyWith(customQuestion: question);
  }

  static GameState nextTurn(GameState state) {
    final nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
    return state.copyWith(currentPlayerIndex: nextIndex, phase: GamePhase.drawingCard, clearCard: true, clearDie: true, clearResponder: true, clearAbHash: true, clearAbHashUser: true, clearCustomQuestion: true);
  }
}
