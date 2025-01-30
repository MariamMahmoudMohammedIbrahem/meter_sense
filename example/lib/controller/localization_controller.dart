import 'package:flutter_reactive_ble_example/commons.dart';

class LocalizationController extends GetxController{
  String currentLanguage = ''.obs.toString();

  void toggleLanguage(String lang) {
    if(lang == 'ara'){
      currentLanguage ='ar';
    }else{
      currentLanguage = 'en';
    }
    // currentLanguage = LocalizationService.currentLocale.languageCode == 'ar' ? 'en' : 'ar';
    update();
  }
}