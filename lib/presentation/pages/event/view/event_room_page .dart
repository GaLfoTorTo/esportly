import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/helpers/game_action_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_event_model.dart';
import 'package:esportly/data/models/team_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/core/providers/event/event_room_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/presentation/widget/badges/position_widget.dart';
import 'package:esportly/presentation/widget/bars/header_widget.dart';
import 'package:esportly/presentation/widget/indicators/indicator_loading_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_outline_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/cards/card_game_widget.dart';
import 'package:esportly/presentation/widget/cards/card_game_list_widget.dart';
import 'package:esportly/presentation/widget/cards/card_mvp_widget.dart';
import 'package:esportly/presentation/widget/cards/card_player_game_widget.dart';
import 'package:esportly/presentation/widget/cards/card_performance_widget.dart';
import 'package:esportly/presentation/widget/images/img_circle_widget.dart';
import 'package:esportly/presentation/widget/indicators/indicator_page_widget.dart';
import 'package:esportly/presentation/widget/bottomSheet/bottomsheet_game_presentes.dart';

class EventRoomPage extends ConsumerStatefulWidget {
  const EventRoomPage({super.key});

  @override
  ConsumerState<EventRoomPage> createState() => EventRoomPageState();
}

class EventRoomPageState extends ConsumerState<EventRoomPage> {
  late final PageController _nextGamesController;

  @override
  void initState() {
    super.initState();
    _nextGamesController = PageController();
  }

  @override
  void dispose() {
    _nextGamesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    //PROVIDERS
    final eventSession = ref.watch(eventSessionProvider);
    final scheduleSession = ref.watch(gameScheduleProvider);
    final matchSession = ref.watch(gameMatchProvider);
    //ESTADOS
    final event = eventSession.event!;
    final gameEvents = ref.watch(gameMatchProvider.select((s) => s.gameEvents));
    final isLive = scheduleSession.inProgressGames.isNotEmpty;
    final finishedGames = scheduleSession.finishedGames.isNotEmpty;
    final participantsPresent = ref.watch(eventRoomProvider.select((s) => s.participantsPresent));

    final modalityColor = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality!.name)['color'] as Color;
    final modalityTextColor = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality!.name)['textColor'] as Color;

    final players = (event.participants ?? [])
        .where((u) => u.participants?.any((p) => p.roles?.contains('Player') ?? false) ?? false)
        .toList();

    return Scaffold(
      appBar: HeaderWidget(
        title: 'Dia de Jogo',
        backgroundColor: modalityColor,
        leftAction: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            spacing: 10,
            children: [
              _HeroSection(
                event: event,
                modalityColor: modalityColor,
                modalityTextColor: modalityTextColor,
              ),
              CardPerformanceWidget(
                onStatusChanged: (status) {},
              ),
              //PARTIDA AO VIVO
              _SectionHeader(
                title: isLive ? 'Partida Ao Vivo' : 'Próxima Partida',
                icon: isLive ? Icons.sensors : Icons.sports,
                color: isLive ? AppColors.red_300 : modalityColor,
                live: isLive,
              ),
              CardGameWidget(
                event: event,
                game: isLive ? scheduleSession.inProgressGames.first! : scheduleSession.nextGames.first!,
                live: isLive,
              ),             
              // FEED DE EVENTOS DA PARTIDA
              if(finishedGames && gameEvents.isNotEmpty)...[
                _SectionHeader(
                  title: 'Eventos da Partida',
                  icon: Icons.bolt_rounded,
                  color: modalityColor,
                ),
                _GameEventsFeed(
                  events: gameEvents.take(8).toList(),
                  teamA: matchSession.teamA,
                  teamB: matchSession.teamB,
                  color: modalityColor,
                  category: event.gameConfig?.category,
                ),
              ],             
              // PRÓXIMAS PARTIDAS
              if (scheduleSession.nextGames.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Previsão de Partidas',
                  icon: Icons.sports_rounded,
                  color: modalityColor,
                  actionLabel: 'Ver Mais',
                  action: () => context.push('/event/view', extra: 1),
                ),
                SizedBox(
                  width: dimensions.width,
                  height: 180,
                  child: PageView(
                    controller: _nextGamesController,
                    children: scheduleSession.nextGames.skip(1).take(3).map((g) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 10),
                        child: CardGameListWidget(
                          width: dimensions.width - 10,
                          event: event,
                          game: g!,
                          gameDate: 'Hoje',
                          active: true,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                IndicatorPageWidget(
                  pageController: _nextGamesController,
                  options: scheduleSession.nextGames.length.clamp(1, 3),
                ),
              ],
                            
              // JOGADORES PRESENTES
              if (participantsPresent.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Presentes',
                  icon: Icons.groups_rounded,
                  color: modalityColor,
                  badge: '${participantsPresent.length}',
                  actionLabel: 'Ver Todos',
                  action: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
                    builder: (_) => const BottomSheetGamePresentes(),
                  ),
                ),
                SizedBox(
                  height: 210,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 12,
                      children: participantsPresent.take(8).map((u) {
                        return CardPlayerGameWidget(
                          user: u,
                          modality: event.modality?.name,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
                            
              // MVP DO DIA
              if (finishedGames) ...[
                const _SectionHeader(
                  title: 'MVP',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.yellow_500,
                ),
                CardMvpWidget(event: event),
              ],
                            
              // DESTAQUES
              if (finishedGames && players.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Destaques',
                  icon: Icons.star_rounded,
                  color: modalityColor,
                ),
                Column(
                  spacing: 10,
                  children: players.take(3).map((u) {
                    if (u.player == null) return const SizedBox.shrink();
                    return _HighlightCard(
                      user: u,
                      event: event,
                      modalityColor: modalityColor,
                      gameEvents: gameEvents,
                    );
                  }).toList(),
                ),
              ],
                            
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HERO SECTION ──────────────────────────────────────────────────────────

class _HeroSection extends ConsumerWidget {
  final EventModel event;
  final Color modalityColor;
  final Color modalityTextColor;

  const _HeroSection({
    required this.event,
    required this.modalityColor,
    required this.modalityTextColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //FUNÇÃO DE VERIFICAÇÃO DE ROLES DO USUARIO LOGADO
    bool userRoles(EventModel event, UserModel user) {
      if (event.id == null) return false;
      UserModel? userInEvent;
      for (final p in event.participants ?? <UserModel>[]) {
        if (p.id == user.id) { userInEvent = p; break; }
      }
      if (userInEvent == null) return false;
      try {
        final participant = UserHelper.getParticipant(userInEvent.participants, event.id!);
        return participant?.roles?.any((r) => r == 'Organizator' || r == 'Colaborator') ?? false;
      } catch (_) {
        return false;
      }
    }

    //ESTADOS
    final roomSession = ref.watch(eventRoomProvider);
    final user = sl<UserModel>(instanceName: 'user');
    final event = ref.watch(eventSessionProvider.select((s) => s.event!));
    final room = ref.watch(eventRoomProvider).room;
    final canManage = userRoles(event, user);
    Color color = roomSession.participantsPresent.isNotEmpty ? AppColors.green_300 : AppColors.grey_300;

    //FUNÇÃO DE ENTRADA NA SALA DO EVENTO
    Future<void> streamRoom() async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: IndicatorLoadingWidget()),
      );
      if(room) {
        await ref.read(eventRoomProvider.notifier).closeRoom();
      } else {
        await ref.read(eventRoomProvider.notifier).openRoom();
      }
      context.pop();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          //NOME E ENDEREÇO DO EVENTO
          Row(
            spacing: 10,
            children: [
              ImgCircularWidget(
                size: 44,
                image: event.photo,
                element: 'event'
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      event.title ?? '',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${event.address!.city}, ${event.address!.state}',
                          style: Theme.of(context).textTheme.labelSmall!
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: room ? AppColors.red_300 : AppColors.grey_300.withAlpha(50),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            spacing: 5,
                            children: [
                              Icon(
                                room ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                                size: 15,
                                color: AppColors.white
                              ),
                              Text(
                                "Ao Vivo",
                                style: Theme.of(context).textTheme.displaySmall!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        ),
                        //RESUMO DE PARTICIPANTES
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withAlpha(50),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 5,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 12,
                                color: color
                              ),
                              Icon(
                                Icons.people,
                                size: 15,
                                color: color
                              ),
                              Text(
                                "${roomSession.participantsPresent.length}",
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if(canManage && !room)...[
            //INDICADOR DE STATUS DA SALA
            ButtonOutlineWidget(
              text: "Sala Fechada",
              icon: room ? Icons.sensors_rounded : Icons.sensors_off_rounded,
              textColor: AppColors.white,
              backgroundColor: room ? AppColors.red_300.withAlpha(20) : Theme.of(context).cardTheme.color!.withAlpha(50),
              width: double.infinity,
              height: 30,
              action: streamRoom
            ),
          ]
        ],
      ),
    );
  }
}

// ─── SECTION HEADER ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? badge;
  final String? actionLabel;
  final VoidCallback? action;
  final bool live;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.badge,
    this.actionLabel,
    this.action,
    this.live = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 5,
          children: [
            //TITULO
            Icon(
              icon, 
              size: 18, 
              color: color
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            //INDICADORES
            if (badge != null)...[
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              )
            ],
            //INDICIADOR AO VIVO
            if (live)...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.red_300,
                  shape: BoxShape.circle,
                ),
              ),
            ]
          ],
        ),
        //BOTÃO DE AÇÃO
        if (actionLabel != null && action != null)...[
          ButtonTextWidget(
            width: 100,
            height: 20,
            text: actionLabel,
            textSize: 10,
            icon: Icons.add_rounded,
            backgroundColor: color.withAlpha(20),
            textColor: color,
            action: () => action!()
          ),
        ]
      ],
    );
  }
}

// ─── LIVE BADGE ──────────────────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.45, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.red_300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Icon(
                Icons.circle, 
                size: 7, 
                color: AppColors.white
              ),
              Text(
                'AO VIVO',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── GAME EVENTS FEED ────────────────────────────────────────────────────────

class _GameEventsFeed extends StatelessWidget {
  final List<GameEventModel> events;
  final TeamModel teamA;
  final TeamModel teamB;
  final Color color;
  final String? category;

  const _GameEventsFeed({
    required this.events,
    required this.teamA,
    required this.teamB,
    required this.color,
    this.category,
  });

  static const List<GameActionConfig> _sharedActions = [
    GameActionConfig(label: 'Início',     icon: Icons.play_arrow_rounded,      color: AppColors.green_300,  event: GameEvent.StartGame,   requiresPlayer: false),
    GameActionConfig(label: 'Fim',        icon: Icons.stop_rounded,            color: AppColors.red_300,    event: GameEvent.EndGame,     requiresPlayer: false),
    GameActionConfig(label: 'Intervalo',  icon: Icons.pause_rounded,           color: AppColors.grey_500,   event: GameEvent.HalfTimeEnd, requiresPlayer: false),
    GameActionConfig(label: 'Acréscimos', icon: Icons.more_time_rounded,       color: AppColors.orange_300, event: GameEvent.ExtraTime,   requiresPlayer: false),
    GameActionConfig(label: 'Lesão',      icon: Icons.medical_services_rounded, color: AppColors.red_200,   event: GameEvent.Injury),
  ];

  @override
  Widget build(BuildContext context) {
    final lookup = <GameEvent, GameActionConfig>{
      for (final a in [...GameActionHelper.getActions(category), ..._sharedActions]) a.event: a,
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: events.asMap().entries.map((entry) {
          final i = entry.key;
          final event = entry.value;
          final meta = event.type != null ? lookup[event.type] : null;
          final metaIcon  = meta?.icon  ?? Icons.circle_rounded;
          final metaColor = meta?.color ?? AppColors.grey_500;
          final metaLabel = meta?.label ?? (event.type?.name ?? 'Evento');
          final isTeamA = event.teamId == teamA.id;
          final teamName = isTeamA ? (teamA.name ?? 'Time A') : (teamB.name ?? 'Time B');

          return Column(
            children: [
              if (i > 0) Divider(height: 1, color: color.withAlpha(20)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    if (!isTeamA) const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: metaColor.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(metaIcon, size: 18, color: metaColor),
                        ),
                        Column(
                          crossAxisAlignment: isTeamA
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          spacing: 1,
                          children: [
                            Text(
                              metaLabel,
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              teamName,
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                color: AppColors.grey_700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isTeamA) const Spacer(),
                    if (event.minute != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${event.minute}'",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── HIGHLIGHT CARD ──────────────────────────────────────────────────────────

class _HighlightCard extends StatelessWidget {
  final UserModel user;
  final EventModel event;
  final Color modalityColor;
  final List<GameEventModel> gameEvents;

  const _HighlightCard({
    required this.user,
    required this.event,
    required this.modalityColor,
    required this.gameEvents,
  });

  int _countGoals() {
    if (user.id == null) return 0;
    return gameEvents
        .where((e) => e.userId == user.id && e.type == GameEvent.Goal)
        .length;
  }

  int _countAssists() {
    if (user.id == null) return 0;
    return gameEvents
        .where((e) => e.userId == user.id && e.type == GameEvent.Assist)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final goals = _countGoals();
    final assists = _countAssists();
    final mainPos = user.player?.getMainPosition(event.modality?.name ?? '');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircleAvatar(
                backgroundImage: ImgHelper.getUserImg(user.photo),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    UserHelper.getFullName(user),
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@${user.userName}',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: AppColors.grey_500,
                    ),
                  ),
                  if (mainPos != null)
                    PositionWidget(
                      position: mainPos.alias,
                      mainPosition: true,
                      width: 35,
                      height: 22,
                      textSide: 10,
                    ),
                ],
              ),
            ),
            Row(
              spacing: 8,
              children: [
                if (goals > 0)
                  _MiniStat(
                    icon: Icons.sports_soccer_rounded,
                    value: '$goals',
                    color: modalityColor,
                  ),
                if (assists > 0)
                  _MiniStat(
                    icon: Icons.handshake_rounded,
                    value: '$assists',
                    color: modalityColor,
                  ),
                if (goals == 0 && assists == 0)
                  _MiniStat(
                    icon: Icons.star_rounded,
                    value: '—',
                    color: AppColors.grey_300,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          Icon(icon, size: 22, color: color),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
