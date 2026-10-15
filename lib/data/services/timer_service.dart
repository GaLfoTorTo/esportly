import 'dart:async';
import 'package:esportly/core/di/service_locator.dart';

/// SERVIÇO PARA GERENCIAMENTO DE CRONOMETROS DE PARTIDAS (CADA PARTIDA COM SEU CRONOMETRO INDIVIDUAL)
class TimerService {
  //GETTER DE SERVIÇO DE TIMER
  static TimerService get instance => sl<TimerService>();
  //MAPA DE ARMAZENAMENTO DE CRONOEMTROS POR PARTIDA
  final Map<int, _GameStopwatch> _gameTimers = {};

  //STREAM DE CRONOMETRO DA PARTIDA (CRONOMETRO)
  Stream<String> clockStream(int gameId) => _gameTimers[gameId]?._timeController.stream ?? Stream.value('00:00');

  //STREAM DE CRONOMETRO DA PARTIDA (CONTADOR DE MINUTOS RESTANTES)
  Stream<int> elapsedStream(int gameId) => _gameTimers[gameId]?._elapsedMinutesController.stream ?? Stream.value(0);

  //STREAM DE CRONOMETRO DA PARTIDA (CONTADOR DE MINUTOS PASSADOS)
  Stream<int> remainingStream(int gameId) => _gameTimers[gameId]?._remainingMinutesController.stream ?? Stream.value(0);


  //FUNÇÃO PARA INICIO OU RETOMADA DE CRONOMETRO DA PARTIDA 
  /// [gameId]: IDENTIFICADOR DA PARTIDA
  /// [duration]: DURAÇÃO DA PARTIDA
  void startStopwatch(int gameId, Duration? duration) {
    //CRIA NOVO CRONOMETRO CASO NÃO EXISTA
    _gameTimers[gameId] ??= _GameStopwatch();
    //INICIA CRONOMETRO DA PARTIDA
    _gameTimers[gameId]!.startStopwatch(duration); 
  }

  //FUNÇÃO PARA PAUSAR CRONOMETRO DA PARTIDA
  /// [gameId]: IDENTIFICADOR DA PARTIDA
  void pauseStopwatch(int gameId) {
    _gameTimers[gameId]?.pauseStopwatch();
  }

  //FUNÇÃO PARA PARAR COMPLETAMENTE CRONOMETRO DA PARTIDA
  /// [gameId]: IDENTIFICADOR DA PARTIDA
  void stopStopwatch(int gameId) {
    _gameTimers[gameId]?.stopStopwatch();
  }

  //FUNÇÃO PARA RESETAR CRONOMETRO DA PARTIDA
  /// [gameId]: IDENTIFICADOR DA PARTIDA
  void resetStopwatch(int gameId) {
    _gameTimers[gameId]?.resetStopwatch();
  }

  //FUNÇÃO PARA VERIFICAR SE CRONOMETRO ESTA RODANDO (PARTIDA EM ANDAMENTO)
  /// [gameId]: IDENTIFICADOR DA PARTIDA
  bool isRunning(int gameId) => _gameTimers[gameId]?.isRunning ?? false;

  void dispose() {
    //ENCERRAR TODOS OS TIMERS E CRONOMETROS ABERTOS QUANDO O SERVIÇO FOR DESTRUÍDO
    for (var timer in _gameTimers.values) {
      timer.dispose();
    }
  }
}

//CLASSE INTERNAR DE GERENCIAMNETO DE CRONOMETROS INDIVIDUAIS
class _GameStopwatch {
  //INSTANCIAR CRONOMETRO
  final Stopwatch _stopwatch = Stopwatch();
  //DEFINIR STREMS DE TEMPO DE PARTIDA FORMATADOS, MINUTOS RESTANTES, MINUTOS DECORRIDOS
  final StreamController<String> _timeController = StreamController.broadcast();
  final StreamController<int> _remainingMinutesController = StreamController.broadcast();
  final StreamController<int> _elapsedMinutesController = StreamController.broadcast();
  
  //DEFINIR ESTADOS DE CRONOMETRO, MINUTOS DECORRIDOS, MINUTOS FALTANTES
  Timer? _stopwatchTimer;
  Timer? _minuteTimer;
  Timer? _secondTimer; 
  //DEFINIR ESTADOS DE INICIO E FIM DA PARTIDA
  DateTime? _matchStartTime;
  DateTime? _matchEndTime;

  //GETTER DE INDICAÇÃO DE CRONOMETRO EM ANDAMENTO
  bool get isRunning => _stopwatch.isRunning;

  //GETTERS DE TEMPO DECORRIDO FORMATADO (mm:ss)
  String get currentTime {
    final duration = Duration(milliseconds: _stopwatch.elapsedMilliseconds);
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  //FUNÇÃO PARA INICIAR OU RETOMAR CRONOMETRO
  /// [duration]: DURAÇÃO DA PARTIDA
  void startStopwatch(Duration? duration) {
    //VERIFICAR SE CRONOMETRO JA FOI INICIADO
    if (_stopwatch.isRunning) return;

    //VERIFICAR SE CRONOMETRO JÁ FOI INICIADO
    if (_stopwatch.elapsedMilliseconds == 0) {
      //REDEFINIR HORARIO DE INICIO E FIM DA PARTIDA (INICIO: HORARIO ATUAL, FIM: HORARIO ATUAL MAIS DURAÇÃO DEFINIDA)
      _matchStartTime = DateTime.now();
      _matchEndTime = _matchStartTime!.add(duration!);
    } else {
      //RESGATAR MINUTOS DECORRIDOS
      final timePassed = _stopwatch.elapsed;
      //REDEFINIR HORARIO DE INICIO E FIM DA PARTIDA (CALCULAR DIFERENCA DE FIM DA PARTIDA COM INICIO DA PARTIDA - MINUTOS DECORRIDOS)
      _matchEndTime = DateTime.now().add(
        _matchEndTime!.difference(_matchStartTime!) - timePassed
      );
      _matchStartTime = DateTime.now().subtract(timePassed);
    }
    //INICIAR CRONOMETRO E TIMERS
    _stopwatch.start();
    _startTimers();
    //NOTIFICAR LISTENERS COM VALORES DEFINIDO
    _emitState();
  }

  //FUNÇÃO DE PAUSA DE CRONOMETROS
  void pauseStopwatch() {
    //VERIFICAR SE CRONOMETRO ESTA RODANDO
    if (_stopwatch.isRunning) {
      //PARAR CRONOMETRO E TIMER
      _stopwatch.stop();
      _stopTimers();
      _emitState();
    }
  }

  //FUNÇÃO PARA PARAR COMPLETAMENTE O CRONOMETRO
  void stopStopwatch() {
    _stopwatch.stop();
    _stopTimers();
  }

  //FUNÇÃO PARA RESETAR CRONOMETRO
  void resetStopwatch() {
    _stopwatch.stop();
    _stopwatch.reset();
    _stopTimers();
    _emitState();
  }

  //FUNÇÃO PARA INICIAR TIMERS
  void _startTimers() {
    //TIMER PRINCIPAL (ATUALIZAR A CADA 30 ms)
    _stopwatchTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      _timeController.add(currentTime);
      if (_stopwatch.elapsed.inSeconds % 60 == 0) {
        _elapsedMinutesController.add(_stopwatch.elapsed.inMinutes);
      }
    });

    //TIMER PARA MINUTOS RESTANTES (ATUALIZAR A CADA 1 m)
    _minuteTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _remainingMinutesController.add(_getRemainingMinutes());
    });

    //TIMER PARA CONTAGEM REGRESSIVAA (ATUALIZA A CADA SEGUNDO)
    _secondTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      //RESGATAR MINUTOS DECORRIDOS
      final remaining = _getRemainingMinutes();
      //VERIFICAR SE TEMPO LIMITE DA PARTIDA FOI ALCANÇADO
      if (remaining <= 0) timer.cancel(); 
      //VERIFICAR SE TEMPO LIMITE DA PARTIDA AINDA NÃO FOI ALCANÇADO
      if (_matchEndTime!.difference(DateTime.now()).inSeconds % 60 == 0) {
        _remainingMinutesController.add(remaining);
      }
    });
  }

  //FUNÇÃO PARA PARAR TIMER TODOS OS TIMERS
  void _stopTimers() {
    _stopwatchTimer?.cancel();
    _minuteTimer?.cancel();
    _secondTimer?.cancel();
  }

  //FUNÇÃO PARA NOTIFICAR LISTENERS
  void _emitState() {
    _timeController.add(currentTime);
    _elapsedMinutesController.add(_stopwatch.elapsed.inMinutes);
    _remainingMinutesController.add(_getRemainingMinutes());
  }

  //FUNÇÃO PARA CALCULAR MINUTOS RESTANTES PARA FIM DA PARTIDA
  int _getRemainingMinutes() {
    //RESGATAR DATA ATUAL
    final now = DateTime.now();
    //VERIFCIAR DIFERENÇA DE HORARIO DE INICIO E FIM DA PARTIDA (RETORNA A DIFERENÇA EM m)
    if (now.isBefore(_matchStartTime!)) {
      return _matchEndTime!.difference(_matchStartTime!).inMinutes;
    } else if (now.isAfter(_matchEndTime!)) {
      return 0;
    } else {
      return _matchEndTime!.difference(now).inMinutes;
    }
  }

  //FUNÇÃO PARA LIMPAR E FECHAR TODOS OS STREAMS E STADOS
  void dispose() {
    _stopTimers();
    _timeController.close();
    _remainingMinutesController.close();
    _elapsedMinutesController.close();
  }
}