import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';

class EventPrivatePage extends ConsumerWidget {
  const EventPrivatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var dimensions = MediaQuery.of(context).size;

    return Expanded(
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.white,
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          children: [
            const Divider(),
            Text(
              "Essa pelada é privada!!",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.grey_500,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "As informações de endereço, datas, participantes, modalidade, etc, só podem ser visualizadas por seus participantes.",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.grey_500,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(vertical: 30),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey_300, width: 2),
                borderRadius: BorderRadius.circular(100)
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.grey_300,
                size: 100,
              ),
            ),
            Text(
              "Solicite participação para poder visualizar os dados da pelada.",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.grey_500,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            ButtonTextWidget(
              text: "Participar",
              width: dimensions.width,
              borderRadius: 50,
              shadow: true,
              action: (){}
            )
          ],
        ),
      ),
    );
  }
}
