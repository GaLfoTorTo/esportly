import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/data/models/game_event_model.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/data/models/team_model.dart';
import 'package:esportly/data/models/user_model.dart';

//ESTADO - GAME MATCH
class GameMatchState {
  final TeamModel teamA;
  final TeamModel teamB;
  final List<GameEventModel> gameEvents;
  final int teamAlength;
  final int teamBlength;
  final int teamAScore;
  final int teamBScore;
  final int teamACorners;
  final int teamBCorners;
  final int teamAFouls;
  final int teamBFouls;
  final int teamADefense;
  final int teamBDefense;
  final int teamAOffside;
  final int teamBOffside;
  final int teamAPasses;
  final int teamBPasses;
  final int teamAPossesion;
  final int teamBPossesion;
  final int teamAShots;
  final int teamBShots;
  final int teamAShotsGoal;
  final int teamBShotsGoal;
  final int teamAYellowCard;
  final int teamBYellowCard;
  final int teamARedCard;
  final int teamBRedCard;

  const GameMatchState({
    required this.teamA,
    required this.teamB,
    this.gameEvents = const [],
    this.teamAlength = 0,
    this.teamBlength = 0,
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.teamACorners = 0,
    this.teamBCorners = 0,
    this.teamAFouls = 0,
    this.teamBFouls = 0,
    this.teamADefense = 0,
    this.teamBDefense = 0,
    this.teamAOffside = 0,
    this.teamBOffside = 0,
    this.teamAPasses = 0,
    this.teamBPasses = 0,
    this.teamAPossesion = 50,
    this.teamBPossesion = 50,
    this.teamAShots = 0,
    this.teamBShots = 0,
    this.teamAShotsGoal = 0,
    this.teamBShotsGoal = 0,
    this.teamAYellowCard = 0,
    this.teamBYellowCard = 0,
    this.teamARedCard = 0,
    this.teamBRedCard = 0,
  });

  GameMatchState copyWith({
    TeamModel? teamA,
    TeamModel? teamB,
    List<GameEventModel>? gameEvents,
    int? teamAlength, int? teamBlength,
    int? teamAScore, int? teamBScore,
    int? teamACorners, int? teamBCorners,
    int? teamAFouls, int? teamBFouls,
    int? teamADefense, int? teamBDefense,
    int? teamAOffside, int? teamBOffside,
    int? teamAPasses, int? teamBPasses,
    int? teamAPossesion, int? teamBPossesion,
    int? teamAShots, int? teamBShots,
    int? teamAShotsGoal, int? teamBShotsGoal,
    int? teamAYellowCard, int? teamBYellowCard,
    int? teamARedCard, int? teamBRedCard,
  }) => GameMatchState(
    teamA: teamA ?? this.teamA,
    teamB: teamB ?? this.teamB,
    gameEvents: gameEvents ?? this.gameEvents,
    teamAlength: teamAlength ?? this.teamAlength,
    teamBlength: teamBlength ?? this.teamBlength,
    teamAScore: teamAScore ?? this.teamAScore,
    teamBScore: teamBScore ?? this.teamBScore,
    teamACorners: teamACorners ?? this.teamACorners,
    teamBCorners: teamBCorners ?? this.teamBCorners,
    teamAFouls: teamAFouls ?? this.teamAFouls,
    teamBFouls: teamBFouls ?? this.teamBFouls,
    teamADefense: teamADefense ?? this.teamADefense,
    teamBDefense: teamBDefense ?? this.teamBDefense,
    teamAOffside: teamAOffside ?? this.teamAOffside,
    teamBOffside: teamBOffside ?? this.teamBOffside,
    teamAPasses: teamAPasses ?? this.teamAPasses,
    teamBPasses: teamBPasses ?? this.teamBPasses,
    teamAPossesion: teamAPossesion ?? this.teamAPossesion,
    teamBPossesion: teamBPossesion ?? this.teamBPossesion,
    teamAShots: teamAShots ?? this.teamAShots,
    teamBShots: teamBShots ?? this.teamBShots,
    teamAShotsGoal: teamAShotsGoal ?? this.teamAShotsGoal,
    teamBShotsGoal: teamBShotsGoal ?? this.teamBShotsGoal,
    teamAYellowCard: teamAYellowCard ?? this.teamAYellowCard,
    teamBYellowCard: teamBYellowCard ?? this.teamBYellowCard,
    teamARedCard: teamARedCard ?? this.teamARedCard,
    teamBRedCard: teamBRedCard ?? this.teamBRedCard,
  );
}

//NOTIFICADOR - GAME MATCH
class GameMatchNotifier extends Notifier<GameMatchState> {
  @override
  GameMatchState build() => GameMatchState(
    teamA: TeamModel(players: []),
    teamB: TeamModel(players: []),
  );

  //FUNÇÃO DE DEFINIÇÃO DE EQUIPE PARA PARTIDA
  void setTeamsFromGame(GameModel game) {
    if (game.teams == null || game.teams!.length < 2) return;
    state = state.copyWith(
      teamA: game.teams!.first,
      teamB: game.teams!.last,
      teamAlength: game.teams!.first.players.length,
      teamBlength: game.teams!.last.players.length,
      teamAScore: game.result?.teamAScore ?? 0,
      teamBScore: game.result?.teamBScore ?? 0,
    );
  }

  //FUNÇÃO DE ATUALIZAÇÃO DE EQUIPE
  void updateTeams(TeamModel teamA, TeamModel teamB) {
    state = state.copyWith(teamA: teamA, teamB: teamB);
  }

  //FUNÇÃO DE ATUALIZAÇÃO DE NÚMERO DE JOGADORES POR TIME
  void setPlayersPerTeam(int playersPerTeam) {
    final aPlayers = state.teamA.players;
    final bPlayers = state.teamB.players;
    final trimmedA = aPlayers.length > playersPerTeam
        ? state.teamA.copyWith(players: aPlayers.sublist(0, playersPerTeam))
        : state.teamA;
    final trimmedB = bPlayers.length > playersPerTeam
        ? state.teamB.copyWith(players: bPlayers.sublist(0, playersPerTeam))
        : state.teamB;
    state = state.copyWith(
      teamA: trimmedA,
      teamB: trimmedB,
      teamAlength: playersPerTeam,
      teamBlength: playersPerTeam,
    );
  }

  //FUNÇÃO DE ATUALIZAÇÃO DE JOGADORES DE UM TIME
  void setPlayersTeam(int teamIndex, List<UserModel> players) {
    if (teamIndex == 0) {
      state = state.copyWith(
        teamA: state.teamA.copyWith(players: players),
        teamAlength: players.length,
      );
    } else {
      state = state.copyWith(
        teamB: state.teamB.copyWith(players: players),
        teamBlength: players.length,
      );
    }
  }

  //FUNÇÃO DE ADIÇÃO DE EVENTO DA PARTIDA
  void _addGameEvent(Map<String, dynamic> payload, GameEvent eventType) {
    try {
      final gameEvent = GameEventModel.fromMap({
        ...payload,
        'type': eventType,
        'timestamp': DateTime.now().toIso8601String(),
      });
      state = state.copyWith(gameEvents: [gameEvent, ...state.gameEvents]);
    } catch (_) {}
  }

  //FUNÇÃO DE APLICAÇÃO DE AÇÃO - WEBSOCKET
  void applyStreamAction(Map<String, dynamic> payload) {
    final actionType = GameEvent.values[payload['action'] as int];
    final team = payload['team'] as String? ?? '';

    switch (actionType) {
      case GameEvent.Goal:
        if (team == 'A') {
          state = state.copyWith(teamAScore: state.teamAScore + 1);
        } else {
          state = state.copyWith(teamBScore: state.teamBScore + 1);
        }
        break;
      case GameEvent.Corner:
        if (team == 'A') {
          state = state.copyWith(teamACorners: state.teamACorners + 1);
        } else {
          state = state.copyWith(teamBCorners: state.teamBCorners + 1);
        }
        break;
      case GameEvent.Offside:
        if (team == 'A') {
          state = state.copyWith(teamAOffside: state.teamAOffside + 1);
        } else {
          state = state.copyWith(teamBOffside: state.teamBOffside + 1);
        }
        break;
      case GameEvent.Foul:
      case GameEvent.FoulTaken:
        if (team == 'A') {
          state = state.copyWith(teamAFouls: state.teamAFouls + 1);
        } else {
          state = state.copyWith(teamBFouls: state.teamBFouls + 1);
        }
        break;
      case GameEvent.YellowCard:
        if (team == 'A') {
          state = state.copyWith(teamAYellowCard: state.teamAYellowCard + 1);
        } else {
          state = state.copyWith(teamBYellowCard: state.teamBYellowCard + 1);
        }
        break;
      case GameEvent.RedCard:
        if (team == 'A') {
          state = state.copyWith(teamARedCard: state.teamARedCard + 1);
        } else {
          state = state.copyWith(teamBRedCard: state.teamBRedCard + 1);
        }
        break;
      default:
        break;
    }
    _addGameEvent(payload, actionType);
  }
}

//PROVIDER - GAME MATCH
final gameMatchProvider = NotifierProvider<GameMatchNotifier, GameMatchState>(GameMatchNotifier.new);
