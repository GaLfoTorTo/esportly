import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/theme/app_images.dart';

class ModalityHelper {
  //FUNÇÃO DE ESTAMPA DO CAMPO
  static String getCategoryCourt(String? category, {bool? large}){
    switch (category) {
      case 'Futebol':
        return large != null && large ? AppIcones.futebol_xl : AppIcones.futebol_sm;
      case 'Fut7':
        return large != null && large ? AppIcones.fut7_xl : AppIcones.fut7_sm;
      case 'Futsal':
        return large != null && large ? AppIcones.futsal_xl : AppIcones.futsal_sm;
      case 'Volei':
        return large != null && large ? AppIcones.volei_xl : AppIcones.volei_sm;
      case 'Volei de praia':
        return large != null && large ? AppIcones.volei_areia_xl : AppIcones.volei_areia_sm;
      case 'Fut Volei':
        return large != null && large ? AppIcones.volei_areia_xl : AppIcones.volei_areia_sm;
      case 'Basquete':
        return large != null && large ? AppIcones.basquete_xl : AppIcones.basquete_sm;
      case 'Streetball':
        return large != null && large ? AppIcones.basquete_street_xl : AppIcones.basquete_street_sm;
      default:
        return large != null && large ? AppIcones.futebol_xl : AppIcones.futebol_sm;
    }
  }

  //FUNÇÃO PARA RESGATAR ICONE DA CATEGORIA
  static Map<String, dynamic> getIconModality(String key){
    switch (key) {
      case "Futebol":
        return {
          "icon": Icons.sports_soccer_rounded,
          "texColor": AppColors.blue_500,
          "color": AppColors.green_300,
          "bg": AppColors.green_700,
        };
      case "Volei":
        return {
          "icon": Icons.sports_volleyball_outlined,
          "texColor": AppColors.blue_500,
          "color": AppColors.yellow_500,
          "bg": AppColors.yellow_700,
        };
      case "Basquete":
        return {
          "icon": Icons.sports_basketball_rounded,
          "texColor": AppColors.blue_500,
          "color": AppColors.orange_300,
          "bg": AppColors.orange_700,
        };
      default:
        return {
          "icon": Icons.sports_soccer_rounded,
          "texColor": AppColors.white,
          "color": AppColors.green_300,
          "bg": AppColors.green_700,
        };
    }
  }

  //FUNÇÃO PARA RESGATAR ICONE DA CATEGORIA
  static Map<String, dynamic> getIconCategory(String key){
    switch (key) {
      case "Futebol":
        return {
          "icon": Icons.sports_soccer_rounded,
          "texColor": AppColors.blue_500,
          "color": AppColors.green_300,
          "bg": AppColors.green_700,
          };
      case "Fut7":
        return {
          "icon": Icons.sports_soccer_sharp,
          "texColor": AppColors.white,
          "color": AppColors.green_300,
          "bg": AppColors.green_700,
          };
      case "Futsal":
        return {
          "icon": Icons.sports_soccer_outlined,
          "texColor": AppColors.white,
          "color": AppColors.blue_300,
          "bg": AppColors.blue_700,
          };
      case "Volei":
        return {
          "icon": Icons.sports_volleyball_rounded,
          "texColor": AppColors.blue_500,
          "color": AppColors.yellow_500,
          "bg": AppColors.yellow_700,
          };
      case "Volei Praia":
        return {
          "icon": Icons.sports_volleyball_outlined,
          "texColor": AppColors.blue_500,
          "color": AppColors.bege_300,
          "bg": AppColors.bege_700,
          };
      case "Fut Volei":
        return {
          "icon": Icons.sports_soccer_outlined,
          "texColor": AppColors.blue_500,
          "color": AppColors.bege_300,
          "bg": AppColors.bege_700,
          };
      case "Basquete":
        return {
          "icon": Icons.sports_basketball_rounded,
          "texColor": AppColors.blue_500,
          "color": AppColors.orange_300,
          "bg": AppColors.orange_700,
          };
      case "Streetball":
        return {
          "icon": Icons.sports_basketball_outlined,
          "texColor": AppColors.white,
          "color": AppColors.dark_300,
          "bg": AppColors.dark_700,
          };
      default:
        return {
          "icon": Icons.sports,
          "texColor": AppColors.green_300,
          "color": AppColors.green_300,
          "bg": AppColors.green_700,
          };
    }
  }
 
 //FUNÇÃO PARA RESGATAR CATEGORIA DO EVENTO
  static String getCategory(String modality, int num){
    if(modality == "Football"){
      switch (num) {
        case 0:
          return "Futebol";
        case 1:
          return "Fut7";
        case 2:
          return "Futsal";
        default:
          return "Futebol";
      }
    }
    if(modality == "Volleyball"){
      switch (num) {
        case 0:
          return "Volei";
        case 1:
          return "Volei de praia";
        case 2:
          return "Fut Volei";
        default:
          return "Volei";
      }
    }
    if(modality == "Basketball"){
      switch (num) {
        case 0:
          return "Basquete";
        case 1:
          return "Streetball";
        default:
          return "Basquete";
      }
    }
    return "Futebol";
  }

  //FUNÇÃO PARA DEFINIÇÃO DE QUANTIDADE DE JOGADORES POR CATEGORIA
  static Map<String, int> getQtdPlayers(String category){
    //SELECIONAR TIPO DE CAMPO
    switch (category) {
      //DEFINIR VALOR PARA SLIDER
      case "Futebol":
        return {
          "qtdPlayers" : 11,
          "minPlayers" :  9,
          "maxPlayers" : 11,
          "divisions" : 2,
        };
      case "Fut7":
        return {
          "qtdPlayers" : 4,
          "minPlayers" :  4,
          "maxPlayers" : 8,
          "divisions" : 4,
        };
      case "Futsal":
        return {
          "qtdPlayers" : 5,
          "minPlayers" :  4,
          "maxPlayers" : 6,
          "divisions" : 2,
        };
      case "Volei":
        return {
          "qtdPlayers" : 6,
          "minPlayers" :  2,
          "maxPlayers" : 6,
          "divisions" : 1,
        };
      case "Volei de praia":
        return {
          "qtdPlayers" : 2,
          "minPlayers" :  2,
          "maxPlayers" : 6,
          "divisions" : 1,
        };
      case "Fut Volei":
        return {
          "qtdPlayers" : 2,
          "minPlayers" :  2,
          "maxPlayers" : 6,
          "divisions" : 1,
        };
      case "Basquete":
        return {
          "qtdPlayers" : 5,
          "minPlayers" : 3,
          "maxPlayers" : 5,
          "divisions" : 1,
        };
      case "Streetball":
        return {
          "qtdPlayers" : 3,
          "minPlayers" : 1,
          "maxPlayers" : 5,
          "divisions" : 1,
        };
      default:
        return {
          "qtdPlayers" : 11,
          "minPlayers" :  9,
          "maxPlayers" : 11,
          "divisions" : 2,
        };
    }
  }

  //FUNÇÃO PARA RESGATAR A COR DA MODALIDADE DA PELADA
  static Map<String, dynamic> getEventModalityColor(String modality){
    switch (modality) {
      case "Volleyball":
      case "Volei":
        return {
          "color" : AppColors.yellow_300,
          "bg" : AppColors.yellow_500,
          "textColor" : AppColors.white,
          "image" : AppImages.cardVolleyball
          };
      case "Volei de praia":
        return {
          "color" : AppColors.bege_300,
          "bg" : AppColors.bege_500,
          "textColor" : AppColors.blue_500,
          "image" : AppImages.cardBeachVolleyball
          };
      case "Fut Volei":
        return {
          "color" : AppColors.bege_300,
          "bg" : AppColors.bege_500,
          "textColor" : AppColors.blue_500,
          "image" : AppImages.cardFutvolei
          };
      case "Basketball":
      case "Basquete":
        return {
          "color" : AppColors.orange_500,
          "bg" : AppColors.orange_700,
          "textColor" : AppColors.white,
          "image" : AppImages.cardBasketball
          };
      case "Streetball":
        return {
          "color" : AppColors.dark_300,
          "bg" : AppColors.dark_700,
          "textColor" : AppColors.white,
          "image" : AppImages.cardStreetball
          };
      case "Futsal":
        return {
          "color" : AppColors.blue_300,
          "bg" : AppColors.blue_500,
          "textColor" : AppColors.white,
          "image" : AppImages.cardFutsal
          };
      default:
        return {
          "color" : AppColors.green_300,
          "bg" : AppColors.green_500,
          "textColor" : AppColors.blue_500,
          "image" : AppImages.cardFootball
          };
    }
  }
}