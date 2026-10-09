import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/presentation/widget/showcase/wizard_widget.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget{
  final String? title;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? leftAction;
  final IconData? leftIcon;
  final VoidCallback? rightAction;
  final IconData? rightIcon;
  final VoidCallback? extraAction;
  final IconData? extraIcon;
  final bool shadow;
  final bool? home;
  final String? photo;
  final PreferredSizeWidget? bottom;
  final bool brightness;

  const HeaderWidget({
    super.key, 
    this.title,
    this.backgroundColor,
    this.textColor,
    this.leftAction, 
    this.leftIcon = Icons.arrow_back_rounded, 
    this.rightAction, 
    this.rightIcon = Icons.close,
    this.extraAction, 
    this.extraIcon = Icons.history,
    this.shadow = true,
    this.home = false,
    this.photo,
    this.bottom,
    this.brightness = false
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: brightness
        ? Colors.transparent
        : ( backgroundColor ?? Theme.of(context).primaryColor),
      surfaceTintColor: Colors.transparent,
      title: title != null 
        ? Text(
          title!,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: textColor ?? AppColors.blue_500
          ),
        )
        : null ,
      leading: WizardWidget(
        elementKey: 'menu',
        child: IconButton(
          icon: Icon(
            leftIcon,
            color: textColor ?? AppColors.blue_500,
          ),
          onPressed: leftAction
        ),
      ),
      actions: [
        if(extraAction != null)...[
          WizardWidget(
            elementKey: 'chat',
            child: IconButton(
              icon: Icon(
                extraIcon,
                color: textColor ?? AppColors.blue_500
              ),
              onPressed: extraAction!,
            ),
          )
        ],
        if(rightAction != null)...[
          WizardWidget(
            elementKey: 'profile',
            child: IconButton(
              icon: home != null && home == true
              ? CircleAvatar(
                backgroundImage: ImgHelper.getUserImg(photo),
              )
              : Icon(rightIcon),
              color: textColor ?? AppColors.blue_500,
              onPressed: rightAction!,
            ),
          )
        ]
      ], 
      elevation: 3,
      shadowColor: shadow ? AppColors.dark_500.withAlpha(100) : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}