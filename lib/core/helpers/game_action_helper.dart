import 'package:flutter/material.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/theme/app_colors.dart';

class GameActionConfig {
  final String label;
  final IconData icon;
  final Color color;
  final GameEvent event;
  final double? score;
  final bool requiresPlayer;

  const GameActionConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.event,
    this.score,
    this.requiresPlayer = true,
  });

  String get scoreLabel {
    if (score == null || score == 0) return '';
    final formatted = score! % 1 == 0
        ? score!.toInt().toString()
        : score!.toStringAsFixed(1);
    return score! > 0 ? '+$formatted' : formatted;
  }

  Color scoreColor(Color fallback) {
    if (score == null || score == 0) return fallback;
    return score! > 0 ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
  }
}

typedef PeriodConfig = ({String label, int total, bool hasExtraTime});

class GameActionHelper {
  GameActionHelper._();

  static PeriodConfig getPeriodConfig(String? category) {
    switch (category) {
      case 'Basquete':
      case 'Streetball':
        return (label: 'Quarto', total: 4, hasExtraTime: false);
      case 'Volei':
      case 'Volei de praia':
      case 'Fut Volei':
        return (label: 'Set', total: 3, hasExtraTime: false);
      default:
        return (label: 'Tempo', total: 2, hasExtraTime: true);
    }
  }

  static List<GameActionConfig> getActions(String? category) {
    switch (category) {
      case 'Volei':
      case 'Volei de praia':
      case 'Fut Volei':
        return const [
          // Pontuação
          GameActionConfig(label: 'Ace',           icon: Icons.bolt_rounded,               color: AppColors.green_500,  event: GameEvent.Ace,          score:  8.0),
          GameActionConfig(label: 'Ponto',         icon: Icons.sports_volleyball_rounded,  color: AppColors.green_300,  event: GameEvent.VolleyPoint,  score:  3.0),
          // Defesa
          GameActionConfig(label: 'Bloqueio',      icon: Icons.front_hand_rounded,         color: AppColors.teal_300,   event: GameEvent.Block,        score:  5.0),
          GameActionConfig(label: 'Defesa',        icon: Icons.shield_rounded,             color: AppColors.blue_300,   event: GameEvent.DefensiveSave,score:  5.0),
          // Erros / Disciplina
          GameActionConfig(label: 'Erro de Saque', icon: Icons.sports_volleyball_outlined, color: AppColors.red_300,    event: GameEvent.ServingError, score: -3.0),
          GameActionConfig(label: 'Falta',         icon: Icons.close_rounded,              color: AppColors.orange_300, event: GameEvent.Fault,        score: -1.0),
          // Neutro
          GameActionConfig(label: 'Substituição',  icon: Icons.swap_horiz_rounded,         color: AppColors.grey_500,   event: GameEvent.Substitution),
        ];

      case 'Basquete':
      case 'Streetball':
        return const [
          // Pontuação
          GameActionConfig(label: 'Cesta 2pts',    icon: Icons.sports_basketball_rounded,  color: AppColors.green_300,  event: GameEvent.Point2,       score:  1.0),
          GameActionConfig(label: 'Cesta 3pts',    icon: Icons.filter_3_rounded,           color: AppColors.green_500,  event: GameEvent.Point3,       score:  2.0),
          // Criação
          GameActionConfig(label: 'Assistência',   icon: Icons.handshake_rounded,          color: AppColors.blue_300,   event: GameEvent.BasketAssist, score:  1.0),
          // Defesa
          GameActionConfig(label: 'Bloqueio',      icon: Icons.front_hand_rounded,         color: AppColors.teal_300,   event: GameEvent.BlockShot,    score:  2.0),
          GameActionConfig(label: 'Rebote',        icon: Icons.vertical_align_top_rounded, color: AppColors.teal_300,   event: GameEvent.Rebound,      score:  1.0),
          GameActionConfig(label: 'Roubo de Bola', icon: Icons.back_hand_rounded,          color: AppColors.teal_500,   event: GameEvent.Steal,        score:  2.0),
          // Erros / Disciplina
          GameActionConfig(label: 'Turnover',      icon: Icons.swap_horiz_rounded,         color: AppColors.orange_300, event: GameEvent.Turnover,     score: -1.0),
          GameActionConfig(label: 'Falta Pessoal', icon: Icons.warning_amber_rounded,      color: AppColors.yellow_500, event: GameEvent.PersonalFoul, score: -1.0),
          // Neutro
          GameActionConfig(label: 'Substituição',  icon: Icons.swap_horiz_rounded,         color: AppColors.grey_500,   event: GameEvent.Substitution),
        ];

      default: // Futebol, Fut7, Futsal
        return const [
          // Pontuação
          GameActionConfig(label: 'Gol',            icon: Icons.sports_soccer_rounded,    color: AppColors.green_300,   event: GameEvent.Goal,           score:  8.0),
          GameActionConfig(label: 'Trave',          icon: Icons.sports_soccer_outlined,   color: AppColors.green_400,   event: GameEvent.ShotOnPost,     score:  1.5),
          GameActionConfig(label: 'Chute Defend.',  icon: Icons.sports_soccer_outlined,   color: AppColors.green_500,   event: GameEvent.ShotSaved,      score:  1.0),
          GameActionConfig(label: 'Chute p/ Fora',  icon: Icons.sports_soccer_outlined,   color: AppColors.teal_200,    event: GameEvent.ShotMissed,     score:  0.3),
          GameActionConfig(label: 'Falta Sofrida',  icon: Icons.personal_injury_rounded,  color: AppColors.teal_300,    event: GameEvent.FoulTaken,      score:  0.5),
          GameActionConfig(label: 'Assistência',    icon: Icons.handshake_rounded,        color: AppColors.teal_400,    event: GameEvent.Assist,         score:  5.0),
          // Defesa / Goleiro
          GameActionConfig(label: 'Desarme',        icon: Icons.shield_rounded,           color: AppColors.yellow_300,  event: GameEvent.Defense,        score:  2.5),
          GameActionConfig(label: 'Defesa Goleiro', icon: Icons.shield_rounded,           color: AppColors.yellow_500,  event: GameEvent.GoalkeeperSave, score:  3.0),
          GameActionConfig(label: 'Defesa Pênalti', icon: Icons.shield_rounded,           color: AppColors.yellow_600,  event: GameEvent.PenaltySave,    score:  8.0),
          // Bola parada
          GameActionConfig(label: 'Pênalti',        icon: Icons.sports,                   color: AppColors.blue_100,    event: GameEvent.Penalty,        score:  8.0),
          GameActionConfig(label: 'Tiro Livre',     icon: Icons.sports_soccer_outlined,   color: AppColors.blue_200,    event: GameEvent.FreeKick,       score:  0.5),
          GameActionConfig(label: 'Escanteio',      icon: Icons.flag_rounded,             color: AppColors.blue_300,    event: GameEvent.Corner,         score:  0.3, requiresPlayer: false),
          // Disciplina / erros
          GameActionConfig(label: 'Gol Sofrido',    icon: Icons.sports_soccer_rounded,    color: AppColors.red_300,     event: GameEvent.GoalkeeperFail, score: -5.0),
          GameActionConfig(label: 'Pênalti Perdido',icon: Icons.sports,                   color: AppColors.red_400,     event: GameEvent.PenaltyMissed,  score: -5.0),
          GameActionConfig(label: 'Gol Contra',     icon: Icons.sports_soccer_rounded,    color: AppColors.red_500,     event: GameEvent.OwnGoal,        score: -5.0),
          GameActionConfig(label: 'Falta',          icon: Icons.warning_amber_rounded,    color: AppColors.orange_300,  event: GameEvent.Foul,           score: -0.5),
          GameActionConfig(label: 'Impedimento',    icon: Icons.not_interested_rounded,   color: AppColors.orange_500,  event: GameEvent.Offside,        score: -1.3, requiresPlayer: false),
          GameActionConfig(label: 'Passe Errado',   icon: Icons.close_rounded,            color: AppColors.orange_600,  event: GameEvent.WrongPass,      score: -0.5),
          GameActionConfig(label: 'Cart. Amarelo',  icon: Icons.square_rounded,           color: AppColors.yellow_500,  event: GameEvent.YellowCard,     score: -3.0),
          GameActionConfig(label: 'Cart. Vermelho', icon: Icons.square_rounded,           color: AppColors.red_500,     event: GameEvent.RedCard,        score: -5.0),
          // Neutro
          GameActionConfig(label: 'Substituição',   icon: Icons.swap_horiz_rounded,       color: AppColors.grey_500,    event: GameEvent.Substitution),
        ];
    }
  }
}
