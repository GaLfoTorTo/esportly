import 'dart:async';

import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';

class StopWatchOverlayWidget extends StatefulWidget {
  final int seconds;
  final String? action;
  final String? periodName;
  const StopWatchOverlayWidget({
    super.key,
    this.seconds = 5,
    this.action,
    this.periodName,
  });

  @override
  State<StopWatchOverlayWidget> createState() => _StopWatchOverlayWidgetState();
}

class _StopWatchOverlayWidgetState extends State<StopWatchOverlayWidget> {
  late int remainingSeconds;
  late Timer timer;
  late String description;
  late Color descriptionColor;

  @override
  void initState() {
    super.initState();
    //RESGATAR QUANTIDADE DE SEGUNDO
    remainingSeconds = widget.seconds;
    //VERIFICAR AÇÃO EXECUTADA
    if(widget.action == 'stop'){
      description = "Finalizando partida...";
      descriptionColor = AppColors.red_300;
    }else if(widget.action == 'reset'){
      description = "Parando Partida...";
      descriptionColor = AppColors.grey_300;
    }else if(widget.action == 'next_period'){
      description = widget.periodName != null
          ? 'Encerrando ${widget.periodName}...'
          : 'Encerrando período...';
      descriptionColor = AppColors.red_300;
    }else{
      description = 'Iniciando';
      descriptionColor = AppColors.green_300;
    }
    //CONTAGEM REGRESIVA
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds == 1) {
        t.cancel();
      }
      //ALTERAR TEXTO DE DESCRIÇÃO NO 2 SEGUNDOS PARA AÇÕES DE RESET E STOP
      if(remainingSeconds == 3){
        if(widget.action == 'reset'){
          description =  'Reiniciando...';
        }else if(widget.action == 'stop'){
          description = 'Recolhendo material...';
        }else if(widget.action == 'next_period'){
          description = widget.periodName != null
              ? 'Iniciando ${widget.periodName}...'
              : 'Próximo período...';
        }
      }
      setState(() {
        remainingSeconds--;
      });
    });
  }

  //LIMPAR CONTADORES
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$remainingSeconds',
            style: TextStyle(
              fontSize: 250,
              color: descriptionColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'DS-DIGITAL',
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 30,
              color: descriptionColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'DS-DIGITAL',
            ),
          ),
        ],
      ),
    );
  }
}