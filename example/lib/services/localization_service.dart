
import '../commons.dart';

class LocalizationService {

  late final Locale locale;
  static late Locale currentLocale;

  LocalizationService(this.locale){
    currentLocale = locale;
  }

  static LocalizationService? of(BuildContext context)=> Localizations.of<LocalizationService>(context, LocalizationService);

  late Map<String, String> _localizedString;

  Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');

    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    _localizedString = jsonMap.map((String key,dynamic value) => MapEntry(key, value.toString()));
  }

  String? translate(String key)=> _localizedString[key];

  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'AR')
  ];

  static Locale? localeResolutionCallBack(Locale? locale, Iterable<Locale>? supportedLocales){
    if(supportedLocales != null && locale != null){
      return supportedLocales.firstWhere((element) =>
      element.languageCode == locale.languageCode,
          orElse: ()=> supportedLocales.first);
    }

    return null;
  }

  static const LocalizationsDelegate<LocalizationService> _delegate = _LocalizationServiceDelegate();

  static const localizationsDelegate = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    _delegate
  ];


}

class _LocalizationServiceDelegate extends LocalizationsDelegate<LocalizationService> {
  const _LocalizationServiceDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<LocalizationService> load(Locale locale) async{
    final service = LocalizationService(locale);
    await service.load();
    return service;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<LocalizationService> old) => false;
}
