import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const int _notifyGameId = 10;
// Canais distintos por importância — Android congela importância na criação do canal
const String _notifyAlertChannelId = 'game_start_channel_v2';
const String _notifyControlChannelId = 'game_control_channel_v2';
const String _notifyIcon = 'ic_notification';

class GameNotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init({
    required void Function(NotificationResponse) onAction,
    void Function(NotificationResponse)? onBackgroundAction,
  }) async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings(_notifyIcon),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: onAction,
      onDidReceiveBackgroundNotificationResponse: onBackgroundAction,
    );

    // Android 13+ (API 33+): POST_NOTIFICATIONS exige consentimento em runtime.
    // Sem permissão concedida, show() é silenciosamente ignorado pelo sistema.
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled() ?? false;
      if (!enabled) {
        await androidPlugin.requestNotificationsPermission();
      }
    }
  }

  /// Notificação unificada de partida.
  ///
  /// - [showControls] true  → organizador/colaborador: notificação persistente com botões de controle.
  /// - [showControls] false → participante/visitante: alerta simples de início de partida.
  Future<void> showGameNotification({
    required bool showControls,
    required String teamAName,
    required String teamBName,
    required int numero,
    // campos usados apenas quando showControls = true
    bool isRunning = false,
    String time = '00:00',
    int period = 1,
    String periodLabel = 'Tempo',
    int teamAScore = 0,
    int teamBScore = 0,
    bool isLastPeriod = false,
    int progress = 0,
  }) async {
    try {
      if (showControls) {
        // NOTIFICAÇÃO PERSISTENTE DE CONTROLE (organizer / collaborator)
        final android = AndroidNotificationDetails(
          _notifyControlChannelId,
          'Controle de Partida',
          channelDescription: 'Controle da partida em andamento',
          importance: Importance.low,
          priority: Priority.low,
          icon: _notifyIcon,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          playSound: false,
          enableVibration: false,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          styleInformation: const MediaStyleInformation(),
          actions: [
            AndroidNotificationAction(
              'game_reset',
              'Reiniciar',
              icon: const DrawableResourceAndroidBitmap('ic_notif_restart'),
              showsUserInterface: true,
              cancelNotification: false,
            ),
            AndroidNotificationAction(
              'game_play_pause',
              isRunning ? 'Pausar' : 'Continuar',
              icon: DrawableResourceAndroidBitmap(
                isRunning ? 'ic_notif_pause' : 'ic_notif_play',
              ),
              showsUserInterface: true,
              cancelNotification: false,
            ),
            AndroidNotificationAction(
              'game_stop',
              isLastPeriod ? 'Encerrar' : 'Próximo $periodLabel',
              icon: DrawableResourceAndroidBitmap(
                isLastPeriod ? 'ic_notif_stop' : 'ic_notif_next',
              ),
              showsUserInterface: true,
              cancelNotification: false,
            ),
          ],
        );
        await _plugin.show(
          id: _notifyGameId,
          title: '$teamAName $teamAScore × $teamBScore $teamBName',
          body: '$period° $periodLabel · $time',
          notificationDetails: NotificationDetails(android: android),
        );
      } else {
        // ALERTA SIMPLES DE INÍCIO (participante / visitante)
        const android = AndroidNotificationDetails(
          _notifyAlertChannelId,
          'Início de Partida',
          channelDescription: 'Notificações de início de partida',
          importance: Importance.high,
          priority: Priority.high,
          icon: _notifyIcon,
          playSound: true,
          enableVibration: true,
        );
        await _plugin.show(
          id: _notifyGameId,
          title: 'Partida #$numero Iniciada!',
          body: '$teamAName × $teamBName',
          notificationDetails: const NotificationDetails(android: android),
        );
      }
    } catch (e, st) {
      debugPrint('[GameNotification] ERRO: $e\n$st');
    }
  }

  Future<void> cancelGameNotification() async {
    await _plugin.cancel(id: _notifyGameId);
  }
}
