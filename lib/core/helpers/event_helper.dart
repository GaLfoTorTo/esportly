import 'package:esportly/core/helpers/date_helper.dart';
import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/data/models/event_model.dart';
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
            'label': "Limite de Gols",
            'icon': Icons.scoreboard,
            'value' : event.gameConfig!.config!["point"]?.toString() ?? 'Não',
          },
          {
            'label': "2 Tempos",
            'icon': Icons.safety_divider_rounded,
            'value' : event.gameConfig!.config!["halves"] ? "Sim" : "Não"
          },
          {
            'label': "Pênaltis",
            'icon': Icons.sports_soccer,
            'value' : event.gameConfig!.config!["penalty"] ? "Sim" : "Não"
          },
          {
            'label': "Árbitro",
            'icon': Icons.sports,
            'value' : event.gameConfig!.config!["refereerId"] != null ? "Sim" : "Não"
          },
        ];
    }
  }
  
  //FUNÇÃO DE BUSCA DE INFORMAÇÕES DE PARTIDAS
  static List<Map<String, dynamic>> getDetailGame(EventModel event){
    switch (event.modality?.name) {
      case "Volleyball":
        return [
          {
            'label': "Sets",
            'icon': Icons.safety_divider_rounded,
            'value' : event.gameConfig!.duration.toString(),
          },
          {
            'label': "Limite de Pontos",
            'icon': Icons.scoreboard,
            'value' : event.gameConfig!.points != null ? event.gameConfig!.points.toString() : "Não",
          },
          {
            'label': "Jogadores por Equipe",
            'icon': Icons.people,
            'value' : event.gameConfig!.playersPerTeam.toString(),
          },
          {
            'label': "Tie Break",
            'icon': Icons.add_alarm_rounded,
            'value' : event.gameConfig!.config!["tieBreakPoints"] != null ? "Sim" : "Não",
          },
        ];
      case "Basketball":
        return [
          {
            'label': "Quarters",
            'icon': Icons.safety_divider_rounded,
            'value' : event.gameConfig!.config!["quarters"] != null ? event.gameConfig!.config!["quarters"].toString() : "Não",
          },
          {
            'label': "Duração (min)",
            'icon': AppIcones.stopwatch_solid,
            'value' : event.gameConfig!.duration.toString(),
          },
          {
            'label': "Limite de Pontos",
            'icon': Icons.scoreboard,
            'value' : event.gameConfig!.points != null ? event.gameConfig!.points.toString() : "Não",
          },
          {
            'label': "Jogadores por Equipe",
            'icon': Icons.people,
            'value' : event.gameConfig!.playersPerTeam.toString(),
          },
        ];
      default:
        return [
          {
            'label': "2 Tempos",
            'icon': Icons.safety_divider_rounded,
            'value' : event.gameConfig!.config!["halves"] != null ? "Sim" : "Não",
          },
          {
            'label': "Duração (min)",
            'icon': AppIcones.stopwatch_solid,
            'value' : event.gameConfig!.duration.toString(),
          },
          {
            'label': "Limite de Gols",
            'icon': Icons.scoreboard,
            'value' : event.gameConfig!.points != null ? event.gameConfig!.points.toString() : "Não",
          },
          {
            'label': "Jogadores por Equipe",
            'icon': Icons.people,
            'value' : event.gameConfig!.playersPerTeam.toString(),
          },
        ];
    }
  }
}