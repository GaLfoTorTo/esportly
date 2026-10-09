import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/core/helpers/event_helper.dart';
import 'package:esportly/core/helpers/map_helper.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

//ESTADO - VISÃO GERAL / SUGESTÕES DE EVENTOS
class EventOverviewState {
  final bool ready;
  final bool error;
  final bool loading;
  final EventModel? event;
  final double? avaliation;
  final LatLng? latLon;
  final UserModel? organizador;
  final String travelMode;
  final double travelDistance;
  final String travelTime;

  const EventOverviewState({
    this.ready = false,
    this.error = false,
    this.loading = false,
    this.event,
    this.avaliation = 0.0,
    this.latLon,
    this.organizador,
    this.travelMode = 'walking',
    this.travelDistance = 0,
    this.travelTime = '',
  });

  EventOverviewState copyWith({
    bool? ready,
    bool? error,
    bool? loading,
    EventModel? event,
    double? avaliation,
    LatLng? latLon,
    UserModel? organizador,
    String? travelMode,
    double? travelDistance,
    String? travelTime,
  }) => EventOverviewState(
    ready: ready ?? this.ready,
    error: error ?? this.error,
    loading: loading ?? this.loading,
    event: event ?? this.event,
    avaliation: avaliation ?? this.avaliation,
    latLon: latLon ?? this.latLon,
    organizador: organizador ?? this.organizador,
    travelMode: travelMode ?? this.travelMode,
    travelDistance: travelDistance ?? this.travelDistance,
    travelTime: travelTime ?? this.travelTime,
  );
}

//NOTIFICADOR - VISÃO GERAL
class EventOverviewNotifier extends Notifier<EventOverviewState> {

  @override
  EventOverviewState build() => const EventOverviewState();

  //FUNÇÃO DE INICIALIZAÇÃO
  void init(EventModel event) {
    try {
      final lat = event.address?.latitude;
      final lon = event.address?.longitude;
      final latLon = (lat != null && lon != null) ? LatLng(lat, lon) : null;
      final (distance, time) = _computeTravel(latLon, 'walking');
      state = state.copyWith(
        event: event,
        avaliation: EventHelper.getAvaliation(event),
        organizador: EventHelper.getUserOrganizator(event),
        latLon: latLon,
        travelDistance: distance,
        travelTime: time,
      );
    } catch (e) {
      state = state.copyWith(event: event, error: true);
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
  }

  //FUNÇÃO DE DEFINIÇÃO DO MODO DE VIAGEM
  void setTravelMode(String mode) {
    final (_, time) = _computeTravel(state.latLon, mode);
    state = state.copyWith(travelMode: mode, travelTime: time);
  }

  //FUNÇÃO DE CALCULO DE VIAGEM
  (double, String) _computeTravel(LatLng? eventLatLon, String mode) {
    if (eventLatLon == null) return (0, '');
    try {
      final userLatLon = sl<ValueNotifier<LatLng?>>(instanceName: 'userLatLog').value;
      if (userLatLon == null) return (0, '');
      final distance = MapHelper.getDistance(userLatLon, eventLatLon);
      final transport = MapHelper.transports.firstWhere((e) => e['type'] == mode);
      final duration = MapHelper.getTravelTime(distance, transport['speed'] as int);
      return (distance, MapHelper.setTimeTravel(duration));
    } catch (_) {
      return (0, '');
    }
  }

}

//PROVIDER - VISÃO GERAL DO EVENTO
final eventOverviewProvider = NotifierProvider<EventOverviewNotifier, EventOverviewState>(EventOverviewNotifier.new);
