import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/ad_service.dart';
import 'state/game_provider.dart';
import 'state/settings_provider.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const SafarEJannahApp(),
    ),
  );
  // Do not hold the first Flutter frame until the Mobile Ads SDK finishes
  // initializing. The launch screen can otherwise remain blank on slow devices.
  unawaited(AdService.instance.initialize());
}

class SafarEJannahApp extends StatelessWidget {
  const SafarEJannahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: settings.isBangla
              ? 'সফর-এ-জান্নাত: সিরাতুল মুস্তাকীম'
              : 'Safar-e-Jannah: Sirat-ul-Mustaqeem',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF090D16),
            primaryColor: const Color(0xFF10B981),
            textTheme: GoogleFonts.hindSiliguriTextTheme(
              ThemeData.dark().textTheme,
            ).apply(
              decoration: TextDecoration.none,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleTextStyle: TextStyle(decoration: TextDecoration.none),
              contentTextStyle: TextStyle(decoration: TextDecoration.none),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF10B981),
              secondary: Color(0xFFF59E0B),
              surface: Color(0xFF0F172A),
              error: Color(0xFFEF4444),
            ),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
