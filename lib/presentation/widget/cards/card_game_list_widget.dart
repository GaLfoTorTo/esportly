import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_model.dart';

class CardGameListWidget extends ConsumerStatefulWidget {
  final double? width;
  final EventModel event;
  final GameModel game;
  final String gameDate;
  final bool active;
  final bool historic;

  const CardGameListWidget({
    super.key,
    this.width,
    required this.event,
    required this.game,
    required this.gameDate,
    this.active = false,
    this.historic = false,
  });

  @override
  ConsumerState<CardGameListWidget> createState() => _CardGameListWidgetState();
}

class _CardGameListWidgetState extends ConsumerState<CardGameListWidget> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(eventSessionProvider);
    final modalityColor = !widget.active ? AppColors.grey_500 : session.modalityColor;
    final modalityTextColor = AppColors.white;
    final modalityImage = session.modalityImage;

    var gameStartTime = DateFormat.Hm().format(widget.game.startTime!);
    var gameEndTime = DateFormat.Hm().format(widget.game.endTime!);
    int teamAScore = widget.game.result != null && widget.game.result!.teamAScore > 0 ? widget.game.result!.teamAScore : 0;
    int teamBScore = widget.game.result != null && widget.game.result!.teamBScore > 0 ? widget.game.result!.teamBScore : 0;
    String emblemaA = widget.game.teams!.first.emblem!;
    String emblemaB = widget.game.teams!.last.emblem!;

    return Card(
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: modalityImage != null ? DecorationImage(
            image: modalityImage,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              modalityColor,
              !widget.active ? BlendMode.saturation : BlendMode.multiply,
            ),
          ) : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: modalityColor,
            gradient: RadialGradient(
              center: AlignmentGeometry.bottomRight,
              radius: 2.3,
              colors: [
                modalityColor.withAlpha(100),
                modalityColor,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "#${widget.game.number}",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: modalityTextColor),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(
                      AppIcones.emblemas[emblemaA]!,
                      width: 50,
                      height: 50,
                      colorFilter: ColorFilter.mode(modalityTextColor, BlendMode.srcIn),
                    ),
                    Column(
                      spacing: 5,
                      children: [
                        if(widget.gameDate.isNotEmpty)...[
                          Text(
                            widget.gameDate,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: modalityTextColor,
                              fontSize: !widget.historic ? 18 : 16,
                            ),
                          ),
                        ],
                        if (widget.historic) ...[
                          Row(
                            spacing: 20,
                            children: [
                              Text(
                                "$teamAScore",
                                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  color: modalityTextColor,
                                  fontSize: 42,
                                ),
                              ),
                              Text(
                                "X",
                                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: modalityTextColor),
                              ),
                              Text(
                                "$teamBScore",
                                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  color: modalityTextColor,
                                  fontSize: 42,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                    ),
                    SvgPicture.asset(
                      AppIcones.emblemas[emblemaB]!,
                      width: 50,
                      height: 50,
                      colorFilter: ColorFilter.mode(modalityTextColor, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
