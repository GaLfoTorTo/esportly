import 'package:flutter_riverpod/flutter_riverpod.dart';

//ESTADO - GAME VOTES
class GameVotesState {
  final Map<String, int> votesGame;     
  final Map<String, int> votesMVP;      
  final bool votedGame;
  final bool votedMVP; 
  final String? selectedGame;
  final String? selectedMVP; 

  const GameVotesState({
    this.votesGame = const {'team1': 0, 'draw': 0, 'team2': 0},
    this.votesMVP  = const {},
    this.votedGame = false,
    this.votedMVP  = false,
    this.selectedGame = '',
    this.selectedMVP  = '',
  });

  //TOTAIS DERIVADOS
  int get votesGameCount => votesGame.values.fold(0, (a, b) => a + b);
  int get votesMVPCount  => votesMVP.values.fold(0, (a, b) => a + b);

  //FUNÇÃO DE CALCULO DE PERCENTUAL DE OPÇÃO DE VOTOS
  double gamePercent(String key) {
    final total = votesGameCount;
    if (total == 0) return 0;
    return ((votesGame[key] ?? 0) / total) * 100;
  }

  GameVotesState copyWith({
    Map<String, int>? votesGame,
    Map<String, int>? votesMVP,
    bool? votedGame,
    bool? votedMVP,
    String? selectedGame,
    String? selectedMVP,
  }) => GameVotesState(
    votesGame: votesGame   ?? this.votesGame,
    votesMVP:  votesMVP    ?? this.votesMVP,
    votedGame: votedGame ?? this.votedGame,
    votedMVP:  votedMVP  ?? this.votedMVP,
    selectedGame: selectedGame ?? this.selectedGame,
    selectedMVP:  selectedMVP  ?? this.selectedMVP,
  );
}

//NOTIFICADOR - GAME VOTES
class GameVotesNotifier extends Notifier<GameVotesState> {
  @override
  GameVotesState build() => const GameVotesState();

  //FUNÇÃO DE INICIALIZAÇÃO DE VALORES DE VOTO
  void init(List<String> uuids) {
    state = GameVotesState(
      votesGame:   {'team1': 0, 'draw': 0, 'team2': 0},
      votesMVP:    { for (final id in uuids) id: 0 },
    );
  }

  //FUNÇÃO DE VOTO EM VENCEDOR / PERDEDOR/ EMPATE DA PARTIDA
  bool setGameVote(String team) {
    if (state.selectedGame == team) return false;
    final updated = Map<String, int>.from(state.votesGame);
    if (state.selectedGame != null && state.selectedGame!.isNotEmpty) {
      updated[state.selectedGame!] = ((updated[state.selectedGame!] ?? 1) - 1).clamp(0, 999);
    }
    updated[team] = (updated[team] ?? 0) + 1;
    state = state.copyWith(
      votesGame: updated,
      votedGame: true,
      selectedGame: team,
    );
    return true;
  }

  //FUNÇÃO DE VOTO NO MELHOR JOGADOR DA PARTIDA
  bool setMVPVote(String uuid) {
    if (state.selectedMVP == uuid) return false;
    final updated = Map<String, int>.from(state.votesMVP);
    if (state.selectedMVP != null && state.selectedMVP!.isNotEmpty) {
      updated[state.selectedMVP!] = ((updated[state.selectedMVP!] ?? 1) - 1).clamp(0, 999);
    }
    updated[uuid] = (updated[uuid] ?? 0) + 1;
    state = state.copyWith(
      votesMVP: updated,
      votedMVP: true,
      selectedMVP: uuid,
    );
    return true;
  }
}

//PROVIDER - GAME VOTES
final gameVotesProvider = NotifierProvider<GameVotesNotifier, GameVotesState>(GameVotesNotifier.new);
