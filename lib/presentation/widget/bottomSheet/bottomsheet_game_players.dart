import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/presentation/widget/images/img_circle_widget.dart';
import 'package:esportly/presentation/widget/cards/card_player_team_widget.dart';

class BottomSheetGamePlayers extends ConsumerStatefulWidget {
  final int team;
  final int qtdPlayers;
  const BottomSheetGamePlayers({
    super.key,
    required this.team,
    required this.qtdPlayers,
  });

  @override
  ConsumerState<BottomSheetGamePlayers> createState() => _BottomSheetGamePlayersState();
}

class _BottomSheetGamePlayersState extends ConsumerState<BottomSheetGamePlayers> {
  late List<UserModel> participants;
  List<UserModel> selectedPlayers = [];

  @override
  void initState() {
    super.initState();
    final session = ref.read(gameSessionProvider);
    final match = ref.read(gameMatchProvider);
    final allParticipants = session.event?.participants ?? [];
    selectedPlayers = List<UserModel>.from(
      widget.team == 0 ? match.teamA.players : match.teamB.players,
    );
    participants = allParticipants
      .where((p) => !match.teamA.players.contains(p) && !match.teamB.players.contains(p))
      .toList();
  }

  void setPlayerTeam(UserModel participant, String action) {
    if (action == 'add') {
      if (selectedPlayers.length < widget.qtdPlayers) {
        if (!selectedPlayers.contains(participant)) {
          setState(() {
            selectedPlayers.add(participant);
            participants.remove(participant);
          });
          ref.read(gameMatchProvider.notifier).setPlayersTeam(widget.team, List.from(selectedPlayers));
        }
      } else {
        Navigator.of(context).pop();
        AppHelper.feedbackMessage(context, "A equipe ja atingiu o número de jogadores!", type: "danger");
      }
    } else {
      if (selectedPlayers.contains(participant)) {
        setState(() {
          selectedPlayers.remove(participant);
          participants.insert(0, participant);
        });
        ref.read(gameMatchProvider.notifier).setPlayersTeam(widget.team, List.from(selectedPlayers));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modality = ref.read(gameSessionProvider).event?.modality?.name ?? '';

    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const BackButton(),
                Padding(
                  padding: const EdgeInsets.only(left: 90),
                  child: Text(
                    'Participantes',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Text(
              'Escolha os jogadores que iram compor as equipes da partida',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey_500),
              textAlign: TextAlign.center,
            ),
          ),
          if (selectedPlayers.isNotEmpty)...[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: selectedPlayers.map((participant) {
                    return InkWell(
                      onTap: () => setPlayerTeam(participant, 'remove'),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ImgCircularWidget(size: 50, image: participant.photo),
                          ),
                          const Positioned(
                            right: 5,
                            bottom: 0,
                            child: Icon(AppIcones.times_circle_solid, color: AppColors.grey_300, size: 15),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ]else...[
            const SizedBox.shrink()
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: participants.map((user) {
                  if (user.player != null) {
                    return CardPlayerTeamWidget(
                      user: user,
                      modality: modality,
                      onPressed: () => setPlayerTeam(user, 'add'),
                    );
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
