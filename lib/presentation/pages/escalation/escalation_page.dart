import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/providers/escalation/escalation_session_provider.dart';
import 'package:esportly/core/providers/escalation/escalation_team_provider.dart';
import 'package:esportly/presentation/controllers/showcase_controller.dart';
import 'package:esportly/presentation/widget/showcase/wizard_widget.dart';
import 'package:esportly/presentation/widget/buttons/float_button_escalation_widget.dart';
import 'package:esportly/presentation/widget/bars/header_widget.dart';
import 'package:esportly/presentation/widget/text/price_indicator_widget.dart';
import 'package:esportly/presentation/widget/lists/escalation_list_widget.dart';
import 'package:esportly/presentation/widget/others/escalation_widget.dart';
import 'package:esportly/presentation/widget/others/reserve_bank_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_icon_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_formation_widget.dart';

class EscalationPage extends ConsumerStatefulWidget {
  const EscalationPage({super.key});

  @override
  ConsumerState<EscalationPage> createState() => EscalationPageState();
}

class EscalationPageState extends ConsumerState<EscalationPage> {
  ShowcaseController showcaseController = ShowcaseController.instance;
  String viewType = 'escalation';
  bool showCap = false;

  @override
  void initState() {
    super.initState();
    showcaseController.addListener(_onShowcaseUpdate);
  }

  @override
  void dispose() {
    showcaseController.removeListener(_onShowcaseUpdate);
    super.dispose();
  }

  //FUNÇÃO DE EXIBIÇÃO DE PAGINA NO SHOWCASE
  void _onShowcaseUpdate() => setState(() {});

  //FUNÇÃO DE SELEÇÃO DE EVENTO
  void selectEvent(id) => ref.read(escalationSessionProvider.notifier).setEvent(id);

  //FUNÇÃO DE SELEÇÃO DE VISUALIZAÇÃO
  void selectView(type) => setState(() => viewType = type);

  //FUNÇÃO DE SELEÇÃO DE FORMAÇÃO DA EQUIPE
  void selectFormation(newValue) => ref.read(escalationSessionProvider.notifier).setFormation(newValue);

  @override
  Widget build(BuildContext context) {
    //RESGATAR INICIALIZAÇÃO DE PROVIDER DE ESCALAÇÃO
    final managerSession = ref.watch(escalationSessionProvider);
    final teamSession = ref.watch(escalationTeamProvider);
    final event = managerSession.event;
    final price = managerSession.price;
    final economy = managerSession.economy;
    final valuation = managerSession.valuation;
    final category = managerSession.category;
    final formation = managerSession.formation;
    final String modalityImage = ModalityHelper.getEventModalityColor(event!.gameConfig?.category ?? event.modality?.name ?? 'Football')['image'];
    //ESTADOS - ESTILIZAÇÃO
    final dimensions = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.dark_300 : AppColors.white;

    return Scaffold(
      appBar: HeaderWidget(
        title: 'Escalação',
        leftAction: () => context.pop(),
        rightAction: () => context.push('/escalation/market'),
        rightIcon: Icons.shopping_cart,
        extraAction: () => context.push('/escalation/historic'),
        extraIcon: Icons.history,
        shadow: false,
      ),
      body: SafeArea(
        child:SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              Container(
                width: dimensions.width,
                height: 70,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dark_500 : AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dark_500.withAlpha(30),
                      spreadRadius: 0.5,
                      blurRadius: 7,
                      offset: const Offset(2, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: dimensions.width * 0.25,
                      child: Row(
                        spacing: 10,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              image: DecorationImage(
                                image: event.photo == null
                                    ? AssetImage(modalityImage) as ImageProvider
                                    : ImgHelper.getEventImg(event),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              event.title!,
                              style: Theme.of(context).textTheme.displayMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: dimensions.width * 0.22,
                      child: PriceIndicatorWidget(
                        title: 'Preço da Equipe',
                        value: '$price',
                      ),
                    ),
                    SizedBox(
                      width: dimensions.width * 0.22,
                      child: Row(
                        children: [
                          PriceIndicatorWidget(
                            value: '$economy',
                            title: 'FutCoins',
                          ),
                          if (valuation != 0.0) ...[
                            Icon(
                              AppHelper.setColorPontuation(valuation)['icon'],
                              size: 20,
                              color: AppHelper.setColorPontuation(valuation)['color'],
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                )
              ),
              Container(
                width: dimensions.width,
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    SizedBox(
                      width: (dimensions.width / 2) - 10,
                      child: ButtonFormationWidget(
                        selectedFormation: formation,
                        formations: managerSession.formations,
                        onChange: selectFormation,
                      ),
                    ),
                    SizedBox(
                      width: (dimensions.width / 2) - 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 10,
                        children: [
                          WizardWidget(
                            elementKey: 'escalation',
                            child: ButtonIconWidget(
                              padding: 20,
                              iconSize: 20,
                              icon: AppIcones.escalacao_outline,
                              iconColor: viewType == 'escalation'
                                  ? AppColors.blue_500
                                  : AppColors.grey_500,
                              backgroundColor:
                                  viewType == 'escalation' ? AppColors.green_300 : color,
                              action: () => selectView('escalation'),
                            ),
                          ),
                          ButtonIconWidget(
                            padding: 20,
                            iconSize: 20,
                            icon: AppIcones.clipboard_outline,
                            iconColor: viewType == 'list' ? AppColors.blue_500 : AppColors.grey_500,
                            backgroundColor: viewType == 'list' ? AppColors.green_300 : color,
                            action: () => selectView('list'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (viewType == 'escalation') ...[
                EscalationWidget(
                  width: dimensions.width - 80,
                  height: (dimensions.height / 2) + 50,
                  category: category,
                  formation: formation,
                ),
                const SizedBox(height: 50),
                const Text('Reservas',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ReserveBankWidget(
                  category: category,
                  players: teamSession.reserves,
                ),
              ] else ...[
                EscalationListWidget(
                  title: 'Titulares', 
                  occupation: 'starters',
                  category: category,
                  formation: formation,
                  players: teamSession.starters,
                ),
                const SizedBox(height: 20),
                EscalationListWidget(
                  title: 'Reservas', 
                  occupation: 'reserves',
                  category: category,
                  formation: formation,
                  players: teamSession.reserves,
                ),
              ],
            ],
          ),
        )
      ),
      floatingActionButton: const FloatButtonEscalationWidget(),
    );
  }
}
