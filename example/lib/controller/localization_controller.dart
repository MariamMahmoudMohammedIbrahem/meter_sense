import 'package:flutter_reactive_ble_example/commons.dart';

class LocalizationController extends GetxController {
  final _storage = GetStorage(); // GetStorage instance
  RxString currentLanguage = 'en'.obs; // Default language

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage(); // Load saved language on start
  }

  void _loadSavedLanguage() {
    String? savedLang = _storage.read('language'); // Read from storage
    if (savedLang != null) {
      currentLanguage.value = savedLang;
    }
  }

  void toggleLanguage() {
    currentLanguage.value = currentLanguage.value == 'en' ? 'ar' : 'en';
    _storage.write('language', currentLanguage.value); // Save to storage
    Get.updateLocale(Locale(currentLanguage.value)); // Update app locale
  }
}
/*
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
}*/
