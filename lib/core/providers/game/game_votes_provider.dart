import 'package:flutter_riverpod/flutter_riverpod.dart';

//ESTADO - GAME VOTES
class GameVotesState {
  final Map<String, int> votesGame;     
  final Map<String, int> votesMVP;      
  final bool votedGame;
  final bool votedMVP; 
  final String? selectedGame;
  final int? selectedMVP; 

  const GameVotesState({
    this.votesGame = const {'team1': 0, 'draw': 0, 'team2': 0},
    this.votesMVP  = const {},
    this.votedGame = false,
    this.votedMVP  = false,
    this.selectedGame = '',
    this.selectedMVP  = 0,
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
    int? selectedMVP,
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
  void initVotes(List<String> participantIds) {
    state = GameVotesState(
      votesGame:   {'team1': 0, 'draw': 0, 'team2': 0},
      votesMVP:    { for (final id in participantIds) id: 0 },
    );
  }

  //FUNÇÃO DE VOTO EM VENCEDOR / PERDEDOR/ EMPATE DA PARTIDA 
  bool setGameVote(String choice) {
    if (state.votedGame) return false;
    final updated = Map<String, int>.from(state.votesGame);
    updated[choice] = (updated[choice] ?? 0) + 1;
    state = state.copyWith(
      votesGame: updated,
      votedGame: true,
    );
    return true;
  }

  //FUNÇÃO DE VOTO NO MELHOR JOGADOR DA PARTIDA
  bool setMVPVote(String playerId) {
    if (state.votedMVP) return false;
    final updated = Map<String, int>.from(state.votesMVP);
    updated[playerId] = (updated[playerId] ?? 0) + 1;
    state = state.copyWith(
      votesMVP: updated,
      votedMVP: true,
    );
    return true;
  }
}

//PROVIDER - GAME VOTES
final gameVotesProvider = NotifierProvider<GameVotesNotifier, GameVotesState>(GameVotesNotifier.new);
