import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/helpers/loading_overlay.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/indicators/indicator_loading_widget.dart';

class DialogRandomTeam extends ConsumerWidget {
  final Future<void> Function() actionRandom;
  final Future<void> Function() actionOrder;
  const DialogRandomTeam({
    super.key,
    required this.actionRandom,
    required this.actionOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;
    final modalityColor = ref.read(eventSessionProvider).modalityColor;

    return  Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Definição de times da partida',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const Icon(
              Icons.safety_divider_rounded,
              size: 200,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Escolha a forma como você deseja definir as equipes que disputaram a partida. Sorteio entre os jogadores confirmados ou a escolha manual as equipes.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Column(
              spacing: 10,
              children: [
                ButtonTextWidget(
                  text: "Sorteio",
                  width: dimensions.width,
                  icon: Icons.repeat_rounded,
                  iconSize: 30,
                  backgroundColor: modalityColor,
                  action: () async {
                    //EXECUTAR FUNÇÃO RANDOMICA E EXIBIR OVERLAY
                    await LoadingOverlay.show(
                      context,
                      actionRandom,
                      loadingWidget: const Center(child: IndicatorLoadingWidget()),
                      barrierColor: AppColors.dark_700.withAlpha(178),
                    );
                    //FECHAR DIALOG
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
                ButtonTextWidget(
                  text: "Ordem",
                  width: dimensions.width,
                  icon: Icons.format_list_numbered_rounded,
                  iconSize: 30,
                  backgroundColor: modalityColor,
                  action: () async {
                    //EXECUTAR FUNÇÃO RANDOMICA E EXIBIR OVERLAY
                    await LoadingOverlay.show(
                      context,
                      actionRandom,
                      loadingWidget: const Center(child: IndicatorLoadingWidget()),
                      barrierColor: AppColors.dark_700.withAlpha(178),
                    );
                    //FECHAR DIALOG
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}