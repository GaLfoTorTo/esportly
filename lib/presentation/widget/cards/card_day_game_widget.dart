import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/data/models/event_model.dart';

class CardDayGameWidget extends StatefulWidget {
  final EventModel event;
  const CardDayGameWidget({
    super.key,
    required this.event,
  });

  @override
  State<CardDayGameWidget> createState() => _CardGameLiveWidgetState();
}

class _CardGameLiveWidgetState extends State<CardDayGameWidget> {
  //ESTADO - ITEMS EVENTO
  late Color modalityColor;
  late Color modalityTextColor;
  late String modalityImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //ESTADO - ITEMS EVENTO
    modalityColor = ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality?.name ?? 'Football')['color'];
    modalityTextColor = ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality?.name ?? 'Football')['textColor'];
    modalityImage = ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality?.name ?? 'Football')['image'];
  }

  @override
  Widget build(BuildContext context) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;

    return Card(
      child: Container(
        width: dimensions.width - 10,
        height: 300,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }
}