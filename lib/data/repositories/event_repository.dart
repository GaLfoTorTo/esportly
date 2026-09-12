import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/data/models/rule_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/data/services/event_service.dart';

class EventRepository {
  //SERVIÇOS - USUARIO, CACHE LOCAL
  final EventService remoteService = EventService();
  final List<EventModel> _cache = <EventModel>[];

  //BUSCAR EVENTOS POR ID
  @override
  Future<EventModel?> getEvent(String uuid) async {
    if (_cache.isNotEmpty) {
      return _cache.firstWhere((u) => u.uuid == uuid);
    }
    try {
      final event = await remoteService.fetchEvent(uuid);
      _cache..clear()..add(event);
      return event;
    } catch (e, stackTrace) {
      print('=== ERRO COMPLETO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      print('=====================');
      return null;
    }
  }

  //BUSCAR EVENTOS
  @override
  Future<List<EventModel>?> getEvents({bool? user}) async {
    if (_cache.isNotEmpty) return _cache;
    try {
      final events = await remoteService.fetchEvents(user ?? false);
      _cache..clear()..addAll(events);
      return events;
    } catch (e, stackTrace) {
      print('=== ERRO COMPLETO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      print('=====================');
      return [];
    }
  }


  //BUSCAR RANKING APARTIR DO TIPO
  @override
  Future<List<UserModel>?> getRankEvent(String uuid, String type) async {
    try {
      final participants = await remoteService.fetchRankEvent(uuid, type);
      return participants;
    } catch (e, stackTrace) {
      print('=== ERRO COMPLETO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      print('=====================');
      return null;
    }
  }
  
  //BUSCAR REGRAS DO EVENTO
  @override
  Future<List<RuleModel>?> getRulesEvent(String uuid) async {
    try {
      final rules = await remoteService.fetchRulesEvent(uuid);
      return rules;
    } catch (e, stackTrace) {
      print('=== ERRO COMPLETO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      print('=====================');
      return null;
    }
  }

  //BUSCAR PARTIDAS DO EVENTO
  @override
  Future<List<GameModel>?> getGamesEvent(String uuid) async {
    try {
      final games = await remoteService.fetchGamesEvent(uuid);
      return games;
    } catch (e, stackTrace) {
      print('=== ERRO COMPLETO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      print('=====================');
      return null;
    }
  }
  
  //BUSCAR HISTÓRICO DE PARTIDAS DO EVENTO
  @override
  Future<List<GameModel>?> geHistoricEvent(String uuid) async {
    try {
      final games = await remoteService.fetchHistoricEvent(uuid);
      return games;
    } catch (e, stackTrace) {
      print('=== ERRO COMPLETO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      print('=====================');
      return null;
    }
  }
}