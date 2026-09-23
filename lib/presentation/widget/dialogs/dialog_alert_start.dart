import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/presentation/widget/buttons/button_outline_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';

class DialogAlertStart extends StatelessWidget {
  const DialogAlertStart({super.key});

  @override
  Widget build(BuildContext context) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;

    return  Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Equipes não foram definidas!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const Icon(
              Icons.safety_divider_rounded,
              size: 150,
            ),
            Text(
              'As equipes que disputarão esta partida não foram escaladas. A partida só poderá ser iniciado quando os elencos foram definidos.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Column(
              spacing: 10,
              children: [
                ButtonTextWidget(
                  text: "Escalar equipes",
                  width: dimensions.width,
                  icon: Icons.people_rounded,
                  action: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push('/games/teams');
                  }
                ),
                ButtonOutlineWidget(
                  text: "Escalar depois",
                  width: dimensions.width,
                  action: () => Navigator.of(context).pop(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}