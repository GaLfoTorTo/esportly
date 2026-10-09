import 'package:esportly/core/api/api_routes.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:esportly/presentation/controllers/map_controller.dart';
import 'package:esportly/presentation/pages/explore/error/erro_permission_page.dart';
import 'package:esportly/presentation/widget/markers/user_marker_widget.dart';
import 'package:esportly/presentation/widget/markers/sport_cluster_widget.dart';
import 'package:esportly/presentation/widget/markers/event_cluster_widget.dart';

class MapWidget extends StatefulWidget {
  final MapWidgetController mapWidgetController;
  const MapWidget({
    super.key, 
    required this.mapWidgetController
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  MapWidgetController get mapWidgetController => widget.mapWidgetController;
  
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapWidgetController.mapController,
      options: MapOptions(
        initialCenter: mapWidgetController.currentLatLog,
        initialZoom: mapWidgetController.currentZoom,
        maxZoom: 18.0,
        minZoom: 12.0,
        onMapEvent: (mapEvent) async{
          //ATUALIZAR ZOOM DE CAMERA E TAMANHO DOS ITENS NO MAPA
          mapWidgetController.currentZoom = mapEvent.camera.zoom;
          mapWidgetController.baseSize = mapWidgetController.calculateBaseSize();
          setState(() {});
        },
        onMapReady: () async{
          //ESPERAR 2 SEGUNDOS
          await Future.delayed(const Duration(seconds: 2));
          //ESTADOS - MAPA E CARREGAMENTO
          mapWidgetController.isMapReady = true;
          //MOVER MAPA PARA POSIÇÃO ATUAL DO USUÁRIO
          mapWidgetController.moveMapCurrentUser(LatLng(
            mapWidgetController.currentPosition.latitude, 
            mapWidgetController.currentPosition.longitude)
          );
        }
      ),
      children: [
        //EXIBIR MENSAGEM E BOTÃO DE SOLICITAÇÃO DE PERMISSÃO PARA GEOLOCALIZAÇÃO
        if(!mapWidgetController.isLoaded && mapWidgetController.isMapReady)...[
          const ErroPermissionPage()
        ]else...[
          TileLayer(
            urlTemplate: ApiRoutes.mapUrl(Theme.of(context).brightness),
          ),
          //POSIÇÃO ATUAL DO USUARIO
          const UserMarkerWidget(),
          //MARKERS (EVENTOS, SPORT PLACE)
          if(mapWidgetController.model == 'Explorer')...[
            //CLUSTERIZAÇÃO DE MARKERS (EVENTOS)
            EventClusterWidget( events: mapWidgetController.events)
          ]else...[
            //CLUSTERIZAÇÃO DE MARKERS (SPORT)
            SportClusterWidget(sportPlaces: mapWidgetController.sportPlaces)
          ]
        ],
      ],
    );
  }
}
