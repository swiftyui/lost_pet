import 'dart:math';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:material_color_utilities/material_color_utilities.dart';

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return child;
  }
}

class ThemeSettings {
  ThemeSettings({
    required this.sourceColor,
    required this.themeMode,
  });

  final Color sourceColor;
  final ThemeMode themeMode;
}

class ThemeSettingsChange extends Notification {
  ThemeSettingsChange({required this.settings});

  final ThemeSettings settings;
}

class CustomColor {
  const CustomColor({
    required this.name,
    required this.color,
    this.blend = true,
  });

  final String name;
  final Color color;
  final bool blend;

  Color value(ThemeProvider provider) {
    return provider.custom(this);
  }
}

class ThemeProvider extends InheritedWidget {
  const ThemeProvider(
      {super.key, required this.settings, required super.child});

  final ValueNotifier<ThemeSettings> settings;

  final pageTransitionsTheme = const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
        TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
        TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
      });

  Color custom(CustomColor custom) {
    if (custom.blend) {
      return blend(custom.color);
    } else {
      return custom.color;
    }
  }

  Color blend(Color targetColour) {
    return Color(
        Blend.harmonize(targetColour.value, settings.value.sourceColor.value));
  }

  Color source(Color? target) {
    Color source = settings.value.sourceColor;
    if (target != null) {
      source = blend(target);
    }
    return source;
  }

  ColorScheme colors(Brightness brightness, Color? targetColor) {
    return ColorScheme.fromSeed(
        seedColor: source(targetColor), brightness: brightness);
  }

  BorderRadius get mediumBorderRadius => BorderRadius.circular(8);

  ShapeBorder get shapeMedium => RoundedRectangleBorder(
        borderRadius: mediumBorderRadius,
      );

  TextTheme textTheme(ColorScheme colors) {
    final colorTheme = colors.brightness == Brightness.dark
        ? typography.white
        : typography.black;

    var avenirTheme = TextTheme(
      bodySmall: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.bodySmall?.color,
        wordSpacing: 0,
      ),
      bodyMedium: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.bodyMedium?.color,
        wordSpacing: 0,
      ),
      // Body Large is used for the markdown pages paragraphs
      bodyLarge: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.bodyLarge?.color,
        wordSpacing: 0,
      ),
      displayLarge: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.displayLarge?.color,
        wordSpacing: 0,
      ),
      displayMedium: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.displayMedium?.color,
        wordSpacing: 0,
      ),
      displaySmall: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.displaySmall?.color,
        wordSpacing: 0,
      ),
      // Used for the markdown pages title
      headlineLarge: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.headlineLarge?.color,
        wordSpacing: 0,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.headlineMedium?.color,
        wordSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.headlineSmall?.color,
        wordSpacing: 0,
        fontSize: 17.0,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.titleLarge?.color,
        wordSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.titleMedium?.color,
        wordSpacing: 0,
      ),
      titleSmall: TextStyle(
        fontFamily: "avenir",
        color: colorTheme.titleSmall?.color,
        wordSpacing: 0,
      ),
    );
    return avenirTheme;
  }

  Typography get typography => Typography.material2021();

  CardTheme cardTheme() {
    return const CardTheme();
  }

  ListTileThemeData listTileTheme(ColorScheme colors) {
    return const ListTileThemeData();
  }

  AppBarTheme appBarTheme(ColorScheme colors) {
    return AppBarTheme(
      shadowColor: Colors.black,
      toolbarHeight: 50,
      elevation: 3,
      scrolledUnderElevation: 3,
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    );
  }

  TabBarTheme tabBarTheme(ColorScheme colors) {
    return const TabBarTheme();
  }

  BottomAppBarTheme bottomAppBarTheme(ColorScheme colors) {
    return const BottomAppBarTheme();
  }

  BottomNavigationBarThemeData bottomNavigationBarTheme(ColorScheme colors) {
    return const BottomNavigationBarThemeData();
  }

  NavigationBarThemeData navigationBarTheme(ColorScheme colors) {
    return const NavigationBarThemeData();
  }

  NavigationRailThemeData navigationRailTheme(ColorScheme colors) {
    return const NavigationRailThemeData();
  }

  DrawerThemeData drawerTheme(ColorScheme colors) {
    return DrawerThemeData(
      elevation: 4,
      backgroundColor: colors.surface,
    );
  }

  ProgressIndicatorThemeData progressIndicatorTheme(ColorScheme colors) {
    return const ProgressIndicatorThemeData();
  }

  FloatingActionButtonThemeData floatingActionButtonTheme(ColorScheme colors) {
    return const FloatingActionButtonThemeData();
  }

  ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colors) {
    return ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ));
  }

  InputDecorationTheme inputDecorationTheme(ColorScheme colors) {
    return const InputDecorationTheme(border: OutlineInputBorder());
  }

  ButtonThemeData buttonTheme(ColorScheme colors) {
    return const ButtonThemeData();
  }

  TextButtonThemeData textButtonTheme(ColorScheme colors) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.onPrimaryContainer,
      ),
    );
  }

  IconThemeData iconTheme(ColorScheme colors) {
    return IconThemeData(
      color: colors.onBackground,
    );
  }

  PopupMenuThemeData popupMenuTheme(ColorScheme colors) {
    return const PopupMenuThemeData();
  }

  DividerThemeData dividerTheme(Color colour) {
    return DividerThemeData(
      color: colour.withOpacity(0.14),
      indent: 16,
      endIndent: 16,
      thickness: 1,
    );
  }

  DialogTheme dialogTheme(ColorScheme colors) {
    return DialogTheme(
      actionsPadding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      backgroundColor: colors.onSecondary,
      surfaceTintColor: colors.onSecondary,
      elevation: 3,
      shadowColor: colors.shadow.withOpacity(0.12),
    );
  }

  ThemeData light([Color? targetColor]) {
    final colorScheme = colors(Brightness.light, targetColor).copyWith(
      primary: Color.fromARGB(255, 64, 148, 61),
      background: const Color.fromRGBO(245, 245, 245, 1),
      onSurface: const Color.fromRGBO(0, 40, 80, 1),
      onSecondary: const Color.fromRGBO(255, 255, 255, 1),
      onInverseSurface: const Color.fromRGBO(0, 0, 0, 0.12),
    );
    return ThemeData.light().copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardTheme(),
      listTileTheme: listTileTheme(colorScheme),
      bottomAppBarTheme: bottomAppBarTheme(colorScheme),
      bottomNavigationBarTheme: bottomNavigationBarTheme(colorScheme),
      navigationBarTheme: navigationBarTheme(colorScheme),
      tabBarTheme: tabBarTheme(colorScheme),
      drawerTheme: drawerTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      progressIndicatorTheme: progressIndicatorTheme(colorScheme),
      floatingActionButtonTheme: floatingActionButtonTheme(colorScheme),
      inputDecorationTheme: inputDecorationTheme(colorScheme),
      buttonTheme: buttonTheme(colorScheme),
      textButtonTheme: textButtonTheme(colorScheme),
      elevatedButtonTheme: elevatedButtonTheme(colorScheme),
      popupMenuTheme: popupMenuTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: textTheme(colorScheme),
      iconTheme: iconTheme(colorScheme),
      typography: typography,
      dividerTheme: dividerTheme(Colors.black),
      dialogTheme: dialogTheme(colorScheme),
      useMaterial3: true,
    );
  }

  ThemeData dark([Color? targetColor]) {
    final colorScheme = colors(Brightness.dark, targetColor).copyWith(
      primary: const Color.fromRGBO(12, 64, 10, 1),
      background: const Color.fromRGBO(12, 64, 10, 1),
      onSecondary: darkCardColour,
      onSurface: const Color.fromRGBO(189, 201, 218, 1),
      onInverseSurface: const Color.fromRGBO(147, 166, 192, 0.38),
      onBackground: const Color.fromRGBO(255, 255, 255, 0.87),
    );
    return ThemeData.dark().copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardTheme(),
      listTileTheme: listTileTheme(colorScheme),
      bottomAppBarTheme: bottomAppBarTheme(colorScheme),
      bottomNavigationBarTheme: bottomNavigationBarTheme(colorScheme),
      navigationBarTheme: navigationBarTheme(colorScheme),
      tabBarTheme: tabBarTheme(colorScheme),
      drawerTheme: drawerTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      progressIndicatorTheme: progressIndicatorTheme(colorScheme),
      floatingActionButtonTheme: floatingActionButtonTheme(colorScheme),
      inputDecorationTheme: inputDecorationTheme(colorScheme),
      buttonTheme: buttonTheme(colorScheme),
      textButtonTheme: textButtonTheme(colorScheme),
      elevatedButtonTheme: elevatedButtonTheme(colorScheme),
      popupMenuTheme: popupMenuTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: textTheme(colorScheme),
      iconTheme: iconTheme(colorScheme),
      typography: typography,
      dividerTheme: dividerTheme(Colors.white),
      dialogTheme: dialogTheme(colorScheme),
      useMaterial3: true,
    );
  }

  ThemeMode themeMode() {
    return settings.value.themeMode;
  }

  ThemeData theme(BuildContext context, [Color? targetColor]) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? light(targetColor)
        : dark(targetColor);
  }

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(covariant ThemeProvider oldWidget) {
    return oldWidget.settings != settings;
  }
}

Color randomColor() {
  return Color(Random().nextInt(0xFFFFFFFF));
}

// Colour of the Entelect logo
const entelectColor = Color.fromRGBO(12, 64, 10, 1);

// Entelect Green colour
const entelectGreen = Color.fromRGBO(109, 170, 35, 1);

// Colour used by cards in dark mode
const darkCardColour = Color.fromRGBO(42, 42, 59, 1);

// Colour of input field icons
const greyIconColour = Color.fromRGBO(152, 152, 152, 1);

// Colours of email interactive links
const darkEmailColour = Color.fromRGBO(189, 201, 218, 1);
const lightEmailColour = Color.fromRGBO(12, 64, 10, 1);

// Colour used by check boxes
const greenAccentColour = Color.fromRGBO(109, 170, 35, 1);

// Box shadow used for light theme cards
List<BoxShadow> lightCardBoxShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.07),
    blurRadius: 5,
    offset: const Offset(0, 4),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 10,
    offset: const Offset(0, 1),
  ),
];

// Box shadow used for dark theme cards
List<BoxShadow> darkCardBoxShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.14),
    blurRadius: 5,
    offset: const Offset(0, 4),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 10,
    offset: const Offset(0, 1),
  ),
];

// Box shadow used for light theme forms
List<BoxShadow> lightFormBoxShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.14),
    blurRadius: 4,
    offset: const Offset(0, 2),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 4,
    offset: const Offset(0, 3),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 5,
    offset: const Offset(0, 1),
  ),
];

// Box shadow used for dark theme forms
List<BoxShadow> darkFormBoxShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.14),
    blurRadius: 4,
    offset: const Offset(0, -2),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 4,
    offset: const Offset(0, -3),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 5,
    offset: const Offset(0, -1),
  ),
];

TextStyle dialogActionTextStyle(ColorScheme colorScheme) {
  return TextStyle(
    color: colorScheme.onSurface,
    fontSize: 14,
    fontFamily: 'avenir',
    fontWeight: FontWeight.w900,
  );
}
