import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lost_pet/firebase_options.dart';
import 'package:lost_pet/src/services/authentication_service.dart';
import 'package:lost_pet/src/services/pets_service.dart';
import 'package:lost_pet/src/services/theme.dart';
import 'package:lost_pet/src/services/user_provider.dart';
import 'package:lost_pet/src/views/home_screens/home_screen.dart';
import 'package:lost_pet/src/views/login_screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: 'lost-pet',
  );
  await _initializeServices();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  // Get the saved user preferences
  final prefs = await SharedPreferences.getInstance();
  EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences(prefs: prefs);
  SharedPreferences instance = await encryptedSharedPreferences.getInstance();
  final rememberMe = instance.getBool('rememberMe') ?? false;

  runApp(MyApp(
    rememberMe: rememberMe,
  ));
}

Future _initializeServices() async {
  await UserProvider.initialise(FirebaseAuth.instance);
  await LostPetsService.initialise();
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.rememberMe});
  final settings = ValueNotifier(
      ThemeSettings(sourceColor: entelectColor, themeMode: ThemeMode.system));
  final AuthenticationService authenticationService = AuthenticationService();
  final bool rememberMe;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      settings: settings,
      child: NotificationListener<ThemeSettingsChange>(
        onNotification: (notification) {
          settings.value = notification.settings;
          return true;
        },
        child: ValueListenableBuilder<ThemeSettings>(
          valueListenable: settings,
          builder: (context, value, _) {
            final theme = ThemeProvider.of(context);
            return _buildMaterialApp(theme);
          },
        ),
      ),
    );
  }

  Widget _determineChildToShow() {
    if (rememberMe && authenticationService.isUserLoggedIn) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }

  SkeletonTheme _buildMaterialApp(ThemeProvider theme) {
    // Determines the theme for all the skeleton elements
    return SkeletonTheme(
      // dark theme
      darkShimmerGradient: const LinearGradient(
        colors: [
          Color.fromRGBO(66, 73, 93, 1),
          Color.fromRGBO(58, 64, 82, 1),
          Color.fromRGBO(50, 55, 70, 1),
          Color.fromRGBO(58, 64, 82, 1),
          Color.fromRGBO(66, 73, 93, 1),
        ],
        stops: [0.0, 0.2, 0.5, 0.8, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      //  light theme
      shimmerGradient: const LinearGradient(
        colors: [
          Color.fromRGBO(223, 231, 234, 1),
          Color.fromRGBO(212, 222, 226, 1),
          Color.fromRGBO(200, 213, 218, 1),
          Color.fromRGBO(212, 222, 226, 1),
          Color.fromRGBO(223, 231, 234, 1),
        ],
        stops: [0.0, 0.2, 0.5, 0.8, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: MaterialApp(
        title: 'Lost Pet',
        debugShowCheckedModeBanner: false,
        restorationScopeId: 'app',
        theme: theme.light(settings.value.sourceColor),
        darkTheme: theme.dark(settings.value.sourceColor),
        builder: (context, child) => Overlay(
          initialEntries: [
            if (child != null) OverlayEntry(builder: (context) => child),
          ],
        ),
        home: _determineChildToShow(),
      ),
    );
  }
}
