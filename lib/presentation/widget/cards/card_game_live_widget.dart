import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/data/models/team_model.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/presentation/widget/animated/animated_ellipsis.dart';
import 'package:esportly/presentation/widget/others/timer_counter_widget.dart';

class CardGameLiveWidget extends ConsumerStatefulWidget {
  final EventModel event;
  final GameModel game;
  const CardGameLiveWidget({
    super.key,
    required this.event,
    required this.game,
  });

  @override
  ConsumerState<CardGameLiveWidget> createState() => _CardGameLiveWidgetState();
}

class _CardGameLiveWidgetState extends ConsumerState<CardGameLiveWidget> {
  late Color modalityColor;
  late Color modalityTextColor;
  late String modalityImage;

  @override
  void initState() {
    super.initState();
    modalityColor = ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality!.name)['color'];
    modalityTextColor = ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality!.name)['textColor'];
    modalityImage = ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality!.name)['image'];
  }

  @override
  Widget build(BuildContext context) {
    var dimensions = MediaQuery.of(context).size;
    final teamAScore = ref.watch(gameMatchProvider.select((s) => s.teamAScore));
    final teamBScore = ref.watch(gameMatchProvider.select((s) => s.teamBScore));
    final GameModel game = widget.game;
    final TeamModel teamA = widget.game.teams!.first;
    final TeamModel teamB = widget.game.teams!.last;

    return InkWell(
      onTap: () {
        ref.read(gameSessionProvider.notifier).setGame(widget.game);
        context.push('/games/overview');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: dimensions.width - 10,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: modalityColor,
          image: DecorationImage(
            image: AssetImage(modalityImage) as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(modalityColor.withAlpha(200), BlendMode.srcATop),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark_500.withAlpha(50),
              spreadRadius: 0.5,
              blurRadius: 5,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 150,
              decoration: const BoxDecoration(
                color: AppColors.red_300,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(70),
                  bottomRight: Radius.circular(70),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: const Icon(
                  Icons.sensors,
                  size: 15,
                  color: AppColors.white
                ),
              ),
            ),
            Text(
              "#${game.number}",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: modalityTextColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        AppIcones.emblemas["emblema_1"]!,
                        width: 60,
                        colorFilter: ColorFilter.mode(modalityTextColor, BlendMode.srcIn),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "${teamA.name}",
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: modalityTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "$teamAScore",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 40, color: AppColors.white),
                  ),
                ),
                Text(
                  ":",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 35, color: AppColors.white),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "$teamBScore",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 40, color: AppColors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        AppIcones.emblemas['emblema_2']!,
                        width: 60,
                        colorFilter: ColorFilter.mode(modalityTextColor, BlendMode.srcIn),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "${teamB.name}",
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: modalityTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          ],
        ),
      ),
    );
  }
}
