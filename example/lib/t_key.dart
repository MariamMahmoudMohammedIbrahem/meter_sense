import 'package:flutter/cupertino.dart';

import 'localization_service.dart';

enum TKeys{
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
  today,
  month,
  balance,
  consumption,
  recharge,
  recharged,
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
  updated,
  charge,
  request,
  choose,
  meter,
  tarrif,
  balanceStation,
  submit,
  connect,
  disconnect,
  welcomeMaster,
  id
}

//Tkeys.device
extension TKeysExtention on TKeys{
  String get _string => toString().split('.')[1];
  String translate(BuildContext context)=> LocalizationService.of(context)?.translate(_string)??'';
}