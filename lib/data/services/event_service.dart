import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/api/api_client.dart';
import 'package:esportly/core/api/api_routes.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/data/models/news_model.dart';
import 'package:esportly/data/models/rule_model.dart';
import 'package:esportly/data/models/user_model.dart';

class EventService {
  //INSTANCIAR SERVIÇOS - API
  ApiClient apiClient = sl<ApiClient>();

  //FUNÇÃO DE BUSCA EVENTO ESPECIFICO
  Future<EventModel> fetchEvent(String uuid) async{
    final resp = await apiClient.get("${ApiRoutes.events}$uuid");
    return EventModel.fromJson(resp.data);
  }
  
  //FUNÇÃO DE BUSCA DE TODOS OS EVENTOS
  Future<List<EventModel>> fetchEvents(bool user) async{
    final route = user ? ApiRoutes.userEvent : ApiRoutes.events;
    final resp = await apiClient.get(route);
    final events = resp.data['events'] ?? [];
    return events
      .map<EventModel>((e) => EventModel.fromMap(e))
      .toList();
  }
  
  //FUNÇÃO DE BUSCA DE DADOS DE RANKING
  Future<List<UserModel>?> fetchRankEvent(String? uuid, String type) async{
    final resp = await apiClient.get("${ApiRoutes.events}$uuid/rank/$type");
    final rank = resp.data['rank'] ?? [];
    return rank
      .map<UserModel>((e) => UserModel.fromMap(e))
      .toList();
  }
  
  //FUNÇÃO DE BUSCA DE DADOS DE REGRAS DA PELADA
  Future<List<RuleModel>?> fetchRulesEvent(String? uuid,) async{
    final resp = await apiClient.get("${ApiRoutes.events}$uuid/rules");
    final rules = resp.data['rules'] ?? [];
    return rules
      .map<RuleModel>((e) => RuleModel.fromMap(e))
      .toList();
  }
  
  //FUNÇÃO DE BUSCA DE DADOS DE REGRAS DA PELADA
  Future<List<NewsModel>?> fetchNewsEvent(String? uuid,) async{
    final resp = await apiClient.get("${ApiRoutes.events}$uuid/news");
    final news = resp.data['news'] ?? [];
    return news
      .map<NewsModel>((e) => NewsModel.fromMap(e))
      .toList();
  }

  //FUNÇÃO DE BUSCA DE PARTuuIDAS DA PELADA
  Future<List<GameModel>?> fetchGamesEvent(String? uuid,) async{
    final resp = await apiClient.get("${ApiRoutes.events}/$uuid/games");
    final games = resp.data['games'] ?? [];
    return games
      .map<GameModel>((e) => GameModel.fromMap(e))
      .toList();
  }
  
  //FUNÇÃO DE BUSCA DE PARTuuIDAS DA PELADA
  Future<List<GameModel>?> fetchHistoricEvent(String? uuid,) async{
    final resp = await apiClient.get("${ApiRoutes.events}$uuid/historic");
    final news = resp.data['news'] ?? [];
    return news
      .map<GameModel>((e) => GameModel.fromMap(e))
      .toList();
  }
}