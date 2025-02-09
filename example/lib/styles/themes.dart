


import '../commons.dart';

ThemeData lightTheme = ThemeData(
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.grey.shade100, // Default background color
  ),
  scaffoldBackgroundColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: MyColors.lightGreen,
      disabledBackgroundColor: Colors.black,
      shape: const StadiumBorder(),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      foregroundColor: Colors.black, // Add this line to set text color
      disabledForegroundColor: MyColors.lightGreen,
    ),
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w900,
      color: MyColors.lightGreen,
    ),
    displayMedium: const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w900,
      color: MyColors.lightGreen,
    ),
    displaySmall: const TextStyle(
      fontWeight: FontWeight.w900,
      color: MyColors.lightGreen,
    ),
    titleMedium: const TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    titleSmall: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodyMedium: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.green.shade900,
    ),
    bodyLarge: const TextStyle(
      color: Colors.brown,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  dividerTheme: const DividerThemeData(
    thickness: 1,
    indent: 0,
    endIndent: 10,
    color: MyColors.lightGreen,
  ),
);
