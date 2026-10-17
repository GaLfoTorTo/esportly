import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/theme/app_images.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/providers/event/event_room_provider.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/images/img_group_circle_widget.dart';
import 'package:esportly/presentation/widget/indicators/indicator_loading_widget.dart';

class CardEventRoomWidget extends ConsumerStatefulWidget {
  final EventModel event;

  const CardEventRoomWidget({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<CardEventRoomWidget> createState() => _CardEventRoomWidgetState();
}

class _CardEventRoomWidgetState extends ConsumerState<CardEventRoomWidget> {

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

  //FUNÇÃO DE ENTRADA NA SALA DO EVENTO
  Future<void> join() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: IndicatorLoadingWidget()),
    );
    final event = ref.read(eventSessionProvider).event;
    if (event == null || event.uuid != widget.event.uuid) {
      await ref.read(eventSessionProvider.notifier).setEvent(widget.event);
    }
    while (ref.read(gameScheduleProvider).loading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    final roomSession = ref.read(eventRoomProvider);
    if (roomSession.room) await ref.read(eventRoomProvider.notifier).enterRoom();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      context.push('/event/day');
    }
  }

  @override
  Widget build(BuildContext context) {
    //RESGATAR DIMENSOES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;
    //VERIFICAR SE HÁ PARTIDAS EM ANDAMENTO PARA ESTE EVENTO
    final roomSession = ref.watch(eventRoomProvider);
    final room = roomSession.room;
    final user = sl<UserModel>(instanceName: 'user');
    final event = widget.event;
    final canManage = userRoles(event, user);
    final roomAccessible = canManage || room;
    //ESTADO - ITEMS EVENTO
    Color modalityColor = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality?.name ?? 'Football')['color'];
    Color modalityTextColor = AppColors.white;//ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality?.name ?? 'Football')['textColor'];
    String modalityImage = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality?.name ?? 'Football')['image'];
    //RESGATAR DATA DO EVENTO
    final now = DateTime.now();
    final day = now.day.toString();
    final month = DateFormat('MMM').format(now).toUpperCase().toString();
    //RESGATAR IMAGENS DOS USUARIOS
    List<String> userImages = event.participants!.take(3).map((user) => user.photo ?? AppImages.userDefault).toList();
            
    return Card(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: modalityColor,
          image: DecorationImage(
            image: AssetImage(modalityImage) as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              modalityColor.withAlpha(200), 
              BlendMode.multiply,
            )
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "${event.title}",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: modalityTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if(room)...[
                  Container(
                    width: 30,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.red_300,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: const Icon(
                      Icons.sensors,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        month,
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: AppColors.dark_300
                        )
                      ),
                      Text(
                        day,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: AppColors.dark_300
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        Icon(
                          Icons.timer,
                          color: modalityTextColor,
                          size: 25,
                        ),
                        Text(
                          "${event.startTime!.substring(0,5)} - ${event.endTime!.substring(0,5)}",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: modalityTextColor
                          )
                        ),
                      ]
                    ),
                    Row(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: modalityTextColor,
                          size: 25,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: dimensions.width * 0.7,
                              child: Text(
                                "${event.address?.street}",
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: modalityTextColor
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(
                              width: dimensions.width * 0.7,
                              child: Text(
                                "${event.address?.city}/${event.address?.state}",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: modalityTextColor
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ]
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ImgGroupCircularWidget(
                  size: 40, 
                  borderColor: modalityTextColor,
                  images: userImages,
                ),
                IconButton(
                  onPressed: () => print('share'), 
                  icon: Icon(
                    Icons.share,
                    color: modalityTextColor,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => print('heart'), 
                  icon: Icon(
                    AppIcones.heart_solid,
                    color: modalityTextColor,
                    size: 20,
                  ),
                ),
                roomAccessible
                    ? ButtonTextWidget(
                        action: join,
                        width: 80,
                        height: 30,
                        text: "Entrar",
                        backgroundColor: modalityColor.withAlpha(200),
                        textColor: modalityTextColor,
                        borderRadius: 50,
                      )
                    : ButtonTextWidget(
                        action: () {},
                        disabled: true,
                        width: 110,
                        height: 30,
                        text: "Sala Fechada",
                        icon: Icons.lock_rounded,
                        backgroundColor: AppColors.grey_300.withAlpha(60),
                        textColor: AppColors.grey_300,
                        borderRadius: 50,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}