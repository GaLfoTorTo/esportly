import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/cards/card_day_event_widget.dart';
import 'package:esportly/presentation/widget/cards/card_event_today_widget.dart';
import 'package:esportly/presentation/widget/cards/card_player_game_widget.dart';
import 'package:esportly/presentation/widget/cards/card_task_widget.dart';
import 'package:esportly/presentation/widget/cards/card_to_you_widget.dart';
import 'package:esportly/presentation/widget/cards/card_popular_widget.dart';
import 'package:esportly/presentation/widget/indicators/indicator_page_widget.dart';

class SectionHomeWidget extends StatefulWidget {
  final dynamic options;
  final String title;

  const SectionHomeWidget({
    super.key,
    required this.options,
    required this.title
  });

  @override
  State<SectionHomeWidget> createState() => _SectionHomeWidgetState();
}

class _SectionHomeWidgetState extends State<SectionHomeWidget> {
  late PageController pageController;
  late BoxConstraints boxConstraints;

  @override
  void initState(){
    super.initState();
    pageController = setPageController();
    boxConstraints = setSectionDimensions();
  }

  @override
  void dispose(){
    super.dispose();
  }

  //FUNÇÃO DE DEFINIÇÃO DE DIMENSOES DA SEÇÃO
  PageController setPageController(){
    switch (widget.title) {
      case "Acontece Hoje":
      case "Tarefas":
        return PageController(viewportFraction: 0.8);
      case "Talvez você conheça":
        return PageController(viewportFraction: 0.45);
      default:
        return PageController();
    }
  }

  //FUNÇÃO DE DEFINIÇÃO DE DIMENSOES DA SEÇÃO
  BoxConstraints setSectionDimensions(){
    switch (widget.title) {
      case "Minhas Peladas":
        return  BoxConstraints(
          maxHeight: 300,
          maxWidth: double.infinity
        );
      case "Perto de Você":
        return  BoxConstraints(
          maxHeight: 500,
          maxWidth: double.infinity
        );
      case "Mais Populares":
        return  BoxConstraints(
          maxHeight: 350,
          maxWidth: double.infinity
        );
      case "Tarefas":
        return  BoxConstraints(
          maxHeight: 120,
          maxWidth: double.infinity
        );
      case "Acontece Hoje":
        return  BoxConstraints(
          maxHeight: 250,
          maxWidth: double.infinity
        );
      case "Talvez você conheça":
        return  BoxConstraints(
          maxHeight: 250,
          maxWidth: double.infinity
        );
      default:
        return  BoxConstraints(
          maxHeight: 300,
          maxWidth: double.infinity
        );
    }
  }
  
  //FUNÇÃO DE DEFINIÇÃO DE CARD DA SEÇÃO
  Widget setCardSection(value){
    switch (widget.title) {
      case "Minhas Peladas":
        return CardDayEventWidget(event: value);  
      case "Tarefas":
        return CardTaskWidget(task: value);  
      case "Perto de Você":
        return CardToYouWidget(event: value);
      case "Mais Populares":
        return CardPopularWidget(event: value);
      case "Acontece Hoje":
        return CardEventTodayWidget(event: value);
      case "Talvez você conheça":
        return CardPlayerGameWidget(user: value);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    //RESGATAR DIMENSOES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;
    
    //FUNÇÃO DE RENDERIZAÇÃO DE SEÇÃO DO HOME PAGE
    Widget sectionHome(){
      //DEFINIR CONTROLLER DA SEÇÃO
      final optionLen = widget.options.length > 5 ? 5 : widget.options.length;
      return Column(
        spacing: 10,
        children: [
          Container(
            constraints: boxConstraints,
            width: dimensions.width,
            child: PageView.builder(
              controller: pageController,
              scrollDirection: Axis.horizontal,
              padEnds: false,
              itemCount: optionLen,
              itemBuilder: (context, index) {
                final value = widget.options[index];
                //DEFINIR CARD
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: setCardSection(value),
                );
              },
            ),
          ),
          IndicatorPageWidget(pageController: pageController, options: optionLen),
        ],
      );
    }

    return Column(
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall
              ),
              if(widget.title != 'Minhas Peladas' )...[
                ButtonTextWidget(
                  text: "Ver Mais",
                  icon: Icons.add_rounded,
                  width: 100,
                  height: 20,
                  textColor: AppColors.green_300,
                  backgroundColor: Colors.transparent,
                  action: () {},
                ) 
              ]
            ]
          ),
        ),
        sectionHome(),
      ],
    );
  }
}