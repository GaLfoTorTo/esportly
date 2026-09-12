import 'package:esportly/data/models/rule_model.dart';
import 'package:esportly/data/repositories/event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/data/models/event_model.dart';

//ESTADO - PARTICIPANTES DO EVENTO
class EventRulesState {
  final bool ready;
  final bool error;
  final bool loading;
  final EventModel? event;
  final List<RuleModel>? rules;

  const EventRulesState({
    this.ready = false,
    this.error = false,
    this.loading = false,
    this.event,
    this.rules = const [],
  });

  EventRulesState copyWith({
    bool? ready,
    bool? error,
    bool? loading,
    EventModel? event,
    List<RuleModel>? rules,
  }) => EventRulesState(
    ready: ready ?? this.ready,
    error: error ?? this.error,
    loading: loading ?? this.loading,
    event: event ?? this.event,
    rules: rules ?? this.rules,
  );
}

//NOTIFICADOR - PARTICIPANTES DO EVENTO
class EventRulesNotifier extends Notifier<EventRulesState> {
  EventRepository get _eventRepository => EventRepository();

  @override
  EventRulesState build() => const EventRulesState();

  //FUNÇÃO DE INICIALIZAÇÃO
  void init(EventModel event){ 
    state = state.copyWith(
      event: event,
    );
  }

  //FUNÇÃO DE DEFINIÇÃO DE RANKING
  Future<void> getRules(String type) async{
    final rules = await _eventRepository.getRulesEvent(state.event!.uuid!);
    state = state.copyWith(rules: rules);
  }
}

//PROVIDER - PARTICIPANTES DO EVENTO
final eventRulesProvider = NotifierProvider<EventRulesNotifier, EventRulesState>(EventRulesNotifier.new);
