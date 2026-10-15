import 'dart:math';
import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_images.dart';
import 'package:palette_generator/palette_generator.dart';

class AppColors {
  AppColors._();

  //GREEN
  static const green_900 = Color(0xFF012C12);
  static const green_800 = Color(0xFF014A1E);
  static const green_700 = Color(0xFF015924);
  static const green_600 = Color(0xFF027A31);
  static const green_500 = Color(0xFF03983E);
  static const green_400 = Color(0xFF03B550);
  static const green_300 = Color(0xFF04D361);
  static const green_200 = Color(0xFF45D988);
  static const green_100 = Color(0xFF93D6B1);

  //BEGE
  static const bege_900 = Color(0xFF4E3722);
  static const bege_800 = Color(0xFF715032);
  static const bege_700 = Color(0xFF946C4B);
  static const bege_600 = Color(0xFFB28862);
  static const bege_500 = Color(0xFFD1A57A);
  static const bege_400 = Color(0xFFE4BB91);
  static const bege_300 = Color(0xFFF6D1A8);
  static const bege_200 = Color(0xFFF7DABA);
  static const bege_100 = Color(0xFFF8E3CB);

  //ORANGE
  static const orange_900 = Color(0xFF571505);
  static const orange_800 = Color(0xFF791D06);
  static const orange_700 = Color(0xFF9B2908);
  static const orange_600 = Color(0xFFC3330A);
  static const orange_500 = Color(0xFFEB3D0B);
  static const orange_400 = Color(0xFFED4E0A);
  static const orange_300 = Color(0xFFEF5F08);
  static const orange_200 = Color(0xFFEB8648);
  static const orange_100 = Color(0xFFE7AC88);

  //RED
  static const red_900 = Color(0xFF4B0202);
  static const red_800 = Color(0xFF590303);
  static const red_700 = Color(0xFF660404);
  static const red_600 = Color(0xFFA40404);
  static const red_500 = Color(0xFFE20505);
  static const red_400 = Color(0xFFEB241E);
  static const red_300 = Color(0xFFF44336);
  static const red_200 = Color(0xFFF4776D);
  static const red_100 = Color(0xFFF3AAA4);

  //YELLOW
  static const yellow_900 = Color(0xFF664E00);
  static const yellow_800 = Color(0xFF937200);
  static const yellow_700 = Color(0xFFBF9500);
  static const yellow_600 = Color(0xFFDFAE00);
  static const yellow_500 = Color(0xFFFFC700);
  static const yellow_400 = Color(0xFFFFDE00);
  static const yellow_300 = Color(0xFFFFF500);
  static const yellow_200 = Color(0xFFEFF328);
  static const yellow_100 = Color(0xFFFFE69C);

  //BLUE
  static const blue_900 = Color(0xFF080314);
  static const blue_800 = Color(0xFF0A041D);
  static const blue_700 = Color(0xFF0C0626);
  static const blue_600 = Color(0xFF10063B);
  static const blue_500 = Color(0xFF140750);
  static const blue_400 = Color(0xFF1A41A1);
  static const blue_300 = Color(0xFF1F7BF2);
  static const blue_200 = Color(0xFF609FEF);
  static const blue_100 = Color(0xFFA1C2EC);

  //PURPLE
  static const purple_900 = Color(0xFF0F021E);
  static const purple_800 = Color(0xFF180436);
  static const purple_700 = Color(0xFF21054E);
  static const purple_600 = Color(0xFF330977);
  static const purple_500 = Color(0xFF450CA0);
  static const purple_400 = Color(0xFF560EC9);
  static const purple_300 = Color(0xFF6610F2);
  static const purple_200 = Color(0xFF9652EB);
  static const purple_100 = Color(0xFFAB85E8);

  //CYAN
  static const cyan_900 = Color(0xFF022A33);
  static const cyan_800 = Color(0xFF043C48);
  static const cyan_700 = Color(0xFF055160);
  static const cyan_600 = Color(0xFF098EA8);
  static const cyan_500 = Color(0xFF0DCAF0);
  static const cyan_400 = Color(0xFF3ED5F3);
  static const cyan_300 = Color(0xFF6EDFF6);
  static const cyan_200 = Color(0xFF96E7F8);
  static const cyan_100 = Color(0xFFBEEFF9);

  //BROWN
  static const brown_900 = Color(0xFF231201);
  static const brown_800 = Color(0xFF351B02);
  static const brown_700 = Color(0xFF472302);
  static const brown_600 = Color(0xFF723803);
  static const brown_500 = Color(0xFF9C4D03);
  static const brown_400 = Color(0xFFBE6D21);
  static const brown_300 = Color(0xFFDF8C3E);
  static const brown_200 = Color(0xFFECB37E);
  static const brown_100 = Color(0xFFF8D9BD);

  //TEAL (defesa, goleiro)
  static const teal_900 = Color(0xFF031E16);
  static const teal_800 = Color(0xFF053629);
  static const teal_700 = Color(0xFF064E3B);
  static const teal_600 = Color(0xFF0B6255);
  static const teal_500 = Color(0xFF0F766E);
  static const teal_400 = Color(0xFF12978A);
  static const teal_300 = Color(0xFF14B8A6);
  static const teal_200 = Color(0xFF57D7C5);
  static const teal_100 = Color(0xFF99F6E4);

  //INDIGO (bola parada, lances especiais)
  static const indigo_900 = Color(0xFF0C0A1E);
  static const indigo_800 = Color(0xFF151335);
  static const indigo_700 = Color(0xFF1E1B4B);
  static const indigo_600 = Color(0xFF2B2677);
  static const indigo_500 = Color(0xFF3730A3);
  static const indigo_400 = Color(0xFF4D4BCA);
  static const indigo_300 = Color(0xFF6366F1);
  static const indigo_200 = Color(0xFF959CF8);
  static const indigo_100 = Color(0xFFC7D2FE);

  //BASE
  static const dark_700 = Color(0xFF181818);
  static const dark_500 = Color(0xFF272727);
  static const dark_300 = Color(0xFF454545);
  static const grey_700 = Color(0xFF969696);
  static const grey_500 = Color(0xFFAAAAAA);
  static const grey_300 = Color(0xFFCCCCCC);
  static const light = Color(0xFFF6F9FF);
  static const white = Color(0xFFFFFFFF);

  //TODAS AS CORES EM STRING
  static Map<String, Color> colors = {
    'green_900': green_900, 'green_800': green_800, 'green_700': green_700,
    'green_600': green_600, 'green_500': green_500, 'green_400': green_400,
    'green_300': green_300, 'green_200': green_200, 'green_100': green_100,

    'bege_900': bege_900, 'bege_800': bege_800, 'bege_700': bege_700,
    'bege_600': bege_600, 'bege_500': bege_500, 'bege_400': bege_400,
    'bege_300': bege_300, 'bege_200': bege_200, 'bege_100': bege_100,

    'orange_900': orange_900, 'orange_800': orange_800, 'orange_700': orange_700,
    'orange_600': orange_600, 'orange_500': orange_500, 'orange_400': orange_400,
    'orange_300': orange_300, 'orange_200': orange_200, 'orange_100': orange_100,

    'red_900': red_900, 'red_800': red_800, 'red_700': red_700,
    'red_600': red_600, 'red_500': red_500, 'red_400': red_400,
    'red_300': red_300, 'red_200': red_200, 'red_100': red_100,

    'yellow_900': yellow_900, 'yellow_800': yellow_800, 'yellow_700': yellow_700,
    'yellow_600': yellow_600, 'yellow_500': yellow_500, 'yellow_400': yellow_400,
    'yellow_300': yellow_300, 'yellow_200': yellow_200, 'yellow_100': yellow_100,

    'blue_900': blue_900, 'blue_800': blue_800, 'blue_700': blue_700,
    'blue_600': blue_600, 'blue_500': blue_500, 'blue_400': blue_400,
    'blue_300': blue_300, 'blue_200': blue_200, 'blue_100': blue_100,

    'purple_900': purple_900, 'purple_800': purple_800, 'purple_700': purple_700,
    'purple_600': purple_600, 'purple_500': purple_500, 'purple_400': purple_400,
    'purple_300': purple_300, 'purple_200': purple_200, 'purple_100': purple_100,

    'cyan_900': cyan_900, 'cyan_800': cyan_800, 'cyan_700': cyan_700,
    'cyan_600': cyan_600, 'cyan_500': cyan_500, 'cyan_400': cyan_400,
    'cyan_300': cyan_300, 'cyan_200': cyan_200, 'cyan_100': cyan_100,

    'brown_900': brown_900, 'brown_800': brown_800, 'brown_700': brown_700,
    'brown_600': brown_600, 'brown_500': brown_500, 'brown_400': brown_400,
    'brown_300': brown_300, 'brown_200': brown_200, 'brown_100': brown_100,

    'teal_900': teal_900, 'teal_800': teal_800, 'teal_700': teal_700,
    'teal_600': teal_600, 'teal_500': teal_500, 'teal_400': teal_400,
    'teal_300': teal_300, 'teal_200': teal_200, 'teal_100': teal_100,

    'indigo_900': indigo_900, 'indigo_800': indigo_800, 'indigo_700': indigo_700,
    'indigo_600': indigo_600, 'indigo_500': indigo_500, 'indigo_400': indigo_400,
    'indigo_300': indigo_300, 'indigo_200': indigo_200, 'indigo_100': indigo_100,

    'dark_700': dark_700, 'dark_500': dark_500, 'dark_300': dark_300,
    'grey_700': grey_700, 'grey_500': grey_500, 'grey_300': grey_300,
    'light': light, 'white': white,
  };

  //CACHE DE COR PREDOMINANTES DAS IMAGENS DO EVENTO
  static final Map<String, Color> _imageColorCache = {};

  //RESGATAR COR DOMINANTE DA IMAGEM NO CACHE
  static Future<Color> getCachedDominantColor(String? imageUrl) async {
    if (imageUrl == null) return grey_300;

    if (_imageColorCache.containsKey(imageUrl)) {
      return _imageColorCache[imageUrl]!;
    }

    final dominantColor = await getDominantColor(imageUrl);
    _imageColorCache[imageUrl] = dominantColor;
    return dominantColor;
  }

  //FUNÇÃO PARA CALCULAR A DISTANCIA ENTRE DUAS CORES NO ESPAÇO RGB
  static double colorDistance(Color color1, Color color2) {
    //RESGATAR DIFERENÇA DE VALORES RGB ENTRE AS DUAS CORES
    final rDiff = color1.r - color2.r;
    final gDiff = color1.g - color2.g;
    final bDiff = color1.b - color2.b;
    //RETORNAR VALOR DE COR OBTIDO
    return rDiff * rDiff + gDiff * gDiff + bDiff * bDiff;
  }

  //FUNÇÃO PARA ENCONTRAR A COR MAIS PROXIMA DA CLASSE
  static Color findClosestColor(Color targetColor) {
    //LISTA DE CORES
    List<Color> listColors = AppColors.colors.values.toList();
    //COR PADRÃO
    Color nearestColor = AppColors.green_300;
    //DISTANCIA MINIMA
    double minDistance = double.infinity;
    //PERCORRER TODAS AS CORES
    for (final appColor in listColors) {
      //CALCULAR DISTANCIA DE COR RECEBIDA COM COR DO LOOP
      final distance = colorDistance(targetColor, appColor);
      //VERIFICAR DISTANCI ENTRE CORES
      if (distance < minDistance) {
        minDistance = distance;
        nearestColor = appColor;
      }
    }
    //RETORNAR COR MAIS PROXIMA
    return nearestColor;
  }

  //FUNÇÃO PARA RESGATAR COR PREDOMINANTE DA IMAGEM
  static Future<Color> getDominantColor(String? image) async {
    //DEFINIR COR PADRÃO
    Color colorDefault = AppColors.green_300;
    try {
      //RESGATAR IMAGEM A SER ANALISADA
      final imageProvider = image != null
        ? NetworkImage(image)
        : const AssetImage(AppImages.cardFootball) as ImageProvider;
      //GERAR PALETA DE CORES APARTIR DA IMAGEM
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 10, //NUMERO MAXIMO DE CORES A SEREM COLETADAS
      );
      //VERIFICAR SE FOI POSSIVEL GERAR A PALETA DE CORES
      if (paletteGenerator.colors.isNotEmpty) {
        // RESGATAR A PRIMEIRA COR DA PALETA DE CORES
        final dominantColor = paletteGenerator.dominantColor?.color;
        //VERIFICAR SE COR PREDOMINANTE FOI ENCONTRADA
        if (dominantColor != null) {
          //ENCONTRAR A COR MAIS PRÓXIMA EM AppColors
          return findClosestColor(dominantColor);
        }
      }
      //RETORNAR COR PADRÃO
      return colorDefault;
    } catch (e) {
      //RETORNAR COR PADRÃO
      return colorDefault;
    }
  }

  //ESCOLHER TOM MAIS CLARO DA COR
  static Color brightnessColor(color){
    var newKey = [];
    //LOOP NAS CORES
    AppColors.colors.forEach((key, value){
      //FILTRAR CORES DO TIPO 100
      if(value == color){
        newKey = key.split('_');
      }
    });
    return AppColors.colors['${newKey[0]}']!;
  }

  //ESCOLHER A COR DO CARD ALEATORIAMENTE
  static Color randomColor(){
    //DEFINIR ARRAY DE ITEMS
    List items = [];
    //LOOP NAS CORES
    AppColors.colors.forEach((key, value){
      //FILTRAR CORES DO TIPO 100
      if(key.contains('100')){
        items.add(value);
      }
    });
    //INSTANCIAR RANDOM
    Random random = Random();
    //SELECIONAR ITEM ALEATORIAMENTE
    int i = random.nextInt(items.length);
    //RETORNAR COR ALEATORIA
    return items[i];
  }
}
