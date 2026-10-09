import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/map_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/controllers/map_controller.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/images/img_group_circle_widget.dart';
import 'package:esportly/presentation/widget/indicators/indicator_avaliacao_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BottomSheetEventExplore extends ConsumerWidget {
  final List<EventModel> events;
  const BottomSheetEventExplore({
    super.key,
    required this.events
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;
    MapWidgetController mapWidgetController = MapWidgetController.instance;
    PageController pageController = PageController();
    //DEFINIR ALTURA DO DIALOG
    double height = events.length > 1 
      ? dimensions.height * 0.65
      : dimensions.height * 0.6;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              children: events.map((event) {
                //LISTA DE INFORMAÇÕES SOBRE A PELADA
                List<Map<String, dynamic>> infoEvent = [
                  {
                    'label': "Categoria",
                    'icon': AppIcones.escalacao_outline,
                    'value' : event.gameConfig!.category,
                  },
                  {
                    'label': "Participantes",
                    'icon': Icons.people_alt_sharp,
                    'value' : event.participants?.length ?? 0,
                  },
                  {
                    'label': "Partidas",
                    'icon': Icons.sports,
                    'value' : event.games?.length ?? 0,
                  },
                ];
                double avaliation = 12.2;//eventController.eventService.getEventAvaliation(event.avaliations);
                String eventDate = event.date.toString().replaceAll('[', '').replaceAll(']', '').toString();
                final userLatLon = mapWidgetController.currentLatLog;
                final eventLatLon = LatLng(event.address!.latitude!, event.address!.longitude!);
                double distance = MapHelper.getDistance(userLatLon, eventLatLon);
                //RESGATAR MELHOR METODO DE TRANSPORTE BASEADO NA DISTANCIA
                Map<String, dynamic> travelMode = MapHelper.getTravelMode(distance);
                //RESGATAR TEMPO DE VIAGEM ATE O LOCAL
                Duration timeTravelMode = MapHelper.getTravelTime(distance, travelMode['speed']);
                String timeTravel = MapHelper.setTimeTravel(timeTravelMode);
                //RESGATAR FOTOS DOS 3 PRIMEIROS PARTICIPANTES
                List<String?> imgParticipantes = [];
                if(event.participants != null && event.participants!.isNotEmpty){
                  imgParticipantes = event.participants!.take(3).map((user) => user.photo).toList();
                }
                //RESGATAR IMAGEM DO LOCAL
                final addressImg = ImgHelper.getAddressImg(event.address?.photos);
                //RESGATAR ORGANIZADOR
                final hasParticipants = event.participants != null && event.participants!.isNotEmpty;
                final eventOrganizador = hasParticipants
                  ? event.participants!.firstWhere(
                      (user) {
                        final participation = user.participants?.where((p) => p.eventId == event.id);
                        return participation != null && participation.isNotEmpty && (participation.first.roles?.contains("Organizator") ?? false);
                      },
                      orElse: () => event.participants!.first,
                    )
                  : null;
            
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    spacing: 10,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              Container(
                                width: dimensions.width * 0.25,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: ImgHelper.getEventImg(event),
                                    fit: BoxFit.cover
                                  )
                                ),
                              ),
                              SizedBox(
                                width: dimensions.width * 0.65,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 5,
                                  children: [
                                    Text(
                                      event.title!, 
                                      style: Theme.of(context).textTheme.titleSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    if(event.privacy!.name == "Public")...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        spacing: 5,
                                        children: [
                                          const Icon(
                                            AppIcones.calendar_solid,
                                            color: AppColors.grey_300,
                                            size: 20
                                          ),
                                          Text(
                                            eventDate,
                                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                              color: AppColors.grey_500
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ]
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
                                            avaliation: avaliation,
                                            width: 100,
                                            starSize: 15,
                                          ),
                                          Text(
                                            "${avaliation.toStringAsFixed(1)}", 
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
                      const Divider(color: AppColors.grey_300),
                      if(event.privacy!.name == "Public")...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: dimensions.width * 0.6,
                              child: Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 5,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: AppColors.green_300,
                                        size: 20
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${event.address!.street} ${event.address!.suburb}",
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                            color: AppColors.green_300
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${event.address!.borough}, ${event.address!.city}",
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: AppColors.dark_500
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${event.address!.city}/${event.address!.state}",
                                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                      color: AppColors.grey_500
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row( 
                                    spacing: 5,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.green_300.withAlpha(50),
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Icon(
                                          travelMode['icon'],
                                          color: AppColors.green_300,
                                          size: 20,
                                        ),
                                      ),
                                      Text(
                                        "${distance.toStringAsFixed(1)} Km ($timeTravel)",
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: AppColors.grey_500
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            if(addressImg.isNotEmpty)...[
                              Stack(
                                children: [
                                  Container(
                                    width: dimensions.width * 0.3,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey_300,
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: addressImg[0]
                                      )
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Text(
                                      "+${addressImg.length - 1}",
                                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                        color: AppColors.white
                                      ),
                                    )
                                  )
                                ],
                              )
                            ]
                          ],
                        ),
                        if(eventOrganizador != null)...[
                          const Divider(color: AppColors.grey_300),
                          Row(
                            spacing: 10,
                            children: [
                              SizedBox(
                                width: 35,
                                height: 35,
                                child: CircleAvatar(
                                  backgroundImage: ImgHelper.getUserImg(eventOrganizador.photo),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    UserHelper.getFullName(eventOrganizador),
                                    style: Theme.of(context).textTheme.titleSmall,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "Organizador",
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                      color: AppColors.grey_500,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                        const Divider(color: AppColors.grey_300),
                        Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: dimensions.width * 0.7,
                            child: Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: infoEvent.map((item){
                                return Row(
                                  spacing: 5,
                                  children: [
                                    Icon(
                                      item['icon'],
                                      color: AppColors.grey_500,
                                    ),
                                    Text(
                                      "${item['label']}:",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: AppColors.grey_500,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "${item['value']}",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: AppColors.grey_500,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                );
                              }).toList(), 
                            ),
                          ),
                          /* if(user.friends)...[ */
                            SizedBox(
                              width: dimensions.width * 0.2,
                              child: Column(
                                spacing: 5,
                                children: [
                                  ImgGroupCircularWidget(
                                    size: 40, 
                                    images: imgParticipantes
                                  ),
                                  Text(
                                    "+ 3 amigos",
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: AppColors.grey_500,
                                    ),
                                    textAlign: TextAlign.end,
                                  )
                                ],
                              ),
                            )
                          ]
                        /* ], */
                      ),
                      ]else...[
                        Column(
                          spacing: 20,
                          children: [
                            Text(
                              "Essa pelada é privada!!",
                              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                color: AppColors.grey_500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              width: 150,
                              height: 150,
                              padding: const EdgeInsets.all(20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.grey_300, width: 2),
                                borderRadius: BorderRadius.circular(100)
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: AppColors.grey_300,
                                size: 100,
                              ),
                            ),
                            Text(
                              "Suas informações só podem ser visualizadas por seus participantes. Contate o organizador para participar ou para mais informações.",
                              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                color: AppColors.grey_500,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ],
                      const Divider(color: AppColors.grey_300),
                      ButtonTextWidget(
                        width: dimensions.width,
                        height: 30,
                        text: "Ver Pelada",
                        action: () {
                          ref.read(eventSessionProvider.notifier).setEvent(event);
                          Navigator.of(context).pop();
                          context.push('/event/view');
                        },
                      )
                    ],
                  ),
                );
              }).toList()
            ),
          ),
          if(events.length > 1)...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SmoothPageIndicator(
                controller: pageController,
                count: events.length > 3 ? 3 : events.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: AppColors.blue_500,
                  dotColor: AppColors.grey_300,
                  expansionFactor: 2,
                ),
              ),
            ),
          ]
        ],
      )
    );
  }
}