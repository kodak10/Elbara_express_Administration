import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elbaraexpress_admin/const/size_utils.dart';

class ColorConstant {
  static Color gray600 = fromHex('#6b6b6b');

  static Color black9007e = fromHex('#7e000000');

  static Color blueGray100 = fromHex('#d9d9d9');

  static Color red700 = fromHex('#d83636');

  static Color blue700 = fromHex('#307dc7');

  static Color blueGray400 = fromHex('#888888');

  static Color amber500 = fromHex('#ffc107');

  static Color amber700 = fromHex('#e1a200');

  static Color deepPurple60075 = fromHex('#75663ba5');

  static Color deepPurple600 = fromHex('#11078c');

  static Color gray200 = fromHex('#f0f0f0');

  static Color gray300 = fromHex('#e4e4e4');

  static Color gray50 = fromHex('#f8f8f8');

  static Color blue50 = fromHex('#d4e4ff');

  static Color deepPurple50 = fromHex('#f3ebff');

  static Color greenA700 = fromHex('#04b155');

  static Color black900 = fromHex('#000000');

  static Color whiteA700 = fromHex('#ffffff');

  static Color gray8004c = fromHex('#4c3c3c43');

  static Color cyan400 = fromHex('#30acc7');
  static Color red = fromHex('#D93636');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

closeApp() {
  Future.delayed(const Duration(milliseconds: 1000), () {
    SystemNavigator.pop();
  });
}
