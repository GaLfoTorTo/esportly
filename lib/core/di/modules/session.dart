import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/repositories/event_repository.dart';
import 'package:esportly/data/services/address_service.dart';
import 'package:esportly/data/services/firebase/firebase_service.dart';
import 'package:permission_handler/permission_handler.dart';


//FUNÇÃO DE REGISTRO DO USUARIO NA SESSÃO — chamado após login ou ao recuperar usuário local
Future<void> registerSession(UserModel user) async {
  //RE-REGISTRO: permitir registrar novamente após logout
  if (sl.isRegistered<UserModel>()) sl.unregister<UserModel>();
  sl.registerSingleton<UserModel>(instanceName: 'user', user);
  //REGISTRAR CHAVE DE SCAFFOLD (re-registro seguro após logout)
  if (sl.isRegistered<GlobalKey<ScaffoldState>>(instanceName: 'scaffoldKey')) {
    sl.unregister<GlobalKey<ScaffoldState>>(instanceName: 'scaffoldKey');
  }
  sl.registerSingleton<GlobalKey<ScaffoldState>>(GlobalKey<ScaffoldState>(), instanceName: 'scaffoldKey');
}

//FUNÇÃO DE BUSCA DE EVENTOS DO USUARIO
Future<void> registerEvents(UserModel user) async{
  //BUSCAR EVENTOS DO USUARIO
  List<EventModel>? events = await sl<EventRepository>().getEvents(user: true);
  if(events != null && events.isNotEmpty){
    //SUBSCRIÇÃO DE NOTIFICAÇÕES DO EVENTO
    FirebaseService().subscribe(events);
  }
  //ADICIONAR GLOBALMENT AO GET EVENTOS DO USUARIO
  if (!sl.isRegistered<List<EventModel>>(instanceName: 'events')) {
    sl.registerSingleton<List<EventModel>>(events ?? [], instanceName: 'events');
  }
}

//FUNÇÃO DE REGISTRO DE LOCALIZAÇÃO DO USUÁRIO — chamada após obter permissão e localização
Future<bool> registerLocation() async {
  final permission = await Permission.location.request();

  if (!permission.isGranted) {
    return false;
  }

  final position = await Geolocator.getCurrentPosition();
  final latLng = LatLng(position.latitude, position.longitude);
  final location = await AddressService().getLatLonLocation(latLng);

  // Registra como singletons de sessão — acessíveis em qualquer lugar via sl()
  if (sl.isRegistered<Position>()) {
    sl.unregister<Position>();
  }
  if (sl.isRegistered<ValueNotifier<LatLng?>>(instanceName: 'userLatLog')) {
    sl.unregister<ValueNotifier<LatLng?>>(instanceName: 'userLatLog');
  }
  if (sl.isRegistered<Map<String, dynamic>>(instanceName: 'userLocation')) {
    sl.unregister<Map<String, dynamic>>(instanceName: 'userLocation');
  }

  sl.registerSingleton<Position>(position);
  sl.registerSingleton<ValueNotifier<LatLng?>>(ValueNotifier<LatLng?>(latLng), instanceName: 'userLatLog');
  sl.registerSingleton<Map<String, dynamic>>(location, instanceName: 'userLocation');

  return true;
}
