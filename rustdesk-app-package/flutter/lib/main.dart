import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'mobile/pages/home_page.dart';
import 'mobile/pages/connection_page.dart';
import 'mobile/pages/remote_page.dart';
import 'mobile/pages/settings_page.dart';
import 'mobile/pages/server_page.dart';
import 'common/theme.dart';
import 'common/constants.dart';
import 'services/ai_service.dart';
import 'services/connection_service.dart';

void main() {
  runApp(const RustDeskApp());
}

class RustDeskApp extends StatelessWidget {
  const RustDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AIService()),
        ChangeNotifierProvider(create: (_) => ConnectionService()),
        ChangeNotifierProvider(create: (_) => AppSettings()),
      ],
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                title: APP_NAME,
                debugShowCheckedModeBanner: false,
                theme: themeProvider.lightTheme.copyWith(
                  colorScheme: lightDynamic ?? themeProvider.lightTheme.colorScheme,
                ),
                darkTheme: themeProvider.darkTheme.copyWith(
                  colorScheme: darkDynamic ?? themeProvider.darkTheme.colorScheme,
                ),
                themeMode: themeProvider.themeMode,
                initialRoute: HOME_ROUTE,
                routes: {
                  HOME_ROUTE: (context) => const HomePage(),
                  CONNECTION_ROUTE: (context) => const ConnectionPage(),
                  REMOTE_ROUTE: (context) => const RemotePage(),
                  SETTINGS_ROUTE: (context) => const SettingsPage(),
                  SERVER_ROUTE: (context) => const ServerPage(),
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class AppSettings extends ChangeNotifier {
  bool _aiEnabled = true;
  bool _offlineAI = false;
  bool _customTheme = true;
  bool _gestureOptimization = true;

  bool get aiEnabled => _aiEnabled;
  bool get offlineAI => _offlineAI;
  bool get customTheme => _customTheme;
  bool get gestureOptimization => _gestureOptimization;

  void toggleAI(bool value) {
    _aiEnabled = value;
    notifyListeners();
  }

  void toggleOfflineAI(bool value) {
    _offlineAI = value;
    notifyListeners();
  }

  void toggleCustomTheme(bool value) {
    _customTheme = value;
    notifyListeners();
  }

  void toggleGestureOptimization(bool value) {
    _gestureOptimization = value;
    notifyListeners();
  }
}