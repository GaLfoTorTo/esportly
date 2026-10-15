import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/img_helper.dart';

class ImgCircularWidget extends StatelessWidget {
  final double size;
  final String? image;
  final String? element;
  final Color? borderColor;
  final bool online;

  const ImgCircularWidget({
    super.key,
    required this.size,
    this.image,
    this.element,
    this.borderColor,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider getImg(){
      if(element == "event") return ImgHelper.getEventImg(null);
      return ImgHelper.getUserImg(image);
    }

    final userImg = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: getImg(),
          fit: BoxFit.cover
        ),
        color: AppColors.grey_300,
        border: Border.all(
          color: borderColor ?? AppColors.grey_500,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );

    if (!online) return userImg;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        userImg,
        const Positioned(
          right: 5,
          bottom: 0,
          child: Icon(
            Icons.circle,
            size: 15,
            color: AppColors.green_300,
          ),
        ),
      ],
    );
  }
}