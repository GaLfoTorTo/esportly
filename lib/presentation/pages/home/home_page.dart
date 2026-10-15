import 'package:flutter/material.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/presentation/widget/cards/card_ads.dart';
import 'package:esportly/presentation/widget/cards/card_level_widget.dart';
import 'package:esportly/presentation/widget/cards/card_presentation_widget.dart';
import 'package:esportly/presentation/widget/showcase/wizard_widget.dart';
import 'package:esportly/presentation/pages/home/secao/section_home_widget.dart';
import 'package:esportly/presentation/pages/home/secao/section_categories_widget.dart';
import 'package:esportly/presentation/controllers/home_controller.dart';
import 'package:esportly/presentation/controllers/showcase_controller.dart';
import 'package:esportly/presentation/controllers/user_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //CONTROLLERS - HOME
  HomeController homeController = HomeController.instance;
  UserController userController = UserController.instance;
  ShowcaseController showcaseController = ShowcaseController.instance;
  //RESGATAR USUARIO LOGADO
  final UserModel user = sl<UserModel>(instanceName: 'user');
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListenableBuilder(listenable: Listenable.merge([homeController, userController, showcaseController]), builder: (_, __){
          //SHOWCASE TUTORIAL (START)
          return WizardWidget(
            elementKey: showcaseController.currentShowcase == 'start' ? 'start' : 'end',
            child: const SizedBox.shrink()
          );
        }),
        //CARD USUARIO
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: AppColors.green_300,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(45), bottomRight: Radius.circular(45)),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark_500.withAlpha(50),
                spreadRadius: 0.5,
                blurRadius: 5,
                offset: const Offset(2, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              CardPresentationWidget(user: user),
            ]
          )
        ),
        //SEÇÃO - CATEGORIAS
        const SectionCategoriesWidget(),
        //SEÇÃO - TASKS
        if(!userController.profileCompleted && user.level != null)...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CardLevelWidget(
              user: user
            ),
          )
        ],
        //SEÇÃO - TAREFAS
        if(user.tasks?.isNotEmpty ?? false)...[
          SectionHomeWidget(
            title: "Tarefas",
            options: user.tasks,
          )
        ],
        //SEÇÃO - EVENTO DO DIA
        if(homeController.events.isNotEmpty)...[
          SectionHomeWidget(
            title: "Minhas Peladas",
            options: homeController.myEvents,
          )
        ],
        //SEÇÃO - ADS/PROPAGANDAS
        if(homeController.ads.isNotEmpty)...[
          const CardAds()
        ],
        //SEÇÃO - PERTO DE VOCE
        if(homeController.toYou.isNotEmpty)...[
          SectionHomeWidget(
            title: "Perto de Você",
            options: homeController.toYou, 
          )
        ],
        //SEÇÃO - POPULARES
        if(homeController.popular.isNotEmpty)...[
          SectionHomeWidget(
            title: "Mais Populares",
            options: homeController.popular, 
          )
        ],
        //SEÇÃO - HOJE
        if(homeController.today.isNotEmpty)...[
          SectionHomeWidget(
            title: "Acontece Hoje",
            options: homeController.today, 
          )
        ],
        //SEÇÃO - SUGESTÃO DE AMIGOS
        if(homeController.popular.isNotEmpty)...[
          SectionHomeWidget(
            title: "Talvez você conheça",
            options: homeController.suggestionFriends, 
          )
        ],
      ]
    );
  }
}