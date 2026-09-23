import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/presentation/widget/bars/header_widget.dart';
import 'package:esportly/presentation/widget/badges/position_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/cards/card_day_game_widget.dart';
import 'package:esportly/presentation/widget/cards/card_game_live_widget.dart';
import 'package:esportly/presentation/widget/cards/card_game_widget.dart';
import 'package:esportly/presentation/widget/cards/card_mvp_widget.dart';
import 'package:esportly/presentation/widget/cards/card_player_game_widget.dart';
import 'package:esportly/presentation/widget/images/img_circle_widget.dart';
import 'package:esportly/presentation/widget/indicators/indicator_page_widget.dart';

class EventDayPage extends ConsumerStatefulWidget {
  const EventDayPage({super.key});

  @override
  ConsumerState<EventDayPage> createState() => EventDayPageState();
}

class EventDayPageState extends ConsumerState<EventDayPage> {
  late final PageController nextGamesController;

  @override
  void initState() {
    super.initState();
    nextGamesController = PageController();
  }

  @override
  void dispose() {
    nextGamesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final schedule = ref.watch(gameScheduleProvider);
    final EventModel event = ref.watch(eventSessionProvider.select((s) => s.event!));

    Color modalityColor = ModalityHelper.getEventModalityColor(
      event.gameConfig?.category ?? event.modality!.name,
    )['color'];

    final highlightsPlayers = event.participants!
        .take(3)
        .where((u) => u.participants!.any((p) => p.roles!.contains("Player")));

    return Scaffold(
      appBar: HeaderWidget(
        title: 'Dia de Jogo',
        backgroundColor: modalityColor,
        leftAction: () => context.pop(),
        rightIcon: Icons.history,
        rightAction: () => context.push('/games/historic'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ImgCircularWidget(size: 30, image: event.photo, element: "event"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("${event.title}", style: Theme.of(context).textTheme.titleSmall),
                    ),
                  ],
                ),
                if (schedule.inProgressGames.isNotEmpty) ...[
                  CardGameLiveWidget(event: event, game: schedule.inProgressGames.first!),
                ] else ...[
                  CardDayGameWidget(event: event),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Próximas partidas', style: Theme.of(context).textTheme.titleSmall),
                    ButtonTextWidget(
                      text: "Ver Mais", icon: Icons.add_rounded,
                      width: 100, height: 20,
                      textColor: modalityColor, backgroundColor: Colors.transparent,
                      action: () {},
                    ),
                  ],
                ),
                SizedBox(
                  width: dimensions.width,
                  height: 150,
                  child: PageView(
                    controller: nextGamesController,
                    children: schedule.nextGames.take(3).map((g) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 10),
                        child: CardGameWidget(
                          width: dimensions.width - 10,
                          event: event, game: g!,
                          gameDate: "Hoje", navigate: false, active: true,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                IndicatorPageWidget(pageController: nextGamesController, options: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Jogadores Presentes', style: Theme.of(context).textTheme.titleSmall),
                    ButtonTextWidget(
                      text: "Ver Mais", icon: Icons.add_rounded,
                      width: 100, height: 20,
                      textColor: modalityColor, backgroundColor: Colors.transparent,
                      action: () {},
                    ),
                  ],
                ),
                SizedBox(
                  height: 210,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 15,
                      children: event.participants!.take(5).map((UserModel user) {
                        return CardPlayerGameWidget(user: user);
                      }).toList(),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('MVP', style: Theme.of(context).textTheme.titleSmall)],
                ),
                CardMvpWidget(event: event),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Destaques', style: Theme.of(context).textTheme.titleSmall)],
                ),
                Column(
                  spacing: 10,
                  children: highlightsPlayers.map((user) {
                    if (user.player == null) return const SizedBox.shrink();
                    return Card(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: AppColors.dark_500.withAlpha(30), spreadRadius: 0.5, blurRadius: 5, offset: const Offset(2, 5))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 80, height: 80, child: CircleAvatar(backgroundImage: ImgHelper.getUserImg(user.photo))),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(UserHelper.getFullName(user), style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text("@${user.userName}", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.grey_300), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      if (user.player!.getMainPosition(event.modality!.name) != null) PositionWidget(position: user.player!.getMainPosition(event.modality!.name)!.alias, mainPosition: true, width: 35, height: 25, textSide: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: modalityColor.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Text("3 Gols", style: Theme.of(context).textTheme.titleSmall!.copyWith(color: modalityColor)),
                                  Icon(Icons.sports_soccer, size: 30, color: modalityColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
