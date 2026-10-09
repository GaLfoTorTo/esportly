import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/event_helper.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/presentation/widget/images/img_group_circle_widget.dart';

class CardEscalationEventWidget extends ConsumerWidget {
  final EventModel event;

  const CardEscalationEventWidget({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensions = MediaQuery.of(context).size;
    final String modalityImage = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality?.name ?? 'Football')['image'];

    final participants = event.participants ?? [];
    final managers = participants.where((u) => u.manager != null).toList();
    final players = participants.where((u) => u.player != null).toList();

    final user = sl<UserModel>(instanceName: 'user');
    final hasEscalation = (user.manager?.escalations ?? []).any((e) => e.eventId == event.id);

    return Card(
      child: Column(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          Container(
            width: dimensions.width,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              image: DecorationImage(
                image: event.photo == null
                    ? AssetImage(modalityImage) as ImageProvider
                    : ImgHelper.getEventImg(event),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      event.title!,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(
                      size: 30,
                      hasEscalation 
                        ? Icons.check_circle
                        : Icons.error,
                      color: hasEscalation
                        ? AppColors.green_300
                        : AppColors.yellow_500,
                    ),
                  ],
                ),
                const Divider(color: AppColors.grey_700),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(2, ((p){
                    final items = p == 0 ? managers : players;
                    final role = p == 0 ? 'Técnicos' : 'Jogadores';
                    final icon = p == 0 ? Icons.assignment_ind_rounded : Icons.shopping_cart;

                    return Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            role,
                            style: Theme.of(context).textTheme.titleSmall
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.green_300.withAlpha(50),
                            border: Border.all(color: AppColors.green_300),
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: Row(
                            spacing: 2,
                            children: [
                              ImgGroupCircularWidget(
                                size: 30,
                                side: "right",
                                images: items
                                    .take(3)
                                    .map((i) => EventHelper.getUserEvent(event, i.id!)?.photo)
                                    .toList(),
                              ),
                              if(items.length > 3)...[
                                Text(
                                  " + ${items.skip(3).length}",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: AppColors.green_300
                                  ),
                                )
                              ],
                              Icon(
                                size: 25,
                                icon,
                                color: AppColors.green_300
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  })),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}