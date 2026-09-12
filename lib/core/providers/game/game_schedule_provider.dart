import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/data/repositories/event_repository.dart';

//ESTADO - GAME SCHEDULE
class GameScheduleState {
  final bool ready;
  final bool error;
  final bool loading;
  final bool hasGames;
  final EventModel? event;
  final int qtd;
  final DateTime? date;
  final List<GameModel?> scheduledGames;
  final List<GameModel?> inProgressGames;
  final List<GameModel?> nextGames;
  final Map<String, List<GameModel>?> finishedGames;

  const GameScheduleState({
    this.ready = false,
    this.error = false,
    this.loading = false,
    this.hasGames = false,
    this.event,
    this.qtd = 3,
    this.date,
    this.nextGames = const [],
    this.inProgressGames = const [],
    this.scheduledGames = const [],
    this.finishedGames = const {},
  });

  GameScheduleState copyWith({
    bool? ready,
    bool? error,
    bool? loading,
    bool? hasGames,
    EventModel? event,
    int? qtd,
    DateTime? date,
    List<GameModel?>? nextGames,
    List<GameModel?>? inProgressGames,
    List<GameModel?>? scheduledGames,
    Map<String, List<GameModel>?>? finishedGames,
  }) => GameScheduleState(
    ready: ready ?? this.ready,
    error: error ?? this.error,
    loading: loading ?? this.loading,
    hasGames: hasGames ?? this.hasGames,
    event: event ?? this.event,
    qtd: qtd ?? this.qtd,
    date: date ?? this.date,
    nextGames: nextGames ?? this.nextGames,
    inProgressGames: inProgressGames ?? this.inProgressGames,
    scheduledGames: scheduledGames ?? this.scheduledGames,
    finishedGames: finishedGames ?? this.finishedGames,
  );
}

//NOTIFICADOR - GAME SCHEDULER
class GameScheduleNotifier extends Notifier<GameScheduleState> {
  final EventRepository _eventRepository = EventRepository();

  @override
  GameScheduleState build() => const GameScheduleState();

  //FUNÇÃO DE INICIALIZACAO
  void init(EventModel event) async{
    state = state.copyWith(
      event: event,
      date: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    //BUSCAR / GERAR PARTIDAS DO EVENTO
    await getGames();
  }

  //FUNÇÃO DE VERIFICAÇÃO DE PARTIDA HOJE
  bool isToday() {
    const weekdayMap = {1: 'seg', 2: 'ter', 3: 'qua', 4: 'qui', 5: 'sex', 6: 'sab', 7: 'dom'};
    final date = state.event!.date!;
    final todayLabel = weekdayMap[state.date!.weekday];
    return date.contains(todayLabel);
  }

  //FUNÇÃO DE DEFINIÇÃO DE PARITDA DO EVENTO
  Future<void> getGames() async {
    state = state.copyWith(loading: true);
    try {
      await Future.delayed(const Duration(seconds: 3));
      final List<GameModel>? games = await _eventRepository.getGamesEvent(state.event!.uuid!);
      if (games != null) {
        if (isToday()) {
          state = state.copyWith(nextGames: games, hasGames: true, loading: false);
        } else {
          state = state.copyWith(scheduledGames: games, hasGames: true, loading: false);
        }
      } else {
        state = state.copyWith(hasGames: false, loading: false);
      }
    } catch (_) {
      state = state.copyWith(hasGames: false, loading: false);
    }
  }

  //FUNÇÃO DE BUSCA DE HISTÓRICO DE PARTIDAS DO EVENTO
  Future<bool> getHistoricGames(EventModel event) async {
    state = state.copyWith(loading: false);
    try {
      final games = await _eventRepository.geHistoricEvent(state.event!.uuid!);
      final Map<String, List<GameModel>> mapGames = {};
      if(games != null){
        for (final item in games) {
          final key = DateFormat('d/MM').format(item.createdAt!);
          mapGames.putIfAbsent(key, () => []).add(item);
        }
      }
      state = state.copyWith(finishedGames: mapGames, loading: true);
      return true;
    } catch (_) {
      state = state.copyWith(loading: true);
      return false;
    }
  }

  //FUNÇÃO DE ADIÇÃO DE PARTIDA AO HISTÓRICO
  void addGameHistoric(GameModel game) {
    final key = DateFormat('d/MM').format(game.createdAt!);
    final updated = Map<String, List<GameModel>?>.from(state.finishedGames);
    if (updated.containsKey(key)) {
      updated[key] = [...updated[key]!, game];
    } else {
      updated[key] = [game];
    }
    state = state.copyWith(finishedGames: updated);
  }

  //FUNÇÃO DE MOVIMENTAÇÃO DE PARTIDA PARA EM PROGRESSO
  void moveToInProgress(GameModel game) {
    state = state.copyWith(
      inProgressGames: [...state.inProgressGames, game],
      nextGames: state.nextGames.where((g) => g?.id != game.id).toList(),
    );
  }
  
  //FUNÇÃO DE REMOVER PARTIDA DE EM PROGRESSO
  void removeFromInProgress(GameModel game) {
    state = state.copyWith(
      inProgressGames: state.inProgressGames.where((g) => g?.id != game.id).toList(),
    );
  }

  //FUNÇÃO DE RETORNO PARA PROXIMAS PARTIDAS
  void backToNext(GameModel game) {
    state = state.copyWith(
      inProgressGames: state.inProgressGames.where((g) => g?.id != game.id).toList(),
      nextGames: [...state.nextGames, game],
    );
  }

  //FUNÇÃO DE ATUALIZAÇÃO DE PARTIDA AGENDADA
  void updateGameInSchedule(GameModel game) {
    final idx = state.nextGames.indexWhere((g) => g?.id == game.id);
    if (idx == -1) return;
    final updated = [...state.nextGames];
    updated[idx] = game;
    state = state.copyWith(nextGames: updated);
  }

  //FUNÇÃO DE DEFINIÇÃO DE VISUALIZAÇÃO DE PARTIDAS
  void setView(bool expand, int totalGames) {
    final current = state.qtd;
    if (expand) {
      final diff = totalGames - current;
      state = state.copyWith(qtd: diff > 3 ? current + 3 : current + diff);
    } else {
      state = state.copyWith(qtd: current - 3 > 3 ? current - 3 : 3);
    }
  }
}

//PROVIDER - GAME SCHEDULE
final gameScheduleProvider = NotifierProvider<GameScheduleNotifier, GameScheduleState>(GameScheduleNotifier.new);
