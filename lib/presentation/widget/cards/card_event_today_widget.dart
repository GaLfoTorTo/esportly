import 'package:flutter/material.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:intl/intl.dart';

class CardEventTodayWidget extends StatelessWidget {
  final EventModel event;
  const CardEventTodayWidget({
    super.key, 
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    var dimensions = MediaQuery.of(context).size;
    DateTime startTime = DateFormat.Hm().parse(event.startTime!);
    DateTime endTime = DateFormat.Hm().parse(event.endTime!);
    var eventStartTime = DateFormat.Hm().format(startTime);
    var eventEndTime = DateFormat.Hm().format(endTime);
    
    return  Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: dimensions.width * 0.8,
              height: 100,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: ImgHelper.getEventImg(event),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              event.title!,
              style: Theme.of(context).textTheme.titleSmall
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 5,
                      children: [
                        const Icon(
                          Icons.timer,
                          color: AppColors.grey_300,
                        ),
                        Text(
                          "${eventStartTime} - ${eventEndTime}",
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: AppColors.grey_500
                          )
                        ),
                        Text(
                          "Hoje",
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: AppColors.red_300,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ]
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.grey_300,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${event.address?.street}",
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                color: AppColors.grey_500
                              )
                            ),
                            Text(
                              "${event.address?.city}/${event.address?.state}",
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                color: AppColors.grey_300
                              )
                            ),
                          ],
                        ),
                      ]
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}