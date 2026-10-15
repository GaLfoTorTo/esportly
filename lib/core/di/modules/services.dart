import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/api/api_client.dart';
import 'package:esportly/data/services/user_service.dart';
import 'package:esportly/data/services/event_service.dart';
import 'package:esportly/data/services/firebase/firebase_service.dart';
import 'package:esportly/data/services/timer_service.dart';
import 'package:esportly/data/services/game_notification_service.dart';

//FUNÇÃO DE INICIALIZAÇÃO DE SERVIÇOS GLOBAIS — chamada no início do app
void registerServices(ProviderContainer container) {
  sl.registerSingleton<GoRouter>(AppRoutes.createRouter(container));
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<UserService>(() => UserService());
  sl.registerLazySingleton<EventService>(() => EventService());
  sl.registerLazySingleton<TimerService>(() => TimerService());
  sl.registerLazySingleton<GameNotificationService>(() => GameNotificationService());
}

//INICIALIZAÇÃO DO FIREBASE MESSAGING — chamada separadamente
Future<void> initFirebaseMessaging() async {
  await FirebaseService().initFirebaseMessaging();
}