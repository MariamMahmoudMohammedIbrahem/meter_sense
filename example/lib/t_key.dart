import 'package:flutter/cupertino.dart';

import 'localization_service.dart';

enum TKeys{
  arabic,
  english,
  device,
  electricity,
  water,
  close,
  failed,
  qr,
  change,
  name,
  currentTarrif,
  today,
  month,
  balance,
  recharge,
  history,
  logout,
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december,
  update,
  choose,
  tarrif,
  balanceStation,
  get,
  id
}

//Tkeys.device
extension TKeysExtention on TKeys{
  String get _string => toString().split('.')[1];
  String translate(BuildContext context){
    return LocalizationService.of(context)?.translate(_string)??'';
  }
}