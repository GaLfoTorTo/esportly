import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/data/models/snapshot_model.dart';
import 'package:esportly/data/models/room_event_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:esportly/core/storage/app_storage.dart';
import 'package:laravel_echo_null/laravel_echo_null.dart';
import 'package:pusher_client_socket/pusher_client_socket.dart' as PUSHER;

class StreamService {
  //STREAM - MENSAGENS DE PARTIDA (GameSnapshotEvent / GameActionEvent)
  final _gameStreamController = StreamController<SnapshotModel>.broadcast();
  Stream<SnapshotModel> get messages => _gameStreamController.stream;

  //STREAM - MENSAGENS DE SALA (RoomEvent / PresenceEvent)
  final _roomStreamController = StreamController<RoomEventModel>.broadcast();
  Stream<RoomEventModel> get roomMessages => _roomStreamController.stream;

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
    channel = null;
    connectionState = ConnectionState.disconnected;
    attempts = 0;
    final String token = AppStorage.read<String>('token') ?? '1235abcd';
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
    final channelName = 'event.$uuid';
    if (channel == channelName && connectionState == ConnectionState.connected) return;
    connectionState = ConnectionState.connecting;
    try {
      echo.channel(channelName)
        ..listen('.GameSnapshotEvent', _parseGamePayload)
        ..listen('.GameActionEvent',   _parseGamePayload)
        ..listen('.RoomEvent',         _parseRoomPayload)
        ..listen('.PresenceEvent',     _parseRoomPayload)
        ..error(onChannelError);
      channel = channelName;
      connectionState = ConnectionState.connected;
    } catch (e) {
      connectionState = ConnectionState.error;
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
    if (attempts >= maxAttempts) return;
    timer?.cancel();
    final delay = Duration(seconds: (5 * (1 << attempts)).clamp(5, 300));
    timer = Timer(delay, () {
      if (!disposed) {
        attempts++;
        connect(uuid: uuid);
      }
    });
  }

  //FUNÇÃO DE PARSEAMENTO — EVENTOS DE PARTIDA
  void _parseGamePayload(dynamic payload) {
    try {
      final map = payload is String
          ? json.decode(payload) as Map<String, dynamic>
          : Map<String, dynamic>.from(payload as Map);
      final message = SnapshotModel.fromMap(map);
      if (!_gameStreamController.isClosed) {
        _gameStreamController.add(message);
      }
    } catch (e) {
      debugPrint('[WS] Erro ao parsear evento de partida: $e');
    }
  }

  //FUNÇÃO DE PARSEAMENTO — EVENTOS DE SALA
  void _parseRoomPayload(dynamic payload) {
    try {
      final map = payload is String
          ? json.decode(payload) as Map<String, dynamic>
          : Map<String, dynamic>.from(payload as Map);
      final message = RoomEventModel.fromMap(map);
      if (!_roomStreamController.isClosed) {
        _roomStreamController.add(message);
      }
    } catch (e, st) {
      debugPrint('[WS] Erro ao parsear evento de sala: $e\n$st');
    }
  }

  //FUNÇÃO DE ERRO DE CONEXÃO
  void onChannelError(dynamic error) {
    connectionState = ConnectionState.error;
  }

  //FUNÇÃO DE FECHAMENTO DO SERVIÇO
  void dispose() {
    disposed = true;
    timer?.cancel();
    _gameStreamController.close();
    _roomStreamController.close();
    echo.disconnect();
  }
}
