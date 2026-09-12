import 'package:intl/intl.dart';

class DateHelper {

  //FUNÇÃO PARA RESGATAR DATA RELATIVA
  static String getDateLabel(DateTime date) {
    //RESGATAR DATA DE HOJE COMPLETA
    final now = DateTime.now();
    //RESGATAR DATA DE HOJE (DD/MM/YYYY)
    final today = DateTime(now.year, now.month, now.day);
    //DATA ALVO (DD/MM/YYYY)
    final targetDate = DateTime(date.year, date.month, date.day);
    //RESGATAR DIFERENÇA ENTRE AS DATA
    final difference = today.difference(targetDate).inDays;
    //VERIFICAR DIFERENÇA ENTRE DATA
    switch (difference) {
      case 0:
        return "Hoje";
      case 1:
        return "Ontem";
      case -1:
        return "Amanhã";
      default:
        return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  //FUNÇÃO PARA FORMATAR DATA DA PELADA
  static String getEventDate(List<String> date){
    if(date.length == 7){
      return "Todo Dia";
    }
    return date.toString().replaceAll('[', '').replaceAll(']', '').toString();
  }

  //FUNNÇÃO DE TRANSFORMAÇÃO DE DATA
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return null;
  }

  // Converte string de horário "HH:mm:ss" ou "HH:mm" para DateTime.
  // Se baseDate for fornecido, combina a data dele com o horário parsed.
  static DateTime? parseTime(dynamic value, {DateTime? baseDate}) {
    if (value == null) return null;
    if (value is DateTime) return _applyBaseDate(value, baseDate);
    if (value is String) {
      DateTime? time;
      try {
        time = DateTime.parse(value);
      } catch (_) {}
      if (time == null) {
        try {
          time = DateFormat('HH:mm:ss').parse(value);
        } catch (_) {}
      }
      if (time == null) {
        try {
          time = DateFormat('HH:mm').parse(value);
        } catch (_) {}
      }
      if (time != null) return _applyBaseDate(time, baseDate);
    }
    return null;
  }

  static DateTime _applyBaseDate(DateTime time, DateTime? baseDate) {
    if (baseDate == null) return time;
    return DateTime(
      baseDate.year, baseDate.month, baseDate.day,
      time.hour, time.minute, time.second, time.millisecond,
    );
  }
}