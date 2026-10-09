import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';

class CardMvpWidget extends StatelessWidget {
  final EventModel event;
  const CardMvpWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;
    //ESTADO - ITEMS EVENTO
    Color modalityColor = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality?.name ?? 'Football')['color'];
    //Color modalityTextColor = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality?.name ?? 'Football')['textColor'];
    String modalityImage = ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality?.name ?? 'Football')['image'];
    UserModel player = event.participants!.first;
    //DEFINIR ESTATISTICAS
    Map<String, dynamic> stats = {
      'Gols': {
        'value': 12,
        'icon' : Icons.sports_soccer_rounded
      },
      'Assistencias': {
        'value': 7,
        'icon' : Icons.handshake_rounded
      },
    };
    
    return Card(
      child: Container(
        width: dimensions.width - 10,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: modalityColor,
          image: DecorationImage(
            image: AssetImage(modalityImage) as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              modalityColor.withAlpha(200), 
              BlendMode.srcATop,
            )
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark_500.withAlpha(50),
              spreadRadius: 0.5,
              blurRadius: 5,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        child: Row(
          spacing: 40,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 20,
              children: [
                Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "MVP ",
                        style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: AppColors.blue_500,
                          fontSize: 35,
                        ),
                        children: [
                          TextSpan(
                            text: "do dia",
                            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                              color: AppColors.blue_500,
                              fontSize: 30,
                            ),
                          ),
                        ]
                      ),
                    ),
                    Text(
                      "Melhor atuação no dia",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.blue_500,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 20,
                  children: [
                    ...stats.entries.map((item){
                      return Column(
                        children: [
                          Icon(
                            item.value['icon'],
                            size: 40,
                            color: AppColors.blue_500,
                          ),
                          Text(
                            "${item.value['value']}",
                            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                              color: AppColors.blue_500,
                            ),
                          )
                        ],
                      );
                    }).toList() 
                  ],
                )
              ],
            ),
            SizedBox(
              width: 120,
              height: 120,
              child: CircleAvatar(
                backgroundImage: ImgHelper.getUserImg(player.photo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}