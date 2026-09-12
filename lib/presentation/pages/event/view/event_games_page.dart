import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/date_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/widget/cards/card_game_widget.dart';
import 'package:esportly/presentation/widget/cards/card_game_live_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/skeletons/skeleton_games_widget.dart';
import 'package:esportly/presentation/pages/event/error/erro_game_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EventGamesPage extends ConsumerStatefulWidget {
  const EventGamesPage({super.key});

  @override
  ConsumerState<EventGamesPage> createState() => _EventGamesPageState();
}

class _EventGamesPageState extends ConsumerState<EventGamesPage> {
  late PageController inProgressController;
  late EventModel event;

  @override
  void initState() {
    super.initState();
    event = ref.read(eventSessionProvider).event!;
    inProgressController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    var dimensions = MediaQuery.of(context).size;
    final gameSession = ref.watch(gameScheduleProvider);
    final isToday = ref.read(gameScheduleProvider.notifier).isToday();
    String date = DateHelper.getDateLabel(ref.read(gameScheduleProvider).date!);

    //ESTADO - ITEMS EVENTO
    final modalityMap = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality!.name);
    Color modalityColor = modalityMap['color'];
    Color modalityTextColor = modalityMap['textColor'];

    return SingleChildScrollView(
      child: Container(
        width: dimensions.width,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(
          spacing: 10,
          children: [
            Text(
              "Agenda",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              "Explore a agenda completa das partidas da pelada. A quantidade de partidas e calculada a partir das informações de duração e horários de início e fim da pelada definidos pelo organizador.",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Builder(builder: (_) {
              List<Widget> listGames = [];

              if (gameSession.loading) {
                return const SkeletonGamesWidget();
              }

              if (!gameSession.hasGames) {
                return const ErroGamePage();
              }

              if (gameSession.date != null && isToday) {
                //PARTIDAS EM ANDAMENTO
                if (gameSession.inProgressGames.isNotEmpty) {
                  listGames.addAll([
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.red_300,
                            ),
                            child: const Icon(
                              Icons.sensors,
                              size: 15,
                              color: AppColors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: dimensions.width,
                      child: PageView(
                        controller: inProgressController,
                        children: [
                          ...gameSession.inProgressGames.take(3).map((game) {
                            return CardGameLiveWidget(event: event, game: game!);
                          }),
                        ],
                      ),
                    ),
                    if (gameSession.inProgressGames.length > 1) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: SmoothPageIndicator(
                          controller: inProgressController,
                          count: gameSession.inProgressGames.length < 3 ? gameSession.inProgressGames.length : 3,
                          effect: const ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: AppColors.blue_500,
                            dotColor: AppColors.grey_300,
                            expansionFactor: 2,
                          ),
                        ),
                      ),
                    ],
                  ]);
                }
                //PARTIDAS AGENDADAS (HOJE)
                if (gameSession.nextGames.isNotEmpty) {
                  listGames.addAll([
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Próximas partidas  - $date',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      spacing: 20,
                      children: gameSession.nextGames.asMap().entries.take(5).map((item) {
                        final key = item.key;
                        final game = item.value;
                        return CardGameWidget(
                          width: dimensions.width - 10,
                          event: event,
                          game: game!,
                          gameDate: date,
                          navigate: key < 1,
                          active: key < 1,
                        );
                      }).toList(),
                    ),
                    ButtonTextWidget(
                      text: "Ver Mais ${gameSession.nextGames.length}",
                      width: 120,
                      height: 20,
                      textColor: modalityTextColor,
                      backgroundColor: modalityColor.withAlpha(20),
                      action: () => {},
                    ),
                  ]);
                }
              }
              //PARTIDAS AGENDADAS (PROXIMO DIA)
              if (gameSession.scheduledGames.isNotEmpty) {
                date = DateHelper.getDateLabel(gameSession.scheduledGames.first!.date!);
                listGames.addAll([
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Partidas Agendadas - $date',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    spacing: 20,
                    children: [
                      ...gameSession.scheduledGames.take(10).map((game) {
                        return CardGameWidget(
                          width: dimensions.width - 10,
                          event: event,
                          game: game!,
                          gameDate: date,
                          active: false,
                        );
                      }),
                    ],
                  ),
                  ButtonTextWidget(
                    text: "Ver Mais ${gameSession.scheduledGames.length}",
                    width: 100,
                    height: 20,
                    textColor: AppColors.green_300,
                    backgroundColor: AppColors.green_300.withAlpha(20),
                    action: () => {},
                  ),
                ]);
              }

              return listGames.isNotEmpty
                  ? Column(children: listGames)
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
