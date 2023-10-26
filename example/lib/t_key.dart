import 'package:flutter/cupertino.dart';

import 'localization_service.dart';

enum TKeys{
  arabic,
  english,
  scan,
  scanning,
  device,
  electricity,
  water,
  close,
  failed,
  qr,
  change,
  welcome,
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
  connect,
  disconnect,
  welcomeMaster,
  id
}

//Tkeys.device
extension TKeysExtention on TKeys{
  String get _string => toString().split('.')[1];
  String translate(BuildContext context){
    return LocalizationService.of(context)?.translate(_string)??'';
  }
}