import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_icon_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';

class EventPrivatePage extends ConsumerWidget {
  const EventPrivatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var dimensions = MediaQuery.of(context).size;
    //BUSCAR EVENTO
    final eventSession = ref.read(eventSessionProvider);
    EventModel event = eventSession.event!;
    final UserModel eventOrganizador = event.participants![0];

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
              "As informações de endereço, datas, participantes, etc, só podem ser visualizadas por seus participantes.",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.grey_500,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(20),
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
              "Contate o organizador ou solicite acesso para se tornar um participante.",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.grey_500,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    SizedBox(
                      width: 35,
                      height: 35,
                      child: CircleAvatar(
                        backgroundImage: ImgHelper.getUserImg(eventOrganizador.photo)
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UserHelper.getFullName(eventOrganizador),
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "Organizador",
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: AppColors.grey_500,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    ButtonIconWidget(
                      icon: AppIcones.paper_plane_solid,
                      iconSize: 20,
                      padding: 15,
                      iconColor: AppColors.green_300,
                      backgroundColor: AppColors.green_300.withAlpha(50),
                      action: () {},
                    ),
                    ButtonIconWidget(
                      icon: AppIcones.user_plus_solid,
                      iconSize: 20,
                      padding: 15,
                      iconColor: AppColors.green_300,
                      backgroundColor: AppColors.green_300.withAlpha(50),
                      action: () {},
                    ),
                  ],
                ),
              ]
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
