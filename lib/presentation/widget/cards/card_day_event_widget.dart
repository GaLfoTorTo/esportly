import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/theme/app_images.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/images/img_group_circle_widget.dart';

class CardDayEventWidget extends ConsumerWidget {
  final EventModel event;

  const CardDayEventWidget({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //RESGATAR DIMENSOES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;
    //VERIFICAR SE HÁ PARTIDAS EM ANDAMENTO PARA ESTE EVENTO
    final inProgressGames = ref.watch(gameScheduleProvider.select((s) => s.inProgressGames));
    //ESTADO - ITEMS EVENTO
    Color modalityColor = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality!.name)['color'];
    Color modalityTextColor = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality!.name)['textColor'];
    String modalityImage = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality!.name)['image'];
    //RESGATAR DATA DO EVENTO
    final now = DateTime.now();
    final day = now.day.toString();
    final month = DateFormat('MMM').format(now).toUpperCase().toString();
    //RESGATAR IMAGENS DOS USUARIOS
    List<String> userImages = event.participants!.take(3).map((user) => user.photo ?? AppImages.userDefault).toList();
    //VERIFICAR SE TEM PARTIDA EM ANDAMENTO
    bool hasGame = inProgressGames.any((gameEvent) => gameEvent?.id == event.id);
            
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
                Column(
                  children: [
                    SizedBox(
                      width: dimensions.width * 0.6,
                      child: Text(
                        "${event.title}",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: modalityTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                if(hasGame)...[
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
                ButtonTextWidget(
                  action: () {
                    ref.read(eventSessionProvider.notifier).setEvent(event);
                    context.go('/event/day');
                  },
                  width: 80,
                  height: 30,
                  text: "Entrar",
                  backgroundColor: modalityColor.withAlpha(200),
                    textColor: modalityTextColor,
                  borderRadius: 50,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}