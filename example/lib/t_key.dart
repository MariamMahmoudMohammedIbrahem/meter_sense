import 'commons.dart';

enum TKeys {
  accessLocation,
  accessCamera,
  accessBluetooth,
  arabic,
  english,
  scan,
  scanning,
  device,
  notConnected,
  hint,
  first,
  electricity,
  water,
  close,
  failed,
  qr,
  change,
  welcome,
  name,
  currentTarrif,
  totalReadings,
  valveStatus,
  balance,
  consumption,
  recharge,
  recharged,
  history,
  timeOut,
  upToDate,
  chargeSuccess,
  // logout,
  update,
  updated,
  charge,
  request,
  choose,
  meter,
  tariff,
  balanceStation,
  submit,
  connect,
  connecting,
  disconnect,
  disconnecting,
  selectDevice,
  welcomeMaster,
  id,
  uploadData,
  dataSent,
  meterData,
  tariffVersion,
  tariffPrice,
  chargingData,
  waterUnit,
  electricUnit,
  priceUnit,
  Mon,
  Tue,
  Wed,
  Thu,
  Fri,
  Sat,
  Sun,
  Jan,
  Feb,
  Mar,
  Apr,
  May,
  Jun,
  Jul,
  Aug,
  Sep,
  Oct,
  Nov,
  Dec,
  resetting
}

//Tkeys.device
extension TKeysExtention on TKeys{
  String get _string => toString().split('.')[1];
  String translate(BuildContext context)=> LocalizationService.of(context)?.translate(_string)??'';
}

String translateDate(BuildContext context, String date) {
  final localizationService = LocalizationService.of(context);
  if (localizationService == null) return date; // Handle null case

  List<String> parts = date.split(", ");
  if (parts.length < 2) return date; // Return original if format is incorrect

  String dayPart = parts[0]; // Day abbreviation (e.g., Tue)
  List<String> dateParts = parts[1].split(" "); // ["Feb", "4"]

  if (dateParts.length < 2) return date; // Ensure valid format

  String monthPart = dateParts[0]; // Month abbreviation (e.g., Feb)
  String dayNumber = dateParts[1]; // Day number (e.g., 4)

  String translatedDay = localizationService.translate(dayPart) ?? dayPart;
  String translatedMonth = localizationService.translate(monthPart) ?? monthPart;
  print(translatedMonth);

  return "$translatedDay،$dayNumber $translatedMonth";
}