import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/data/models/game_config_model.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';

//ESTADO - GAME CONFIG
class GameConfigState {
  final bool loading;
  final bool error;
  final GameConfigModel? config;

  const GameConfigState({
    this.loading = false,
    this.error = false,
    this.config,
  });

  GameConfigState copyWith({
    bool? loading,
    bool? error,
    GameConfigModel? config,
  }) => GameConfigState(
    loading: loading ?? this.loading,
    error: error ?? this.error,
    config: config ?? this.config,
  );
}

//NOTIFICADOR - GAME CONFIG
class GameConfigNotifier extends Notifier<GameConfigState> {
  @override
  GameConfigState build() => const GameConfigState();

  //FUNÇÃO DE INICIALIZAÇÃO
  void init(GameConfigModel? config) {
    if (config == null) return;
    state = GameConfigState(config: config);
  }

  //FUNÇÃO DE APLICAÇÃO DE CONFIGURAÇÕES DE PARTIDA
  void applyConfig({
    required String? category,
    required int? duration,
    required int? playersPerTeam,
    required Map<String, dynamic> configMap,
    UserModel? refereer,
  }) {
    final gameSession = ref.read(gameSessionProvider);
    if (state.config == null || gameSession.currentGame == null || gameSession.event == null) return;

    try {
      state = state.copyWith(
        config: GameConfigModel(
          id: state.config!.id,
          eventId: state.config!.eventId,
          category: category ?? state.config!.category,
          duration: duration ?? state.config!.duration,
          playersPerTeam: playersPerTeam,
          config: configMap,
          createdAt: state.config!.createdAt,
          updatedAt: DateTime.now(),
        ) 
      );
      ref.read(gameMatchProvider.notifier).setPlayersPerTeam(playersPerTeam!);
    } catch (e) {
      state = state.copyWith(error: true);
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
  }
}

//PROVIDER - GAME CONFIG
final gameConfigProvider = NotifierProvider<GameConfigNotifier, GameConfigState>(GameConfigNotifier.new);
