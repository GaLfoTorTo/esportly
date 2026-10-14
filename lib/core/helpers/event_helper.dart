import 'package:esportly/core/helpers/date_helper.dart';
import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_config_model.dart';
import 'package:esportly/data/models/user_model.dart';

class EventHelper {
  //FUNÇÃO PARA RESGATAR NOME COMPLETO DO USUARIO
  static UserModel? getUserEvent(EventModel event,int userId){
    return event.participants?.firstWhere((u) => u.id == userId);
  }

  //FUNÇÃO PARA RESGATAR ORGANIZADOR DO EVENTO
  static UserModel getUserOrganizator(EventModel event){
    return event.participants!.firstWhere((u){
      final participant = u.participants!.where((p) => p.eventId == event.id).first;
      return participant.roles!.contains("Organizator");
    });
  }
  
  //FUNÇÃO PARA RESGATAR COLABORADORES DO EVENTO
  static List<UserModel?> getCollaborators(EventModel event){
    final arr = event.participants!.where((u){
      final item = u.participants!.where((p) => p.eventId == event.id).first;
      return item.roles!.contains("Colaborator");
    }).toList();
    return arr;
  }
  
  //FUNÇÃO PARA RESGATAR AVALIAÇÕES DO EVENTO
  static double getAvaliation(EventModel event){
    double num = 0.0;
    if(event.avaliations?.isEmpty ?? false) return num;
    event.avaliations!.map((a){
      num += a.avaliation!;
    });
    return num / event.avaliations!.length;
  }
  
  //FUNÇÃO PARA RESGATAR JOGADOR DO EVENTO
  static UserModel getUserPlayer(EventModel event, int userId){
    return event.participants!.firstWhere((u){
      final participant = u.participants!.where((p) => p.eventId == event.id).first;
      return participant.roles!.contains("Player");
    });
  }
  
  //FUNÇÃO PARA RESGATAR MANAGERS DO EVENTO
  static UserModel getUserManager(EventModel event){
    return event.participants!.firstWhere((u){
      final participant = u.participants!.where((p) => p.eventId == event.id).first;
      return participant.roles!.contains("Manager");
    });
  }

  //FUNÇÃO DE BUSCA DE INFORMAÇÕES DO EVENTO
  static List<Map<String, dynamic>> getInfoEvent(EventModel event){
    return [
      {
        'label': "Agenda",
        'icon': Icons.calendar_month_rounded,
        'value' : DateHelper.getEventDate(event.date!),
      },
      {
        'label': "Horário",
        'icon': Icons.watch_later,
        'value' : "${event.startTime!.substring(0,5)} as ${event.endTime!.substring(0,5)}",
      },
      {
        'label': "Modalidade",
        'icon': AppIcones.modality_solid,
        'value' : event.modality?.name ?? '',
      },
      {
        'label': "Partiricpants",
        'icon': Icons.people,
        'value' : "${event.participants?.length ?? 0}",
      },
      {
        'label': "Categoria",
        'icon': Icons.category,
        'value' : event.gameConfig!.category,
      },
      {
        'label': "Partidas",
        'icon': Icons.sports,
        'value' : "${event.games?.length ?? 0}",
      },
      {
        'label': "Visibilidade",
        'icon': Icons.lock,
        'value' : event.privacy!.name,
      },
    ];
  }
  
  //FUNÇÃO DE BUSCA DE INFORMAÇÕES DO CONFIGURAÇÕES DE PARTIDAS
  static List<Map<String, dynamic>> getInfoGameConfig(EventModel event){
    switch (event.modality?.name) {
      case "Volleyball":
        return [
          {
            'label': "Jogadores por Equipe",
            'icon': Icons.people,
            'value' : event.gameConfig!.playersPerTeam?.toString() ?? '',
          },
          {
            'label': "Sets",
            'icon': Icons.safety_divider_rounded,
            'value' : event.gameConfig!.config!['sets']?.toString() ?? '',
          },
          {
            'label': "Limite de Pontos",
            'icon': Icons.scoreboard,
            'value' : event.gameConfig!.points?.toString() ?? 'Não',
          },
          {
            'label': "Tie Break",
            'icon': Icons.add_alarm_rounded,
            'value' : event.gameConfig!.config!["hasTieBreak"] ? "Sim" : "Não",
          },
          {
            'label': "Pontos no Tie Break",
            'icon': Icons.scoreboard,
            'value' : event.gameConfig!.config!["tieBreakPoints"]?.toString() ?? '',
          },
          {
            'label': "Árbitro",
            'icon': Icons.sports,
            'value' : event.gameConfig!.config!["refereerId"] != null ? "Sim" : "Não",
          },
        ];
      case "Basketball":
        return [
          {
            'label': "Jogadores por Equipe",
            'icon': Icons.people,
            'value' : event.gameConfig!.playersPerTeam?.toString() ?? '',
          },
          {
            'label': "Quarters",
            'icon': Icons.safety_divider_rounded,
            'value' : event.gameConfig!.config!["quarters"]?.toString() ?? '',
          },
          {
            'label': "Duração (min)",
            'icon': AppIcones.stopwatch_solid,
            'value' : event.gameConfig!.duration?.toString() ?? '',
          },
          {
            'label': "Shot Clock (seg)",
            'icon': Icons.sports_soccer,
            'value' : event.gameConfig!.config!["shotClock"]?.toString() ?? '',
          },
          {
            'label': "Limite de Pontos",
            'icon': Icons.scoreboard,
            'value' : event.gameConfig!.config!["point"]?.toString() ?? "Não",
          },
          {
            'label': "Árbitro",
            'icon': Icons.sports,
            'value' : event.gameConfig!.config!["refereerId"] != null ? "Sim" : "Não",
          },
        ];
      default:
        return [
          {
            'label': "Jogadores por Equipe",
            'icon': Icons.people,
            'value' : event.gameConfig!.playersPerTeam?.toString() ?? '',
          },
          {
            'label': "Duração (min)",
            'icon': AppIcones.stopwatch_solid,
            'value' : event.gameConfig!.duration?.toString() ?? '',
          },
          {
            'label': "2 Tempos",
            'icon': Icons.safety_divider_rounded,
            'value' : event.gameConfig!.config!["hasTwoHalves"] == true ? "Sim" : "Não",
          },
          {
            'label': "Limite de Gols",
            'icon': Icons.scoreboard,
            'value' : event.gameConfig!.config!["hasGoalLimit"] == true
                ? (event.gameConfig!.config!["goalLimit"]?.toString() ?? '--')
                : 'Não',
          },
          {
            'label': "Pênaltis",
            'icon': Icons.sports_soccer,
            'value' : event.gameConfig!.config!["hasPenalty"] == true ? "Sim" : "Não",
          },
          {
            'label': "Prorrogação",
            'icon': Icons.more_time_rounded,
            'value' : event.gameConfig!.config!["hasExtraTime"] == true
                ? (event.gameConfig!.config!["extraTime"]?.toString() != null
                    ? "${event.gameConfig!.config!["extraTime"]} min"
                    : "Sim")
                : "Não",
          },
          {
            'label': "Árbitro",
            'icon': Icons.sports,
            'value' : event.gameConfig!.config!["hasRefereer"] == true ? "Sim" : "Não",
          },
        ];
    }
  }
  
  //FUNÇÃO DE BUSCA DE INFORMAÇÕES DE PARTIDAS (baseado na config por partida)
  static List<Map<String, dynamic>> getDetailGame(GameConfigModel config){
    final cfg = config.config ?? {};
    final String sportType;
    switch (config.category) {
      case 'Volei':
      case 'Volei de praia':
      case 'Fut Volei':
        sportType = 'Volleyball';
        break;
      case 'Basquete':
      case 'Streetball':
        sportType = 'Basketball';
        break;
      default:
        sportType = 'Football';
    }

    switch (sportType) {
      case 'Volleyball':
        return [
          {
            'label': "Sets",
            'icon': Icons.safety_divider_rounded,
            'value': (cfg['sets'] ?? '--').toString(),
          },
          {
            'label': "Pontos por Set",
            'icon': Icons.scoreboard,
            'value': cfg['hasPointsLimit'] == true
                ? (cfg['points'] ?? '--').toString()
                : "Não",
          },
          {
            'label': "Tie-Break",
            'icon': Icons.add_alarm_rounded,
            'value': cfg['hasTieBreak'] == true
                ? (cfg['tieBreakPoints'] != null ? "${cfg['tieBreakPoints']} pts" : "Sim")
                : "Não",
          },
          {
            'label': "Jogadores por Equipe",
            'icon': Icons.people,
            'value': config.playersPerTeam?.toString() ?? '--',
          },
        ];
      case 'Basketball':
        return [
          {
            'label': "Quartos",
            'icon': Icons.safety_divider_rounded,
            'value': (cfg['quarters'] ?? '--').toString(),
          },
          {
            'label': "Duração/Quarto (min)",
            'icon': AppIcones.stopwatch_solid,
            'value': config.duration?.toString() ?? '--',
          },
          {
            'label': "Limite de Pontos",
            'icon': Icons.scoreboard,
            'value': cfg['hasPointsLimit'] == true
                ? (cfg['points'] ?? '--').toString()
                : "Não",
          },
          {
            'label': "Jogadores por Equipe",
            'icon': Icons.people,
            'value': config.playersPerTeam?.toString() ?? '--',
          },
        ];
      default: // Football
        return [
          {
            'label': "2 Tempos",
            'icon': Icons.safety_divider_rounded,
            'value': cfg['hasTwoHalves'] == true ? "Sim" : "Não",
          },
          {
            'label': "Duração/Tempo (min)",
            'icon': AppIcones.stopwatch_solid,
            'value': config.duration?.toString() ?? '--',
          },
          {
            'label': "Limite de Gols",
            'icon': Icons.scoreboard,
            'value': cfg['hasGoalLimit'] == true
                ? (cfg['goalLimit'] ?? '--').toString()
                : "Não",
          },
          {
            'label': "Jogadores por Equipe",
            'icon': Icons.people,
            'value': config.playersPerTeam?.toString() ?? '--',
          },
        ];
    }
  }
}