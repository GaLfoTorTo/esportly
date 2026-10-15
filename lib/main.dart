import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:esportly/app_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/storage/app_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:esportly/core/di/modules/services.dart';
import 'package:esportly/core/di/modules/controllers.dart';
import 'package:esportly/core/di/modules/repositories.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:esportly/data/services/game_notification_service.dart';
import 'package:esportly/core/providers/game/game_control_provider.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/core/helpers/game_action_helper.dart';

// HANDLER DE AÇÃO DA NOTIFICAÇÃO (app em foreground ou retomado)
void _onNotificationAction(NotificationResponse response) {
  try {
    final container = sl<ProviderContainer>();
    final notifier = container.read(gameControlProvider.notifier);
    final gameState = container.read(gameControlProvider);
    switch (response.actionId) {
      case 'game_play_pause':
        if (gameState.isGameRunning) {
          notifier.pauseGame();
        } else {
          notifier.startGame();
        }
        break;
      case 'game_stop':
        final category = container.read(gameConfigProvider).config?.category;
        final periodConfig = GameActionHelper.getPeriodConfig(category);
        if (gameState.currentPeriod >= periodConfig.total) {
          notifier.stopGame();
        } else {
          notifier.nextPeriod();
        }
        break;
      case 'game_reset':
        notifier.resetGame();
        break;
    }
  } catch (_) {}
}

// HANDLER DE AÇÃO DA NOTIFICAÇÃO (app em background — função top-level obrigatória)
@pragma('vm:entry-point')
void _onBackgroundNotificationAction(NotificationResponse response) {
  // Quando o app está completamente suspenso, a ação reabre o app
  // e o foreground handler assume o controle
}

void main() async {
  //1 - INICIALIZAR OS BINDINGS DO FLUTTER
  final WidgetsBinding widgetBinding = WidgetsFlutterBinding.ensureInitialized();
  //2 - SEGURAR SPALSH ATÉ CARERGAMENTO DOS DEMAIS ITENS
  FlutterNativeSplash.preserve(widgetsBinding: widgetBinding);
  //TENTAR TRATAMENTOS INICIAIS
  try {
    //3 - INICIALIZAR DE VARIAVEIS DE AMBIENTE
    await dotenv.load(fileName: ".env",);
    //4 - INICIALIZAÇÃO DE STORAGE
    await AppStorage.init();
    //5 - INICIALIZAR FIREBASE (com timeout para evitar travamentos)
    //5.1 - INICIALIZAR FIREBASE APP (INTEGRATION)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10));
    }
    //5.2 - INICIALIZAR FIREBASE MESSAGING (BACKGROUND)
    FirebaseMessaging.onBackgroundMessage(initFirebaseHandler);
    //6 - REGISTRAR PROVIDER CONTAINER GLOBAL (acesso Riverpod fora da widget tree)
    final container = ProviderContainer();
    sl.registerSingleton<ProviderContainer>(container);
    //6.1 - INICIALIZAR DEPENDENCIAS (CONTROLLERS, SERVICES E REPOSITORIES)
    registerServices(container);
    registerInitControllers();
    registerLazyControllers();
    registerRepositories();
    //6.2 - INICIALIZAR SERVIÇO DE NOTIFICAÇÃO DE PARTIDA
    await sl<GameNotificationService>().init(
      onAction: _onNotificationAction,
      onBackgroundAction: _onBackgroundNotificationAction,
    );
    //7 - INICIALIZAR PROVIDER + ARVORE DE WIDGETS (APPWIDGET)
    runApp(UncontrolledProviderScope(container: container, child: const AppWidget()));
  } catch (e, stack) {
    //ERROS - EXIBIÇÃO DE ERRO
    debugPrint('Erro na inicialização: $e');
    debugPrint('Stack trace: $stack');
    
    //ERROS - EXIBIR TELA DE ERRO AMIGÁVEL
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.green_300,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Falha na inicialização do aplicativo",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue_500
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Recarregue o App e tente novamente",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.blue_500),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => main(), // Tentar novamente
                  child: const Text("Tentar novamente"),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}

Future<void> initFirebaseHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}