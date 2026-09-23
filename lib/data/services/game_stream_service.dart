import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/data/models/snapshot_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:esportly/core/storage/app_storage.dart';
import 'package:laravel_echo_null/laravel_echo_null.dart';
import 'package:pusher_client_socket/pusher_client_socket.dart' as PUSHER;

class GameStreamService {
  //STREAM - MENSAGENS INTERNAS
  final streamController = StreamController<SnapshotModel>.broadcast();
  Stream<SnapshotModel> get messages => streamController.stream;

  //INSTANCIA DE STREAM/WEBSOCKET (.ENV)
  late Echo<PUSHER.PusherClient, PusherChannel> echo;

  //ESTADO - CONEXÃO
  ConnectionState connectionState = ConnectionState.disconnected;
  String? channel;
  bool disposed = false;
  Timer? timer;
  int attempts = 0;
  int maxAttempts = 5;

  //FUNÇÃO DE INICIALIZAÇÃO DO SERVIÇO
  void init(){
    //BUSCAR TOKEN
    final String token = AppStorage.read<String>('token') ?? '1235abcd';
    //INSTANCIAR WEBSOCKET
    echo = Echo<PUSHER.PusherClient, PusherChannel>(PusherConnector(
      dotenv.env['REVERB_APP_KEY']!,
      authHeaders: () async => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      authEndPoint: dotenv.env['REVERB_APP_AUTH']!,
      host: dotenv.env['REVERB_APP_HOST'],
      wsPort: int.parse(dotenv.env['REVERB_APP_PORT']!),
      wssPort: int.parse(dotenv.env['REVERB_APP_PORT']!),
      nameSpace: '',
      cluster: 'mt1',
      encrypted: bool.parse(dotenv.env['REVERB_APP_ENCRYPT']!),
      activityTimeout: 120000,
      pongTimeout: 30000,
      enableLogging: true,
      autoConnect: true,
      maxReconnectionAttempts: 3,
    ));
  }

  //FUNÇÃO DE CONEXÃO E INSCRIÇÃO NO CANAL DE STREAM
  Future<void> connect({required String uuid}) async {
    final channelName = 'event.event-123';
    if (channel == channelName && connectionState == ConnectionState.connected) return;
    connectionState = ConnectionState.connecting;
    try {
      echo.channel(channelName)
        ..listen('GameSnapshotEvent', parsePayload)
        ..listen('GameActionEvent', parsePayload)
        ..listen('RoomEvent', parsePayload)
        ..error(onChannelError);
      channel = channelName;
      connectionState = ConnectionState.connected;
      debugPrint('[WS] Conectado ao canal: $channelName');
    } catch (e) {
      connectionState = ConnectionState.error;
      debugPrint('[WS] Erro ao conectar: $e');
      reconnect(uuid: uuid);
    }
  }

  //FUNÇÃO DE DESCONEXÃO
  Future<void> disconnect() async {
    timer?.cancel();
    echo.disconnect();
    channel = null;
    disposed = false;
    connectionState = ConnectionState.disconnected;
  }

  //FUNÇÃO DE RECONEXÃO
  void reconnect({required String uuid}) {
    if (attempts >= maxAttempts) {
      debugPrint('[WS] Máximo de tentativas atingido');
      return;
    }
    timer?.cancel();
    final delay = Duration(seconds: (5 * (1 << attempts)).clamp(5, 300));
    timer = Timer(delay, () {
      if (!disposed) {
        attempts++;
        connect(uuid: uuid);
      }
    });
  }

  //FUNÇÃO DE PARSEAMENTO DE PAYLOAD DO STREAM
  void parsePayload(dynamic payload) {
    try {
      final map = payload is String
        ? json.decode(payload) as Map<String, dynamic>
        : Map<String, dynamic>.from(payload as Map);
      final message = SnapshotModel.fromMap(map);
      if (!streamController.isClosed) {
        streamController.add(message);
      }
    } catch (e) {
      debugPrint('[WS] Erro ao parsear mensagem: $e');
    }
  }

  //FUNÇÃO DE ERRO DE CONEXÃO
  void onChannelError(dynamic error) {
    debugPrint('[WS] Erro no canal: $error');
    connectionState = ConnectionState.error;
  }

  //FUNÇÃO DE FECHAMENTO DO SERVIÇO
  void dispose() {
    disposed = true;
    timer?.cancel();
    streamController.close();
    echo.disconnect();
  }
}
