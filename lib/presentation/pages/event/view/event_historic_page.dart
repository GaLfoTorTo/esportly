import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/core/helpers/date_helper.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/pages/event/error/erro_historic_game_page.dart';
import 'package:esportly/presentation/widget/skeletons/skeleton_games_widget.dart';
import 'package:esportly/presentation/widget/bars/header_widget.dart';
import 'package:esportly/presentation/widget/cards/card_game_list_widget.dart';

class EventHistoricPage extends ConsumerStatefulWidget {
  const EventHistoricPage({super.key});

  @override
  ConsumerState<EventHistoricPage> createState() => _EventHistoricPageState();
}

class _EventHistoricPageState extends ConsumerState<EventHistoricPage> with SingleTickerProviderStateMixin {
  late EventModel event;
  late TabController _tabController;
  List<String?> tabs = [];

  @override
  void initState() {
    super.initState();
    event = ref.read(eventSessionProvider).event!;
    final finishedGames = ref.read(gameScheduleProvider).finishedGames;
    if (finishedGames.isNotEmpty) {
      tabs = finishedGames.keys.toList();
      _tabController = TabController(length: tabs.length, vsync: this);
    } else {
      _tabController = TabController(length: 1, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dimensions = MediaQuery.of(context).size;
    final schedule = ref.watch(gameScheduleProvider);

    return Scaffold(
      appBar: HeaderWidget(
        title: "Histórico",
        leftAction: () => context.pop(),
        shadow: false,
      ),
      body: SafeArea(
        child: Builder(builder: (_) {
          if (!schedule.loading) {
            return const SkeletonGamesWidget();
          }

          if (schedule.finishedGames.isEmpty && tabs.isEmpty) {
            return const ErroHistoricGamePage();
          }

          if (schedule.finishedGames.isNotEmpty && tabs.isNotEmpty) {
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: tabs.map((tab) {
                    return SizedBox(
                      width: 100,
                      height: 50,
                      child: Tab(text: tab),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: schedule.finishedGames.entries.map((entry) {
                      final List<GameModel>? listGames = entry.value;
                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        children: listGames!.map((game) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: CardGameListWidget(
                              width: dimensions.width - 20,
                              event: event,
                              game: game,
                              gameDate: DateHelper.getDateLabel(game.createdAt!),
                              active: false,
                              historic: true,
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        }),
      ),
    );
  }
}
