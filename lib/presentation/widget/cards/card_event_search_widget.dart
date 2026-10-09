import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/date_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/services/avaliation_service.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/presentation/widget/indicators/indicator_avaliacao_widget.dart';

class CardEventSearchWidget extends ConsumerWidget {
  final EventModel event;

  const CardEventSearchWidget({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //DEFINIR CONTROLLER DE EVENTO
    AvaliationService avaliationService = AvaliationService();
    //VERIFICAR SE HÁ PARTIDAS EM ANDAMENTO
    final hasInProgress = ref.watch(gameScheduleProvider.select((s) => s.inProgressGames.isNotEmpty));
    //RESGATAR AVALIAÇÃO DO EVENTO
    double avaliations = avaliationService.getRatingAvaliation(event.avaliations);
    //RESGATAR DATA DO EVENTO
    String eventDate = DateHelper.getEventDate(event.date!);

    return InkWell(
      onTap: () {
        //DEFINIR EVENTO ATUAL NO PROVIDER E NAVEGAR
        ref.read(eventSessionProvider.notifier).setEvent(event);
        context.push('/event/view');
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            spacing: 10,
            children: [
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.title!, 
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis
                  ),
                  if(event.privacy!.name != "Public")...[
                    const Icon(
                      Icons.lock_rounded,
                      color: AppColors.grey_300,
                    )
                  ]
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: ImgHelper.getEventImg(event),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        if(event.privacy!.name == "Public")...[
                          Row(
                            spacing: 10,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  const Icon(
                                    AppIcones.calendar_solid,
                                    color: AppColors.grey_300,
                                    size: 20
                                  ),
                                  SizedBox(
                                    width: 110,
                                    child: Text(
                                      eventDate,
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: AppColors.grey_500
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]
                              ),
                              if(hasInProgress)...[
                                const Icon(
                                  Icons.sensors,
                                  size: 15,
                                  color: AppColors.red_300
                                ),
                              ]
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 5,
                            children: [
                              const Icon(
                                Icons.timer,
                                color: AppColors.grey_300,
                                size: 20
                              ),
                              Text(
                                "${event.startTime} as ${event.endTime}",
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: AppColors.grey_500
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              IndicatorAvaliacaoWidget(
                                avaliation: avaliations,
                                width: 100,
                                starSize: 15,
                              ),
                              Text(
                                avaliations.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ]else...[
                          ...List.generate(3, (index) {
                            return Container(
                              width: 200,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.grey_300.withAlpha(100),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          })
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}