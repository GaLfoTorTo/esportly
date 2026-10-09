import 'dart:io';

import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/theme/app_images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class ImgHelper {
  //FUNÇÃO PARA RESGATAR IMAGEM DO EVENTO
  static ImageProvider getEventImg(EventModel? event){
    //RESGATAR IMAGEM DA PELADA
    if(event != null){
      final imgProvider = event?.photo != null
        ? CachedNetworkImageProvider(event!.photo!)
        : AssetImage(ModalityHelper.getEventModalityColor(event.gameConfig?.category ?? event.modality?.name ?? 'Football')['image']) as ImageProvider;
        return imgProvider;
    }
    return const AssetImage(AppImages.cardFootball) as ImageProvider;
  }

  //FUNÇÃO PARA RESGATAR IMAGEM DO USUARIO
  static ImageProvider getUserImg(String? photo){
    //RESGATAR IMAGEM DA PELADA
    final imgProvider = photo != null && photo.startsWith('http')
      ? CachedNetworkImageProvider(photo)
      : const AssetImage(AppImages.userDefault) as ImageProvider;
      return imgProvider;
  }

  //FUNÇÃO PARA RESGATAR IMAGEM DO ENDEREÇO
  static List<ImageProvider> getAddressImg(List<String>? photos){
    //LISTA DE IMAGENS
    List<ImageProvider> arrPhotos = [];
    //VERIFICAR SE EXISTEM FOTOS DO LOCAL
    if(photos != null){
      for(var photo in photos){
        //RESGATAR IMAGEM DA PELADA
        arrPhotos.add(CachedNetworkImageProvider(photo));
      }
    }
    return arrPhotos;
  }

  //FUNÇÃO PARA BUSCAR IMAGEM DE CAPA
  Future<File?> getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    //VERIFICAR SE IMAGEM FOI SELECIONADA
    if (image != null) {
      //RESGTAR CAMINHO DA IMAGEM
      return File(image.path);
    }
    return null;
  }
  
  //FUNÇÃO DE EXIBIÇÃO DE CAPA
  dynamic capaImage(imageFile, dimensions){
    if(imageFile != null){
      return Container(
        width: 200,
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageFile is File 
              ? FileImage(imageFile) as ImageProvider<Object>
              : CachedNetworkImageProvider(imageFile),
            fit: BoxFit.cover
          ),
          border: Border.all(
            color: AppColors.grey_500,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
      );
    }else{
      return Opacity(
        opacity: 0.3,
        child: Container(
          width: 200,
          height: 200,
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.grey_700,
            border: Border.all(
              color: AppColors.grey_500,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            AppIcones.camera_solid,
            color: AppColors.blue_500,
            size: 30,
          ),
        ),
      );
    }
  }
}