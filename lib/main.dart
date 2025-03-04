import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';

import '../../common/theme/paisa_theme.dart';
import 'app/app_builder.dart';
import 'app/routes.dart';
import 'common/enum/box_types.dart';
import 'data/settings/settings_service.dart';
import 'di/service_locator.dart';
import 'presentation/home/bloc/home_bloc.dart';

late String currentLocale;
Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final settings = Hive.box(BoxType.settings.stringValue).listenable(
    keys: [
      appColorKey,
      dynamicColorKey,
      themeModeKey,
    ],
  );
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: settings,
      builder: (BuildContext context, Box<dynamic> value, Widget? child) {
        final isDynamic = value.get(dynamicColorKey, defaultValue: true);
        final themeModeValue = value.get(themeModeKey, defaultValue: 0);
        final color = value.get(appColorKey, defaultValue: 0xFF795548);
        final primaryColor = Color(color);
        return AppBuilder(
          builder: (context) {
            return DynamicColorBuilder(
              builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                ColorScheme lightColorScheme;
                ColorScheme darkColorScheme;
                if (lightDynamic != null && darkDynamic != null && isDynamic) {
                  lightColorScheme = lightDynamic.harmonized();
                  darkColorScheme = darkDynamic.harmonized();
                } else {
                  lightColorScheme = ColorScheme.fromSeed(
                    seedColor: primaryColor,
                  );
                  darkColorScheme = ColorScheme.fromSeed(
                    seedColor: primaryColor,
                    brightness: Brightness.dark,
                  );
                }

                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => locator.get<HomeBloc>()),
                  ],
                  child: MaterialApp.router(
                    routeInformationProvider: goRouter.routeInformationProvider,
                    routeInformationParser: goRouter.routeInformationParser,
                    routerDelegate: goRouter.routerDelegate,
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData.light().copyWith(
                      colorScheme: lightColorScheme,
                      dialogTheme: dialogTheme(),
                      appBarTheme: appBarTheme(Brightness.dark),
                      useMaterial3: true,
                      textTheme: GoogleFonts.outfitTextTheme(
                        ThemeData.light().textTheme,
                      ),
                      scaffoldBackgroundColor: lightColorScheme.background,
                      dialogBackgroundColor: lightColorScheme.background,
                      navigationBarTheme: navigationBarThemeData,
                      applyElevationOverlayColor: true,
                      inputDecorationTheme: inputDecorationTheme,
                      elevatedButtonTheme: elevatedButtonTheme(
                        context,
                        lightColorScheme,
                      ),
                      extensions: [lightCustomColor],
                    ),
                    darkTheme: ThemeData.dark().copyWith(
                      colorScheme: darkColorScheme,
                      dialogTheme: dialogTheme(),
                      appBarTheme: appBarTheme(Brightness.light),
                      useMaterial3: true,
                      textTheme: GoogleFonts.outfitTextTheme(
                        ThemeData.dark().textTheme,
                      ),
                      scaffoldBackgroundColor: darkColorScheme.background,
                      dialogBackgroundColor: darkColorScheme.background,
                      navigationBarTheme: navigationBarThemeData,
                      applyElevationOverlayColor: true,
                      inputDecorationTheme: inputDecorationTheme,
                      elevatedButtonTheme: elevatedButtonTheme(
                        context,
                        darkColorScheme,
                      ),
                      extensions: [darkCustomColor],
                    ),
                    themeMode: ThemeMode.values[themeModeValue],
                    localizationsDelegates: const [
                      AppLocalizations.delegate, // Add this line
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en', ''),
                    ],
                    onGenerateTitle: (BuildContext context) =>
                        AppLocalizations.of(context)!.appTitle,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
