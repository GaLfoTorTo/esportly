import 'package:flutter/foundation.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/data/repositories/event_repository.dart';
import 'package:esportly/data/repositories/user_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController();

  //DEFINIR CONTROLLER UNICO NO GETIT
  static ProfileController get instance => sl<ProfileController>();
  //INSTANCIAR SERVIÇO DE ENDEREÇOS
  UserRepository userRepository = UserRepository();
  EventRepository eventRepository = EventRepository();

  //ESTADOS - READY E PERMISSOES
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  set isLoaded(bool v) { _isLoaded = v; notifyListeners(); }

  bool _isReady = false;
  bool get isReady => _isReady;
  set isReady(bool v) { _isReady = v; notifyListeners(); }

  bool _hasError = false;
  bool get hasError => _hasError;
  set hasError(bool v) { _hasError = v; notifyListeners(); }

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;
  set hasPermission(bool v) { _hasPermission = v; notifyListeners(); }

  //ESTADOS - POSIÇÃO, ZOOM E CARREGAMENTO DO MAPA
  late UserModel user;
  List<EventModel> events = [];

  Future<void> getProfile(id) async {
    Future.delayed(const Duration(milliseconds: 1000));
    await getUser(id);
    await getUserEvents();
    isLoaded = true;
  }

  //FUNÇÃO PARA BUSCAR DADOS DO USUARIO
  Future<void> getUser(id) async {
    Future.delayed(const Duration(milliseconds: 1000));
    user = await userRepository.getUser(id);
  }

  //FUNÇÃO DE BUSCA DE EVENTOS DO USUARIO
  Future<void> getUserEvents() async {
    //BUSCAR EVENTOS DO USUARIO
    //events.addAll(await eventRepository.getUserEvents(user.id));
  }
}
