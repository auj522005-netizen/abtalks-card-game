import 'dart:math';
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../models/die_face.dart';

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
  final String? customQuestion;

  const GameState({
    required this.players,
    required this.drawPile,
    required this.currentPlayerIndex,
    this.currentCard,
    this.currentDieFace,
    this.selectedResponderId,
    required this.phase,
    this.isAbHashActive = false,
    this.customQuestion,
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
    String? customQuestion,
    bool clearCustomQuestion = false,
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
      customQuestion: clearCustomQuestion ? null : (customQuestion ?? this.customQuestion),
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
  static GameState initializeGame(List<String> playerNames) {
    final players = playerNames.asMap().entries.map((e) => Player(id: 'p${e.key}', name: e.value)).toList();
    final allCards = _buildAndShuffleDeck();
    return GameState(players: players, drawPile: allCards, currentPlayerIndex: 0, phase: GamePhase.drawingCard);
  }

  static List<GameCard> _buildAndShuffleDeck() {
    final allCards = _allQuestions();
    allCards.shuffle(Random());
    return allCards;
  }

  static GameState drawCard(GameState state) {
    if (state.isGameOver) return state;
    final available = state.drawPile.where((c) => !c.isUsed).toList();
    if (available.isEmpty) return state;
    final card = available.first;
    final updatedPile = state.drawPile.map((c) => c.id == card.id ? c.copyWith(isUsed: true) : c).toList();
    final nextPhase = (card.type == CardType.abHash) ? GamePhase.responding : GamePhase.selectingResponder;
    return state.copyWith(drawPile: updatedPile, currentCard: card, phase: nextPhase, clearDie: true, clearResponder: true, clearAbHash: true, clearCustomQuestion: true);
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
    return state.copyWith(players: updatedPlayers, isAbHashActive: true, phase: GamePhase.responding);
  }

  static GameState setCustomQuestion(GameState state, String question) {
    return state.copyWith(customQuestion: question);
  }

  static GameState nextTurn(GameState state) {
    final nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
    return state.copyWith(currentPlayerIndex: nextIndex, phase: GamePhase.drawingCard, clearCard: true, clearDie: true, clearResponder: true, clearAbHash: true, clearCustomQuestion: true);
  }
}

// ─────────── Questions ───────────

List<GameCard> _allQuestions() {
  final q = [
    // ── الطفولة (13) ──
    ['q01', 'لو وصفت طفولتك في 3 كلمات، إيه هما؟', 'الطفولة'],
    ['q02', 'إيه أكتر ذكريات طفولتك اللي لسه مأثرة في شخصيتك لحد النهاردة؟', 'الطفولة'],
    ['q03', 'لو رجعت بالزمن وشوفت والدتك وهي مراهقة، هتقولها إيه؟', 'الطفولة'],
    ['q04', 'إيه الدرس الوحيد اللي لو تقدر تعلمه لكل طفل في العالم، هتعلمهوله؟', 'الطفولة'],
    ['q05', 'إيه أكتر درس اتعلمته من والدك وبتطبقه في حياتك دلوقتي؟', 'الطفولة'],
    ['q06', 'لو عندك فرصة تغير طبع واحد في طريقة تربية أهلك ليك، هيكون إيه؟', 'الطفولة'],
    ['q07', 'إيه الذكرى اللي بتخليك تبتسم تلقائياً من غير ما تحس؟', 'الطفولة'],
    ['q08', 'هل حرمانك من حاجة في صغرك كان دافع لنجاحك ولا ساب جواك عقدة؟', 'الطفولة'],
    ['q09', 'إيه السر اللي كنت مخبيه عن أهلك ومستحيل تقولهولهم لحد دلوقتي؟', 'الطفولة'],
    ['q10', 'إيه العادة الطفولية اللي لسه محتفظ بيها ومبتتكسفش منها؟', 'الطفولة'],
    ['q11', 'لو طفولتك كانت لوحة مرسومة، إيه الألوان الغالبة عليها؟', 'الطفولة'],
    ['q12', 'هل كنت بتدور على رضا أهلك، ولا كنت بتعمل اللي في دماغك؟', 'الطفولة'],
    ['q13', 'إيمتى حسيت لأول مرة إن أهلك مش خارقين؟', 'الطفولة'],
    // ── النفس والمشاعر (13) ──
    ['q14', 'مين أنت لما الأضواء بتطفي ومحدش شايفك؟', 'النفس'],
    ['q15', 'لو طلعنا قلبك برا وجلسناه قدامك، تفتكر هيقولك إيه؟', 'النفس'],
    ['q16', 'إيمتى كانت آخر مرة عيطت فيها بحرقة؟', 'النفس'],
    ['q17', 'إيه السؤال اللي دايماً بيدور في عقلك وملقتش إجابة ليه؟', 'النفس'],
    ['q18', 'إيه المعركة الداخلية اللي بتخوضها يومياً ومحدش يعرف عنها؟', 'النفس'],
    ['q19', 'إيه أكتر كلمة اتقالتلك وجرحتك جداً ومهما طال الزمن مش هتنساها؟', 'النفس'],
    ['q20', 'هل إظهار الضعف والدموع قدام الناس شجاعة ولا قلة حيلة؟', 'النفس'],
    ['q21', 'إيه الحاجة اللي بتخليك تحس بالأمان الداخلي؟', 'النفس'],
    ['q22', 'لو حياتك كتاب، إيه عنوان الفصل الحالي؟', 'النفس'],
    ['q23', 'هل جربت إنك تكون وسط زحمة وحاسس بوحدة قاتلة؟', 'النفس'],
    ['q24', 'إيه الصفة اللي بتحاول تخبيها عن الناس بكل الطرق؟', 'النفس'],
    ['q25', 'هل بتحس إنك لابس ماسك لما بتتعامل مع المجتمع؟', 'النفس'],
    ['q26', 'إزاي بتعالج نفسك لما تحس بالاكتئاب أو الإحباط؟', 'النفس'],
    // ── الحب والعلاقات (13) ──
    ['q27', 'إيه المفهوم الحقيقي للحب من وجهة نظرك؟', 'الحب'],
    ['q28', 'لو شريك حياتك غلط ومستحيل تكتشفها، يصارحك ولا يخبي؟', 'الحب'],
    ['q29', 'إيه أكبر تضحية قدمتها عشان شخص بتحبه وهل ندمت عليها؟', 'الحب'],
    ['q30', 'إيمتى حسيت لأول مرة إنك وقعت في الحب بجد؟', 'الحب'],
    ['q31', 'لو اضطريت تختار بين كرامتك وشخص بتحبه، هتعمل إيه؟', 'الحب'],
    ['q32', 'الحب الأول هو الأقوى ولا حب النضج هو الأبقى؟', 'الحب'],
    ['q33', 'إيه هي الخيانة بالنسبة لك؟ هل بتقتصر على الفعل ولا الفكرة؟', 'الحب'],
    ['q34', 'إيمتى حسيت إنك بتعطي في علاقة أكتر ملي بتاخده؟', 'الحب'],
    ['q35', 'لو الصداقة ليها شروط، إيه الشرط الأول والأهم؟', 'الحب'],
    ['q36', 'هل تقدر تسامح شخص خذلك في وقت كنت محتاجه فيه جداً؟', 'الحب'],
    ['q37', 'إيه الموقف اللي ينهي علاقتك بصديق فوراً؟', 'الحب'],
    ['q38', 'إزاي بتتعامل مع وجع الفراق عن شخص كان بيمثلك كل حاجة؟', 'الحب'],
    ['q39', 'إيه الحاجة اللي بتأكد إن الشخص بيبادلك نفس عمق المشاعر؟', 'الحب'],
    // ── النجاح والعمل (14) ──
    ['q40', 'إيه مفهوم النجاح الحقيقي بالنسبة لك؟', 'النجاح'],
    ['q41', 'إيه أصعب قرار خدته وكان نقطة تحول في حياتك؟', 'النجاح'],
    ['q42', 'لو الشغل اختفى من العالم بكرة، هتعمل إيه؟', 'النجاح'],
    ['q43', 'هل مريت بوقت حسيت فيه إنك عايز تستسلم تماماً؟', 'النجاح'],
    ['q44', 'لو اضطريت تختار بين شغفك اللي مبيجيبش فلوس وشغل ممل بيكسب كتير؟', 'النجاح'],
    ['q45', 'إيه المشروع اللي حلمت بيها ولسه منفذتهاش؟', 'النجاح'],
    ['q46', 'لو خسرت كل ثروتك بكرة، إيه أول خطوة هتعملها؟', 'النجاح'],
    ['q47', 'إيه القوة الخفية اللي بيصحيك كل يوم وتشتغل؟', 'النجاح'],
    ['q48', 'الشهرة لعنة بتسحب من خصوصيتك ولا ميزة بتفتحلك الأبواب؟', 'النجاح'],
    ['q49', 'لو اديتك محاضرة 10 دقائق لكل شباب العالم، إيه موضوعها؟', 'النجاح'],
    ['q50', 'القدر يعشق السعي فعلاً، ولا الحظ بيلعب الدور الأكبر؟', 'النجاح'],
    ['q51', 'إيمتى حسيت إن شغلك تحول لرسالة حقيقية؟', 'النجاح'],
    ['q52', 'إزاي بتتعامل مع النقد الهدام على تعبك؟', 'النجاح'],
    ['q53', 'كلمة واحدة تعبر عن مسيرتك المهنية؟', 'النجاح'],
    // ── الفلسفة والمخاوف (14) ──
    ['q54', 'إيه أكتر حاجة بتخاف منها بجد دلوقتي؟', 'الفلسفة'],
    ['q55', 'لو معاك ظرف مكتوب فيه تاريخ وفاتك، هل هتفتحها؟', 'الفلسفة'],
    ['q56', 'لو العالم هينتهي كمان أسبوع، إيه أول 3 حاجات هتعملها فوراً؟', 'الفلسفة'],
    ['q57', 'لو عندك القدرة ترجع شخص مات للحياة ساعة، مين هيكون؟', 'الفلسفة'],
    ['q58', 'إيه القناعة اللي مستعد تموت عشانها؟', 'الفلسفة'],
    ['q59', 'إيه الكذبة اللي بتكذبها على نفسك كل يوم عشان تعيش وتكمل؟', 'الفلسفة'],
    ['q60', 'لو عيشت على جزيرة معزولة وتاخد 3 حاجات بس، هتاخد إيه؟', 'الفلسفة'],
    ['q61', 'هل بتخاف إن الناس تنساك بعد ما تموت؟', 'الفلسفة'],
    ['q62', 'إيه السر اللي مستحيل تحكيه لأي كائن حي لحد ما تموت؟', 'الفلسفة'],
    ['q63', 'لو حياتك حلم هتصحي منه بكرة، حقيقتك برة الحلم هتكون إيه؟', 'الفلسفة'],
    ['q64', 'لو تقدر تمحي صفة بشرية من كل الناس، هتختار إيه؟', 'الفلسفة'],
    ['q65', 'لو ملاك الموت واقف قدامك، إيه أول حاجة هتندم إنك ملحقتش تعملها؟', 'الفلسفة'],
    ['q66', 'حياة قصيرة مليانة إنجازات ولا حياة طويلة هادية وبسيطة؟', 'الفلسفة'],
    ['q67', 'لخص حياتك ورسالتك.. في كلمة واحدة بس!', 'الفلسفة'],
  ];

  final cards = <GameCard>[];

  for (final item in q) {
    cards.add(GameCard(id: item[0], text: item[1], type: CardType.question, category: item[2]));
  }

  // 3 Free cards
  for (int i = 1; i <= 3; i++) {
    cards.add(GameCard(id: 'free$i', text: 'حرية كاملة\nاطرح أي سؤال تريده', type: CardType.free));
  }

  // 20 AB# cards
  for (int i = 1; i <= 20; i++) {
    cards.add(GameCard(id: 'ab$i', text: 'AB#', type: CardType.abHash));
  }

  return cards;
}
