import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/helpers/loading_overlay.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/presentation/widget/overlays/form_overlay_widget.dart';
import 'package:esportly/presentation/widget/bars/header_widget.dart';
import 'package:esportly/presentation/widget/others/court_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_outline_widget.dart';
import 'package:esportly/presentation/widget/dialogs/dialog_category.dart';
import 'package:esportly/presentation/widget/inputs/select_rounded_widget.dart';
import 'package:esportly/presentation/widget/inputs/silder_players_widget.dart';
import 'package:esportly/presentation/widget/inputs/input_text_widget.dart';
import 'package:esportly/presentation/widget/indicators/indicator_form_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/controllers/navigation_controller.dart';
import 'package:esportly/presentation/controllers/event_controller.dart';

class EventConfigGameStep extends StatefulWidget {  
  const EventConfigGameStep({super.key});

  @override
  State<EventConfigGameStep> createState() => EventConfigGameStepState();
}

class EventConfigGameStepState extends State<EventConfigGameStep> {
  //RESGATAR CONTROLLER DE NAVEGAÇÃO
  NavigationController navigationController = NavigationController.instance;
  //RESGATAR CONTROLLER DE EVENTO
  EventController eventController = EventController.instance;
  //DEFINIR FORMKEY
  final formKey = GlobalKey<FormState>();
  //CONTROLADOR DE VALIDAÇÃO
  bool isValid = true;
  // VARIÁVEL PARA CONTROLAR O STATUS
  final ValueNotifier<int> _overlayStatus = ValueNotifier<int>(0);
  //DEFINIR CATEGORIAS
  List<String> categories = [
    "Futebol",
    "Fut7",
    "Futsal",
  ];
  //DEFINIR VARIAVEIS DE CONTROLLE DE SLIDER
  int qtdPlayers = 11;
  int minPlayers = 9;
  int maxPlayers = 11;
  int divisions = 3;

  //CONTROLADOR DE EXIBIÇÃO DE CAMPOS
  bool hasRefereer = false;
  bool hasGoalLimit = false;
  bool hasExtraTime = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //RESGATAR VALORES DEFINIDOS NAS CONFIGURAÇÕES
    hasRefereer = bool.parse(eventController.hasRefereerController.text);
    hasGoalLimit = bool.parse(eventController.hasGoalLimitController.text);
    hasExtraTime = bool.parse(eventController.hasExtraTimeController.text);
    //EXIBIR DIALOG DE CATEGORIA CASO TENHA SIDO DEFINIDA
    if(eventController.category.isNotEmpty){
      //DEFINIR VARIAVEIS DE CONTROLE DE PARTICIPANTES
      setCategory();
      //EXIBIR DIALOG INFORMATIVO DE CATEGORIA
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(context: context, builder: (_) => const DialogCategory());
      });
    }
  }

  //FUNÇÃO PARA RESGATAR ICONE DA CATEGORIA
  IconData getIconCategory(key){
    switch (key) {
      case "Futebol":
        return AppIcones.foot_futebol_solid;
      case "Fut7":
        return AppIcones.foot_fut7_solid;
      case "Futsal":
        return AppIcones.foot_futsal_solid;
      default:
        return AppIcones.foot_futebol_solid;
    }
  }

  //FUNÇÃO PARA DEFINIR QUANTIDADE DE JOGADOR POR EQUIPE 
  void setCategory(){
    setState(() {
      //RESGATAR CATEGORIA
      final category = eventController.category;
      //RESGATAR VALORES POR CATEGORIA
      final mapPlayers = ModalityHelper.getQtdPlayers(category);
      //ATUALIZAR ESTADOS
      qtdPlayers = mapPlayers['qtdPlayers']!;
      minPlayers = mapPlayers['minPlayers']!;
      maxPlayers = mapPlayers['maxPlayers']!;
      divisions = mapPlayers['divisions']!;
      //ATUALIZAR JOGADORES POR EQUIPE
      setPlayersPerTeam(qtdPlayers);
    });
  }

  void setPlayersPerTeam(int qtd){
    //ATUALIZAR JOGADORES POR EQUIPE
    qtdPlayers = qtd;
    eventController.playersPerTeamController.text = qtdPlayers.toString();
  }
  
  //FUNÇÃO PARA VALIDAR FORMULÁRIO
  void validForm(){
    setState(() {
      //VERIFICAR SE CATEGORIA FOI SELECIONADA
      if(eventController.category.isEmpty){
        isValid = false;
      }
      //VERIFICAR SE QUANTIDADE DE JOGADORES POR EQUIPE FOI SELECIONADA
      if(eventController.playersPerTeamController.text.isEmpty){
        isValid = false;
      }
      //RESGATAR O FORMULÁRIO
      var formData = formKey.currentState;
      //VERIFIAR SE CAMPOS DE TEXTO FORAM PREENCHIDOS
      if(formData?.validate() ?? false){
        isValid = true;
        return;
      }
      isValid = false;
      return;
    });
  }

  //VALIDAÇÃO DA ETAPA
  void submitForm() async{
    //VALIDAR FORMULÁRIO
    validForm();
    //VERIFICAR SE DADOS DA ETAPA FORAM PREENCHIDOS CORRETAMENTE
    if (isValid) {
      //EXIBIR OVERLAY
      await LoadingOverlay.show(
        context,
        () async {
          //ENVAR FORMULARIO
          final response = await eventController.registerEvent();
          //ATUALIZA STATUS COM BASE NA RESPOSTA
          _overlayStatus.value = response['status']!;
          //ESPERAR 5 SEGUNDOS ANTES DE EXECUTAR FUNÇÃO DE CRONOMETRO
          await Future.delayed(const Duration(seconds: 5));
        },
        loadingWidget: Material(
          color: Colors.transparent,
          child: ValueListenableBuilder<int>(valueListenable: _overlayStatus, builder: (_, status, __) => FormOverlayWidget(
            status: status,
            form: "event",
          )),
        ),
        barrierColor: AppColors.dark_700.withAlpha(179),
      );
      //PEQUENO DELAY
      await Future.delayed(const Duration(milliseconds: 100));
      //SE SUCESSO, FECHA O OVERLAY APÓS ANIMAÇÃO
      if (_overlayStatus.value == 200) {
        //NAVEGAR PARA ADICÃO DE PARTICIPANTES
        context.push('/event/register/participants');
      }else{
        //EXIBIR MENSAGEM DE ERRO
        AppHelper.feedbackMessage(context, "Houve um erro ao enviar as informações, tente novamente.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;

    return Scaffold(
      appBar: HeaderWidget(
        title: "Registro", 
        leftAction: () => context.pop(),
        rightAction: () => navigationController.backHome(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              width: dimensions.width,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const IndicatorFormWidget(
                    length: 3,
                    etapa: 2
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Configuração de partidas",
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Agora, Informe suas preferências para as partidas da pelada. Essas informações nos ajudará a melhora a sua experiência no app",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey_500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child:Text(
                      "Categoria",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: categories.map((key){
                        //RESGATAR ICONE DA CATEGORIA
                        IconData icone = getIconCategory(key);
                        return SelectRoundedWidget(
                          value: key,
                          icon: icone,
                          size: 110,
                          iconSize: 40,
                          checked: eventController.category == key,
                          onChanged: (value) {
                            //ATUALIZAR CATEGORIA
                            eventController.category = key;
                            eventController.categoryController.text = key;
                            //DEFINIR QUANTIDADE DE EQUIPES POR TIME 
                            setCategory();
                          }
                        );
                      }).toList()
                    ),
                  ),
                  //VALIDAÇÃO DE CATEGORIA
                  if(!isValid && eventController.category.isEmpty)...[
                    const Padding(
                      padding: EdgeInsets.only(top: 10, left: 8.0),
                      child: Text(
                        'A categoria deve ser informado!',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                  ListenableBuilder(listenable: eventController, builder: (_, __){
                    if(eventController.category.isNotEmpty){
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child:Text(
                              "Quantidade de Jogadores",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Defina quantos jogadores atuaram em campo por cada equipe. Essa informação poderá ser alterada a qualquer momento após o registro.",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey_500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SilderPlayersWidget(
                            qtdPlayers: qtdPlayers.toDouble(),
                            minPlayers: minPlayers.toDouble(),
                            maxPlayers: maxPlayers.toDouble(),
                            divisions: divisions,
                            onChange: (double value){
                              setState(() {
                                //ATUALIZAR QUANTIDADE DE JOGADORES
                                setPlayersPerTeam(value.toInt());
                              });
                            },
                          ),
                          //VALIDAÇÃO DE CATEGORIA
                          if(!isValid && eventController.category.isEmpty)...[
                            const Padding(
                              padding: EdgeInsets.only(top: 10, left: 8.0),
                              child: Text(
                                'A quantidade de jogadores deve ser informado!',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 50),
                            child: CourtWidget(
                              category: eventController.category,
                              players: qtdPlayers,
                            ),
                          ),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: InputTextWidget(
                      name: 'duration',
                      label: bool.parse(eventController.hasTwoHalvesController.text)
                        ? "Duração (min. por tempo)" 
                        : "Duração (min.)",
                      prefixIcon: Icons.timer_outlined,
                      textController: eventController.durationController,
                      type: TextInputType.number,
                      onChanged: (value) => eventController.durationController.text = value,
                      onValidated: (value) => '',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: SwitchListTile(
                      value: bool.parse(eventController.hasTwoHalvesController.text),
                      onChanged: (value){
                        setState(() {
                          //ATUALIZAR VALOR DO SWITCH
                          eventController.hasTwoHalvesController.text = value.toString();
                        });
                      },
                      activeColor: AppColors.green_300,
                      inactiveTrackColor: AppColors.grey_300,
                      inactiveThumbColor: AppColors.grey_500,
                      title: Text(
                        'Dois Tempos',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.dark_300),
                      ),
                      secondary: const Icon(
                        Icons.safety_divider_rounded,
                        color: AppColors.grey_500,
                        size: 30,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: SwitchListTile(
                      value: bool.parse(eventController.hasExtraTimeController.text),
                      onChanged: (value){
                        setState(() {
                          //ATUALIZAR ESTADO DE PRORROGAÇÃO
                          hasExtraTime = value;
                          //ATUALIZAR VALOR 
                          eventController.hasExtraTimeController.text = value.toString();
                        });
                      },
                      activeColor: AppColors.green_300,
                      inactiveTrackColor: AppColors.grey_300,
                      inactiveThumbColor: AppColors.grey_500,
                      title: Text(
                        'Prorrogação',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.dark_300),
                      ),
                      secondary: const Icon(
                        Icons.more_time_rounded,
                        color: AppColors.grey_500,
                        size: 30,
                      ),
                    ),
                  ),
                  if(hasExtraTime)...[
                    InputTextWidget(
                      name: 'extra_time',
                      label: 'Tempo Prorrogação',
                      prefixIcon: Icons.more_time_rounded,
                      textController: eventController.extraTimeController,
                      type: TextInputType.number,
                      onChanged: (value) => eventController.extraTimeController.text = value,
                      onValidated: (value) => '',//hasExtraTime ? eventController.apiClient.validateEmpty(value, 'Tempo Prorrogação') : null,
                    ),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: SwitchListTile(
                      value: bool.parse(eventController.hasPenaltyController.text),
                      onChanged: (value){
                        setState(() {
                          eventController.hasPenaltyController.text = value.toString();
                        });
                      },
                      activeColor: AppColors.green_300,
                      inactiveTrackColor: AppColors.grey_300,
                      inactiveThumbColor: AppColors.grey_500,
                      title: Text(
                        'Pênaltis',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.dark_300),
                      ),
                      secondary: SvgPicture.asset(
                        AppIcones.chuteiras['campo']!,
                        width: 25,
                        colorFilter: const ColorFilter.mode(
                          AppColors.grey_500,
                          BlendMode.srcIn
                        ),
                      )
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: SwitchListTile(
                      value: bool.parse(eventController.hasGoalLimitController.text),
                      onChanged: (value){
                        setState(() {
                          hasGoalLimit = value;
                          eventController.hasGoalLimitController.text = value.toString();
                        });
                      },
                      activeColor: AppColors.green_300,
                      inactiveTrackColor: AppColors.grey_300,
                      inactiveThumbColor: AppColors.grey_500,
                      title: Text(
                        'Limite de Gols',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.dark_300),
                      ),
                      secondary: const Icon(
                        AppIcones.futebol_ball_solid,
                        color: AppColors.grey_500,
                        size: 25,
                      ),
                    ),
                  ),
                  if(hasGoalLimit)...[
                    InputTextWidget(
                      name: 'limitGols',
                      label: 'Qtd. Gols',
                      prefixIcon: AppIcones.futbol_ball_outline,
                      textController: eventController.goalLimitController,
                      type: TextInputType.number,
                      onChanged: (value) => eventController.goalLimitController.text = value,
                      onValidated: (value) => '',//hasGoalLimit ? eventController.apiClient.validateEmpty(value, 'Qtd. Gols') : null,
                    ),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    margin: const EdgeInsets.only(top:20, bottom: 40),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: SwitchListTile(
                      value: bool.parse(eventController.hasRefereerController.text),
                      onChanged: (value) {
                        setState(() {
                          hasRefereer = value;
                          eventController.hasRefereerController.text = value.toString();
                        });
                      },
                      activeColor: AppColors.green_300,
                      inactiveTrackColor: AppColors.grey_300,
                      inactiveThumbColor: AppColors.grey_500,
                      title: Text(
                        'Árbitro',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.dark_300),
                      ),
                      secondary: const Icon(
                        Icons.sports,
                        color: AppColors.grey_500,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ButtonOutlineWidget(
                        text: "Voltar",
                        width: 100,
                        action: () => context.pop(),
                      ),
                      ButtonTextWidget(
                        text: "Salvar",
                        icon: AppIcones.save_solid,
                        width: 100,
                        action: submitForm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}