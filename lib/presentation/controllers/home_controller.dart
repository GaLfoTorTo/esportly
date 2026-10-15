import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/core/di/modules/session.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/data/services/firebase/firebase_service.dart';
import 'package:esportly/core/providers/navigation_provider.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/data/services/home_service.dart';
import 'package:esportly/data/services/user_service.dart';
import 'package:esportly/data/services/address_service.dart';

//===HOME BASE===
abstract class HomeBase {
  //SERVICES
  UserService get userService;
  HomeService get homeService;
  AddressService get addressService;
  List<EventModel> get events;
  //ESTADO - CARREGAMENTO DE DADOS
  bool get isReady;
  bool get isLoading;
  bool get hasError;
  //ESTADOS - CARDS EVENT
  List<Map<String, dynamic>> get ads;
  List<EventModel> get toYou;
  List<EventModel> get nearby;
  List<EventModel> get popular;
  List<EventModel> get myEvents;
  List<EventModel> get today;
  //ESTADOS - USERS
  List<UserModel> get suggestionFriends;
  List<Map<String, dynamic>> get ranking;
  List<Map<String, dynamic>> get partidas;
}

class HomeController extends ChangeNotifier implements HomeBase {
  //CONTROLLERS
  static HomeController get instance => sl<HomeController>();

  //SERVICES
  @override
  UserService userService = UserService();
  @override
  HomeService homeService = HomeService();
  @override
  AddressService addressService = AddressService();

  //DEFINIR EVENTOS DO USUARIO LOGADO - OBRIGATÓRIO
  @override
  late List<EventModel> events;

  //ESTADOS - CARREGAMENTO DE DADOS
  bool _isReady = false;
  @override
  bool get isReady => _isReady;
  set isReady(bool v) { _isReady = v; notifyListeners(); }

  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;
  set isLoading(bool v) { _isLoading = v; notifyListeners(); }

  bool _hasError = false;
  @override
  bool get hasError => _hasError;
  set hasError(bool v) { _hasError = v; notifyListeners(); }

  //ESTADOS - HOME
  @override
  final List<Map<String, dynamic>> ads = [];
  @override
  final List<EventModel> toYou = [];
  @override
  final List<EventModel> nearby = [];
  @override
  final List<EventModel> popular = [];
  @override
  final List<EventModel> myEvents = [];
  @override
  final List<EventModel> today = [];
  @override
  final List<UserModel> suggestionFriends = [];
  @override
  final List<Map<String, dynamic>> ranking = [];
  @override
  final List<Map<String, dynamic>> partidas = [];

  //FUNÇÃO DE RESET — deve ser chamada no logout para limpar dados da sessão anterior
  void reset() {
    _isReady = false;
    _isLoading = false;
    _hasError = false;
    ads.clear();
    toYou.clear();
    nearby.clear();
    popular.clear();
    myEvents.clear();
    today.clear();
    suggestionFriends.clear();
    ranking.clear();
    partidas.clear();
    notifyListeners();
  }

  //FUNÇÃO DE INICIALIZAÇÃO DE CONTROLLER
  Future<void> init() async {
    //BUSCAR EVENTOS DO USUARIO
    events = sl<List<EventModel>>(instanceName: 'events');
  }

  //FUNÇÃO PARA BUSCA INFORMAÇÕES DA HOME PAGE
  Future<void> fetchHome() async {
    isLoading = true;
    //EXECUTAR BUSCA DE DADOS PARA HOME PAGE
    try {
      await requestPermissions();
      //PREENCHER LISTAS COM OS DADOS RESGATADOS
      final resp = await homeService.fetchHome();
      //SEPARA DADOS
      handleRequest(resp);
      //ATUALIZAR ESTADO DE CARREGAMENTO
      isLoading = false;
      isReady = true;
      sl<ProviderContainer>().read(navReadyProvider.notifier).state = true;
    } catch (e, stackTrace) {
      hasError = true;
      isLoading = false;
      debugPrint('fetchHome error: $e\n$stackTrace');
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) {
        AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
      }
    }
  }

  //FUNÇÃO PARA SEPARAR DADOS RESGATADOS DA API
  void handleRequest(resp) {
    //LIMPAR LISTAS ANTES DE PREENCHER
    ads.clear();
    myEvents.clear();
    toYou.clear();
    popular.clear();
    today.clear();
    suggestionFriends.clear();
    ranking.clear();
    partidas.clear();

    //PREENCHER LISTAS COM OS DADOS RESGATADOS
    ads.addAll(resp['ads']                   as List<Map<String, dynamic>>? ?? []);
    toYou.addAll(resp['toYou']               as List<EventModel>? ?? []);
    nearby.addAll(resp['nearby']             as List<EventModel>? ?? []);
    popular.addAll(resp['popular']           as List<EventModel>? ?? []);
    today.addAll(resp['today']               as List<EventModel>? ?? []);
    ranking.addAll(resp['ranking']           as List<Map<String, dynamic>>? ?? []);
    partidas.addAll(resp['partidas']         as List<Map<String, dynamic>>? ?? []);
    suggestionFriends.addAll(resp['friends'] as List<UserModel>? ?? []);

    //PREENCHER LIVE COM EVENTOS DO USUARIO QUE ACONTECEM HOJE
    const weekdayAbbr = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    final todayAbbr = weekdayAbbr[DateTime.now().weekday];
    myEvents.addAll(events.where((e) {
      final date = e.date;
      if (date == null || date.isEmpty) return false;
      return date.length == 7 || date.contains(todayAbbr);
    }));

    notifyListeners();
  }

  //FUNÇÃO DE REQUISIÇÃO DE PERMISSÕES
  Future<void> requestPermissions() async {
    await registerLocation();
    await FirebaseService().initFirebaseMessaging();
  }
}
