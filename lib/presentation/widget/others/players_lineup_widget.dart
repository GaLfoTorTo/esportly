import 'package:flutter/material.dart';
import 'package:esportly/core/helpers/escalation_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/img_helper.dart';

class PlayersLineupWidget extends StatelessWidget {
  final List<UserModel> players;
  final double? width;
  final double? height;
  final String category;
  final String? command;
  final bool? showPlayerName;
  
  const PlayersLineupWidget({
    super.key,
    required this.players,
    this.command = "Home",
    this.width = 342,
    this.height = 518,
    this.category = "Futebol",
    this.showPlayerName = false,
  });

  double calcSizeAvatar(int qtd) {
    // Mapeia a quantidade para um tamanho fixo baseado em faixas
    if (qtd <= 4) return 60.0;
    if (qtd <= 6) return 55.0;
    if (qtd <= 8) return 52.0;
    if (qtd <= 10) return 50.0;
    return 45.0;
  }

  //FUNÇÃO PARA CALCULAR A POSIÇÃO DOS JOGADORES
  List<Row> _buildPlayers(BuildContext context) {
    //CALCULAR TAMANHO DOS PLAYERS 
    double size = calcSizeAvatar(players.length);
    //DEFINIR FORMAÇÃO
    var formation = EscalationHelper.getFormation(category, players.length);
    //VERIFICAR MANDO DE CAMPO
    if(command == 'Away'){
      formation = formation.reversed.toList();
    }
    final listPlayers = <Row>[];
    int playerIndex = 0;
    formation.every((item){
      listPlayers.add(
        Row(
          mainAxisAlignment: item == 1 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: List.generate(item, (key){
            //RESGATAR JOGADOR
            if (playerIndex >= players.length) return const SizedBox.shrink();
            final player = players[playerIndex++];

            return Column(
              spacing: 5,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: command == "Home" ? AppColors.blue_300 : AppColors.red_300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dark_300.withAlpha(50),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0,5), 
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: ImgHelper.getUserImg(player.photo),
                  ),
                ),
                if(showPlayerName!)...[
                  Container(
                    width: 80,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.dark_300.withAlpha(50),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dark_700.withAlpha(50),
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      UserHelper.getFullName(player),
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: AppColors.white
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ]
              ],
            );
          })
        )
      );
      return true;
    });
    return listPlayers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildPlayers(context),
      ),
    );
  }
}