import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/presentation/controllers/theme_controller.dart';

class AppImages {
  //RESGATAR COR PRINCIPAL
  static String get primaryColor {
    try {
      return sl<ThemeController>().mainModality;
    } catch (e) {
      return cardFootball;
    }
  }

  static const logo = "assets/images/icons/logo.png";
  static const userDefault = "assets/images/user-default.png";
  static const linhas = "assets/images/linhas.png";
  //IMAGENS PARA CAPAS DE APRESENTAÇÃO DE PÁGINAS
  static const capaEvent = "assets/images/capas/capa_event.png";
  static const capaExplore = "assets/images/capas/capa_explore.png";
  static const capaEscalacao = "assets/images/capas/capa_escalacao.png";
  //IMAGENS PARA CAPAS APRESENTAÇÃO DE REGISTROS
  static const football = "assets/images/register/football.jpg";
  static const volleyball = "assets/images/register/volleyball.jpg";
  static const basketball = "assets/images/register/basketball.jpg";
  //IMAGENS PARA BACKGROUND DE CARDS
  static const cardFootball = "assets/images/cards/football_card.jpg";
  static const cardFutsal = "assets/images/cards/futsal_card.jpg";
  static const cardFutvolei = "assets/images/cards/futvolei_card.png";
  static const cardVolleyball = "assets/images/cards/volleyball_card.jpg";
  static const cardBeachVolleyball = "assets/images/cards/beach_volleyball_card.jpg";
  static const cardBasketball = "assets/images/cards/basketball_card.jpg";
  static const cardStreetball = "assets/images/cards/streetball_card.png";
  //MAPEAMENTO DE IMAGENS DE CARD
  static Map<String, String> cards = {
    "Football": cardFootball,
    "Volleyball": cardVolleyball,
    "Basketball": cardBasketball
  };
  //MAPEAMENTO DE IMAGENS DE POSIÇÕES
  static Map<String, String> positions = {
    "ATA": "assets/images/positions/Football/position_ata.png",
    "MEI": "assets/images/positions/Football/position_mei.png",
    "LAT": "assets/images/positions/Football/position_lat.png",
    "ZAG": "assets/images/positions/Football/position_zag.png",
    "GOL": "assets/images/positions/Football/position_gol.png",
    "PON": "assets/images/positions/volleyball/position_pon.png",
    "CEN": "assets/images/positions/volleyball/position_cen.png",
    "OPO": "assets/images/positions/volleyball/position_opo.png",
    "LIB": "assets/images/positions/volleyball/position_lib.png",
    "LEV": "assets/images/positions/volleyball/position_lev.png",
    "ARM": "assets/images/positions/basketball/position_arm.png",
    "ALA": "assets/images/positions/basketball/position_ala.png",
    "PIV": "assets/images/positions/basketball/position_piv.png",
    "ALP": "assets/images/positions/basketball/position_alp.png",
    "ALM": "assets/images/positions/basketball/position_alm.png",
  };
}