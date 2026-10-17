import 'package:esportly/core/providers/game/game_control_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/providers/event/event_room_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_room_provider.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/pages/games/detail/game_escalation_page.dart';
import 'package:esportly/presentation/pages/games/detail/game_overview_page.dart';
import 'package:esportly/presentation/pages/games/detail/game_statistics_page.dart';
import 'package:esportly/presentation/pages/games/detail/game_timeline_page.dart';
import 'package:esportly/presentation/widget/bars/header_scroll_widget.dart';
import 'package:esportly/presentation/widget/buttons/float_button_widget.dart';
import 'package:esportly/presentation/widget/dialogs/dialog_alert_start.dart';
import 'package:esportly/presentation/widget/bottomSheet/bottomsheet_game_control.dart';
import 'package:esportly/presentation/widget/cards/card_score_widget.dart';

class GameDetailPage extends ConsumerStatefulWidget {
  const GameDetailPage({super.key});

  @override
  ConsumerState<GameDetailPage> createState() => GameDetailPageState();
}

class GameDetailPageState extends ConsumerState<GameDetailPage> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final ScrollController scrollController = ScrollController();
  double tabMargin = 10.0;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    scrollController.addListener(handleScroll);
    //INICIAR PARTICIPANTES
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(gameSessionProvider).ready) {
        showDialog(
          context: context, 
          builder: (_) => const DialogAlertStart()
        );
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  //FUNÇÃO DE ALTERAÇÃO DE SCROLL
  void handleScroll() {
    final double pos = scrollController.position.pixels;
    setState(() { tabMargin = pos >= 300 ? 0 : 10; });
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final eventSession = ref.watch(eventSessionProvider);
    final gameSession = ref.watch(gameSessionProvider);
    final gameControlSession = ref.watch(gameControlProvider);
    final liveSession = ref.watch(gameRoomProvider);
    final modalityColor = eventSession.modalityColor;
    final modalityTextColor = eventSession.modalityTextColor;

    const List<String> tabs = ['Resumo', 'Escalações', 'Estatísticas', 'Timeline'];

    return Scaffold(
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            HeaderScrollWidget(
              title: "Partida #${gameSession.currentGame?.number}",
              backgroundColor: modalityColor,
              leftAction: () => context.pop(),
              rightIcon: AppIcones.cog_solid,
              rightAction: () => context.push('/games/config'),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                if (gameSession.currentGame != null)
                  const CardScoreWidget(),
              ]),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                child: Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.dark_500
                      : AppColors.white,
                  margin: EdgeInsets.symmetric(horizontal: tabMargin),
                  child: TabBar(
                    controller: tabController,
                    onTap: (i) => setState(() => tabIndex = i),
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 5, color: modalityColor),
                      insets: EdgeInsets.symmetric(horizontal: dimensions.width / 5),
                    ),
                    labelColor: modalityColor,
                    labelStyle: const TextStyle(
                      color: AppColors.grey_500,
                      fontWeight: FontWeight.normal,
                    ),
                    unselectedLabelColor: AppColors.grey_500,
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
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: const [
            GameOverviewPage(),
            GameEscalationPage(),
            GameStatisticsPage(),
            GameTimelinePage(),
          ],
        ),
      ),
      floatingActionButton: gameControlSession.isGameRunning && tabIndex == 0
          ? FloatButtonWidget(
              floatKey: "control_games",
              icon: Icons.play_arrow,
              backgroundColor: modalityColor,
              color: modalityTextColor,
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const BottomsheetGameControl(),
              ),
            )
          : const SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _SliverAppBarDelegate({required this.child});

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) =>
      child != oldDelegate.child;
}
