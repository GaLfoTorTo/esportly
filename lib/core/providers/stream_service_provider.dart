import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/data/services/stream_service.dart';

//PROVIDER — INSTÂNCIA COMPARTILHADA DO SERVIÇO DE WEBSOCKET
final streamServiceProvider = Provider<StreamService>((ref) {
  final service = StreamService();
  ref.onDispose(service.dispose);
  return service;
});
