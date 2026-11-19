import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart'; // gerado por `flutterfire configure`
import 'game_page.dart';
import 'l10n/app_localizations.dart';
import 'login_page.dart';
import 'progress_page.dart';
import 'providers.dart';
import 'settings_page.dart';
import 'shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  await FirebaseAuth.instance.authStateChanges().first; // espera restaurar a sessão
  runApp(ProviderScope(overrides: [prefsProvider.overrideWithValue(prefs)], child: const EmplakeApp()));
}

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
  late final StreamSubscription<User?> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class EmplakeApp extends ConsumerStatefulWidget {
  const EmplakeApp({super.key});
  @override
  ConsumerState<EmplakeApp> createState() => _EmplakeAppState();
}

class _EmplakeAppState extends ConsumerState<EmplakeApp> {
  late final GoRouter _router;
  late final SharedPreferences _prefs;

  String get _lastRoute {
    final saved = _prefs.getString('lastRoute');
    return kTabs.contains(saved) ? saved! : '/game';
  }

  @override
  void initState() {
    super.initState();
    _prefs = ref.read(prefsProvider);
    _router = GoRouter(
      initialLocation: _lastRoute, // reabre na última página
      refreshListenable: _AuthRefresh(),
      redirect: (context, state) {
        final logged = FirebaseAuth.instance.currentUser != null;
        final loc = state.matchedLocation;
        if (!logged) return loc == '/login' ? null : '/login';
        if (loc == '/login') return _lastRoute;
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        ShellRoute(
          builder: (_, state, child) => AppShell(location: state.matchedLocation, child: child),
          routes: [
            GoRoute(path: '/game', pageBuilder: (_, _) => const NoTransitionPage(child: GamePage())),
            GoRoute(path: '/progress', pageBuilder: (_, _) => const NoTransitionPage(child: ProgressPage())),
            GoRoute(path: '/settings', pageBuilder: (_, _) => const NoTransitionPage(child: SettingsPage())),
          ],
        ),
      ],
    );
    _router.routerDelegate.addListener(() {
      final p = _router.routerDelegate.currentConfiguration.uri.path;
      if (kTabs.contains(p)) _prefs.setString('lastRoute', p);
    });
  }

  ThemeData _theme(SettingsState s, Brightness b) {
    final base = ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(s.seed), brightness: b));
    return base.copyWith(textTheme: GoogleFonts.getTextTheme(s.font, base.textTheme));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    return MaterialApp.router(
      routerConfig: _router,
      onGenerateTitle: (c) => AppLocalizations.of(c)!.appTitle,
      locale: s.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FirebaseUILocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: s.mode, // padrão: ThemeMode.system
      theme: _theme(s, Brightness.light),
      darkTheme: _theme(s, Brightness.dark),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(s.scale)),
        // ignore: deprecated_member_use
        child: MaterialUiCompatibilityBridge(child: child!),
      ),
    );
  }
}