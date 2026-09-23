import 'package:esportly/presentation/widget/skeletons/skeleton_event_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esportly/core/api/api_routes.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/map_helper.dart';
import 'package:esportly/core/helpers/date_helper.dart';
import 'package:esportly/core/helpers/event_helper.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/services/integration_map_service.dart';
import 'package:esportly/core/providers/event/event_overview_provider.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_icon_widget.dart';
import 'package:esportly/presentation/widget/bottomSheet/bottomsheet_map_travel.dart';
import 'package:esportly/presentation/widget/text/expandable_text_widget.dart';

class EventOverviewPage extends ConsumerStatefulWidget {
  const EventOverviewPage({super.key});

  @override
  ConsumerState<EventOverviewPage> createState() => _EventHomePageState();
}

class _EventHomePageState extends ConsumerState<EventOverviewPage> {
  MapController mapController = MapController();
  bool isMapLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //VERIFICAR SE MAPA ESTA PRONTO PARA INICIAR
      setState(() { isMapLoaded = true; });
    });
  }
    
  @override
  Widget build(BuildContext context) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;
    final eventSession = ref.watch(eventOverviewProvider);
    final EventModel event = eventSession.event!;
    final LatLng? latLon = eventSession.latLon;
    final UserModel? organizador = eventSession.organizador;
    final travelMode = ref.watch(eventOverviewProvider.select((s) => s.travelMode));
    final travelDistance = ref.watch(eventOverviewProvider.select((s) => s.travelDistance));
    final travelTime = ref.watch(eventOverviewProvider.select((s) => s.travelTime));
    final String date = DateHelper.getEventDate(event.date!);
    final Color modalityColor = ref.watch(eventSessionProvider.select((s) => s.modalityColor));
    //LISTA DE INFORMAÇÕES SOBRE AS PARTIDAS
    List<Map<String, dynamic>> infoGame = EventHelper.getInfoGameConfig(event);
    
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.dark_700
          : AppColors.white,
        width: dimensions.width,
        child: Builder(builder: (_) {
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: modalityColor,
                          size: 20
                        ),
                        Container(
                          width: dimensions.width - 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "${event.address!.street} ${event.address!.suburb} ${event.address!.city}, ${event.address!.state}",
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ]
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: modalityColor,
                          size: 20
                        ),
                        Container(
                          width: dimensions.width - 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "$date - ${event.startTime!.substring(0,5)} as ${event.endTime!.substring(0,5)}",
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ]
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.new_label_rounded,
                          color: modalityColor,
                          size: 20
                        ),
                        Container(
                          width: dimensions.width - 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Iniciada em: ${DateFormat("dd MMM y").format(event.createdAt!)}",
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ]
                    ),
                  ],
                ),
              ),
              if(event.bio != null)...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ExpandableTextWidget(
                    text: event.bio!
                  ),
                ),
              ],
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            SizedBox(
                              width: 35,
                              height: 35,
                              child: CircleAvatar(
                                backgroundImage: ImgHelper.getUserImg(organizador?.photo)
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${organizador?.firstName ?? ''} ${organizador?.lastName ?? ''}",
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                        Row(
                          spacing: 5,
                          children: [
                            ButtonIconWidget(
                              icon: AppIcones.paper_plane_solid,
                              iconSize: 20,
                              padding: 15,
                              iconColor: modalityColor,
                              backgroundColor: modalityColor.withAlpha(50),
                              action: () {},
                            ),
                            ButtonIconWidget(
                              icon: AppIcones.user_plus_solid,
                              iconSize: 20,
                              padding: 15,
                              iconColor: modalityColor,
                              backgroundColor: modalityColor.withAlpha(50),
                              action: () {},
                            ),
                          ],
                        ),
                      ]
                    ),
                  ],
                ),
              ),
              const Divider(),
              Container(
                width: dimensions.width,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Detalhes',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 20,
                children: [
                  Column(
                    children: [
                      ButtonIconWidget(
                        icon: AppIcones.users_solid,
                        iconSize: 30,
                        padding: 20,
                        iconColor: modalityColor,
                        backgroundColor: modalityColor.withAlpha(50),
                        action: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "${event.participants!.length}",
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: modalityColor,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Participantes",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      ButtonIconWidget(
                        icon: AppIcones.escalacao_solid,
                        iconSize: 30,
                        padding: 20,
                        iconColor: modalityColor,
                        backgroundColor: modalityColor.withAlpha(50),
                        action: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          event.gameConfig!.category,
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: modalityColor,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Categoria",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      ButtonIconWidget(
                        icon: Icons.sports,
                        iconSize: 30,
                        padding: 20,
                        iconColor: modalityColor,
                        backgroundColor: modalityColor.withAlpha(50),
                        action: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "${event.games?.length ?? 0}",
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: modalityColor,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Partidas",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      ButtonIconWidget(
                        icon: AppIcones.lock_solid,
                        iconSize: 30,
                        padding: 20,
                        iconColor: modalityColor,
                        backgroundColor: modalityColor.withAlpha(50),
                        action: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          event.privacy!.name,
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: modalityColor,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Visibilidade",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    //CONTAINER BASE DE DIMENSIONAMENTO
                    SizedBox(
                      width: dimensions.width,
                      height: 400,
                    ), 
                    //AREA DE BOTÕES 
                    Positioned(
                      bottom: -15,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: dimensions.width,
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            ...infoGame.map((item){
                              return SizedBox(
                                width: dimensions.width * 0.25,
                                child: Column(
                                  spacing: 5,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: modalityColor.withAlpha(50),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Icon(
                                        item['icon'],
                                        color: modalityColor,
                                        size: 25,
                                      ),
                                    ),
                                    Text(
                                      item['value'],
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: modalityColor,
                                        fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      item['label'],
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),           
                    // COMPONENTE DE CAMPO
                    Positioned(
                      bottom: 150,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateZ(pi / 2)
                          ..rotateY(0.9),
                        child: Container(
                          width: 200,
                          height: 380,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white, width: 5),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dark_300.withAlpha(50),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(5, 0),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            ModalityHelper.getCategoryCourt(event.gameConfig!.category),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
              const Divider(),
              Container(
                width: dimensions.width,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Localização',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Container(
                width: dimensions.width,
                height: dimensions.height * 0.25,
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                color: AppColors.grey_300,
                child: Builder(builder: (_) {
                  //EXIBIR LOADING DE CARREGAMENTO DO MAPA
                  if (!isMapLoaded || latLon == null) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: modalityColor,
                      )
                    );
                  }
                  return FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: latLon!,
                      initialZoom: 12,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: ApiRoutes.mapUrl(Theme.of(context).brightness),
                        userAgentPackageName: 'com.example.esportly',
                        subdomains: const ['a', 'b', 'c', 'd'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: latLon!,
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.location_on,
                              size: 20,
                              color: modalityColor,
                            )
                          ),
                        ],
                      ),
                    ],
                  );
                })
              ),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey_300),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 60,
                    ),
                    Expanded(
                      child: Column(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${event.address!.street} ${event.address!.suburb}",
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${event.address!.borough}, ${event.address!.city}",
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${event.address!.city}/${event.address!.state}",
                            style: Theme.of(context).textTheme.displayLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 20,
                children: [
                  Column(
                    children: [
                      ButtonIconWidget(
                        icon: MapHelper.transports.firstWhere((e) => e['type'] == travelMode)['icon'],
                        iconSize: 30,
                        padding: 15,
                        iconColor: modalityColor,
                        backgroundColor: modalityColor.withAlpha(50),
                        action: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
                          builder: (_) => const BottomSheetMapTravel()
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Text(
                              "${travelDistance.toStringAsFixed(1)} Km ($travelTime)",
                              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ButtonIconWidget(
                        icon: Icons.directions,
                        iconSize: 30,
                        padding: 15,
                        iconColor: modalityColor,
                        backgroundColor: modalityColor.withAlpha(50),
                        action: () => IntegrationRouteService.openDialogApps(
                          event.address!,
                          travelModel: MapHelper.transports.firstWhere((e) => e['type'] == travelMode)['type']
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Text(
                              "Ver Rotas",
                              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        })
      ),
    );
  }
}