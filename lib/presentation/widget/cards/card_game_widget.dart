import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/data/models/team_model.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/presentation/widget/animated/animated_ellipsis.dart';
import 'package:esportly/presentation/widget/others/timer_counter_widget.dart';
import 'package:intl/intl.dart';

class CardGameWidget extends ConsumerStatefulWidget {
  final EventModel event;
  final GameModel game;
  final bool live;

  const CardGameWidget({
    super.key,
    required this.event,
    required this.game,
    this.live = false,
  });

  @override
  ConsumerState<CardGameWidget> createState() => _CardGameWidgetState();
}

class _CardGameWidgetState extends ConsumerState<CardGameWidget> {
  late Color modalityColor;
  late Color modalityTextColor;
  late String modalityImage;

  @override
  void initState() {
    super.initState();
    modalityColor = ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality?.name ?? 'Football')['color'];
    modalityTextColor = AppColors.white;//ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality?.name ?? 'Football')['textColor'];
    modalityImage = ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality?.name ?? 'Football')['image'];
  }

  @override
  Widget build(BuildContext context) {
    final TeamModel teamA = widget.game.teams!.first;
    final TeamModel teamB = widget.game.teams!.last;
    
    final teamAScore = ref.watch(gameMatchProvider.select((s) => s.teamAScore));
    final teamBScore = ref.watch(gameMatchProvider.select((s) => s.teamBScore));

    var gameStartTime = DateFormat.Hm().format(widget.game.startTime!);
    var gameEndTime = DateFormat.Hm().format(widget.game.endTime!);

    return Card(
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(modalityImage) as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              modalityColor.withAlpha(200), 
              BlendMode.multiply,
            ),
          ),
        ),
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: RadialGradient(
              center: AlignmentGeometry.bottomRight,
              radius: 1.7,
              colors: [
                modalityColor.withAlpha(10),
                modalityColor,
              ],
            ),
          ),
          child: Column(
            spacing: 10,
            children: [
              if(widget.live)...[
                Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.red_300,
                    borderRadius: BorderRadius.circular(50)
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(
                      Icons.sensors, 
                      size: 15,
                      color: AppColors.white
                    ),
                  ),
                ),
              ],
              Text(
                "#${widget.game.number}",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: modalityTextColor),
              ),
              Row(
                spacing: 30,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 120,
                    child: Column(
                      spacing: 5,
                      children: [
                        SvgPicture.asset(
                          AppIcones.emblemas[teamA.emblem ?? "emblema_2"]!,
                          width: 60,
                          colorFilter: ColorFilter.mode(modalityTextColor, BlendMode.srcIn),
                        ),
                        Text(
                          "${teamA.name}",
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: modalityTextColor),
                        ),
                      ],
                    ),
                  ),
                  if(widget.live)...[
                    Text(
                      "$teamAScore",
                      style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 40, color: modalityTextColor),
                    ),
                  ],
                  Text(
                    "X",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 35, color: modalityTextColor),
                  ),
                  if(widget.live)...[
                    Text(
                      "$teamBScore",
                      style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 40, color: modalityTextColor),
                    ),
                  ],
                  SizedBox(
                    width: 100,
                    height: 120,
                    child: Column(
                      spacing: 5,
                      children: [
                        SvgPicture.asset(
                          AppIcones.emblemas[teamB.emblem ?? "emblema_2"]!,
                          width: 60,
                          colorFilter: ColorFilter.mode(modalityTextColor, BlendMode.srcIn),
                        ),
                        Text(
                          "${teamB.name}",
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: modalityTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if(widget.live)...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        TimerCounterWidget(game: widget.game, color: AppColors.white),
                        Container(
                          height: 20,
                          width: 50,
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: AppColors.white.withAlpha(100),
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: const AnimatedEllipsis(dotSize: 5, dotColor: AppColors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ]else...[
                Column(
                  spacing: 5,
                  children: [
                    Text(
                      "Previsão de Duração",
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(color: modalityTextColor),
                    ),
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 15,
                          color: modalityTextColor
                        ),
                        Text(
                          "$gameStartTime - $gameEndTime",
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(color: modalityTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              ButtonTextWidget(
                action: () {
                  ref.read(gameSessionProvider.notifier).setGame(widget.game, false);
                  context.push('/games/overview');
                },
                width: 80,
                height: 30,
                text: widget.live ? "Acompanhar" : "Iniciar",
                icon: widget.live ? null : Icons.play_arrow ,
                backgroundColor: modalityColor.withAlpha(150),
                textColor: AppColors.white,
                borderRadius: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}
