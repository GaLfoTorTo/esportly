import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/date_helper.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/services/avaliation_service.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/presentation/widget/indicators/indicator_avaliacao_widget.dart';

class CardEventListWidget extends ConsumerWidget {
  final EventModel event;

  const CardEventListWidget({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    final dimensions = MediaQuery.of(context).size;
    final eventSession = ref.watch(eventSessionProvider);
    final AvaliationService avaliationService = AvaliationService();
    final inLive = ref.watch(gameScheduleProvider.select((s) => s.inProgressGames.isNotEmpty));
    final double avaliations = avaliationService.getRatingAvaliation(event.avaliations);
    final String eventDate = DateHelper.getEventDate(event.date!);

    return Card(
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: dimensions.width,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              image: DecorationImage(
                image: eventSession.modalityImage ?? ImgHelper.getEventImg(event),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: dimensions.width * 0.4,
                      child: Text(
                        event.title!,
                        style: Theme.of(context).textTheme.titleLarge
                      ),
                    ),
                    SizedBox(
                      width: dimensions.width * 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IndicatorAvaliacaoWidget(
                            avaliation: avaliations,
                            width: dimensions.width / 4.5,
                            starSize: 15,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    const Icon(Icons.calendar_month),
                    Text(
                      eventDate,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    const Icon(Icons.timer),
                    Text(
                      "${event.startTime?.substring(0, 5)} as ${event.endTime?.substring(0, 5)}",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ 
                    Row(
                      spacing: 5,
                      children: [
                        const Icon(Icons.location_on),
                        Text(
                          "${event.address!.city} / ${event.address!.state}",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    if(inLive)...[
                      const Icon(
                        Icons.sensors,
                        size: 15,
                        color: AppColors.red_300
                      ),
                    ]
                  ]
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}