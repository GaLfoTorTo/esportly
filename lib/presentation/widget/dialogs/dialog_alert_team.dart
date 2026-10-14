import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';

class DialogAlertTeam extends ConsumerWidget {
  const DialogAlertTeam({
    super.key,
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
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Nº de Jogadores Insuficiente',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              'Parece que o Nº de jogadores presentes não é o suficiente para compor 2 equipes.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Icon(
              Icons.people_rounded,
              size: 200,
            ),
            Text(
              'Para iniciar a partida reduza o Nº de jogadores por equipe nas configurações ou aguarde a chegada de mais jogadores.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            ButtonTextWidget(
              text: "Entendi",
              width: dimensions.width,
              backgroundColor: modalityColor,
              action: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}