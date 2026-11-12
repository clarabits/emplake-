import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
// O formulário do firebase_ui_auth usa o Material ANTIGO; por isso o tema dele é aplicado com o prefixo `old`.
import 'package:flutter/material.dart' as old;
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/app_localizations.dart';
import 'widgets.dart';

// Client ID OAuth "Web" (Firebase > Authentication > Google > Configuração do SDK da Web).
const kGoogleClientId = '189261562553-t1seputc71gcsguib802tsu9d16brfn2.apps.googleusercontent.com';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget brand(double iconSize, double titleSize) => Column(mainAxisSize: MainAxisSize.min, children: [
          _Bob(
            child: Container(
              padding: EdgeInsets.all(iconSize * .3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [cs.primary.withValues(alpha: .35), Colors.transparent]),
              ),
              child: Icon(Icons.rocket_launch, size: iconSize, color: cs.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(l.appTitle.toUpperCase(),
              style: GoogleFonts.orbitron(fontSize: titleSize, fontWeight: FontWeight.w800, letterSpacing: 6, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(l.loginTagline, textAlign: TextAlign.center, style: tt.bodyMedium),
        ]);

    // Campos arredondados e botões em pílula, combinando com o tema espacial.
    final fieldBorder = old.OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cs.primary.withValues(alpha: .35)));
    final themed = old.Theme.of(context).copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      inputDecorationTheme: old.InputDecorationThemeData(
        filled: true,
        fillColor: cs.surface.withValues(alpha: .55),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: old.OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cs.primary, width: 2)),
      ),
      outlinedButtonTheme: old.OutlinedButtonThemeData(
        style: old.OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          side: BorderSide(color: cs.primary),
          backgroundColor: cs.primary.withValues(alpha: .14),
        ),
      ),
      filledButtonTheme: old.FilledButtonThemeData(
        style: old.FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder()),
      ),
    );

    return Scaffold(
      body: SpaceBackground(
        child: Stack(fit: StackFit.expand, children: [
          // Planetas decorativos atrás do formulário.
          IgnorePointer(
            child: Stack(children: [
              Positioned(left: -70, bottom: -60, child: Opacity(opacity: .75, child: _Bob(child: _ringedPlanet(260)))),
              Positioned(right: 40, top: 40, child: _Bob(child: _planet(54, const [Color(0xFF4FC3F7), Color(0xFF01579B)]))),
              Positioned(right: 130, bottom: 70, child: _Bob(child: _planet(30, const [Color(0xFFFFB74D), Color(0xFFE65100)]))),
              Positioned(left: 60, top: 70, child: _Bob(child: _planet(22, const [Color(0xFFBA68C8), Color(0xFF4A148C)]))),
            ]),
          ),
          old.Theme(
            data: themed,
            child: SignInScreen(
              providers: [EmailAuthProvider(), GoogleProvider(clientId: kGoogleClientId)],
              headerBuilder: (context, constraints, _) => Padding(padding: const EdgeInsets.all(20), child: brand(48, 28)),
              sideBuilder: (context, constraints) => Center(child: Padding(padding: const EdgeInsets.all(24), child: brand(88, 42))),
              footerBuilder: (context, _) => Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(children: [
                  Text(l.language, style: tt.labelMedium),
                  const SizedBox(height: 6),
                  const LanguagePicker(),
                  const SizedBox(height: 16),
                  Text(l.groupLabel, textAlign: TextAlign.center, style: tt.bodySmall),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

Widget _planet(double size, List<Color> c) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(center: const Alignment(-.4, -.4), colors: c),
        boxShadow: [BoxShadow(color: c[0].withValues(alpha: .5), blurRadius: size / 3)],
      ),
    );

/// Planeta com anel (estilo Saturno), desenhado só com containers.
Widget _ringedPlanet(double size) => SizedBox(
      width: size,
      height: size * .7,
      child: Stack(alignment: Alignment.center, children: [
        _planet(size * .6, const [Color(0xFFFFE082), Color(0xFFEF6C00)]),
        Transform.rotate(
          angle: -.35,
          child: Container(
            width: size,
            height: size * .26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.elliptical(size / 2, size * .13)),
              border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: .7), width: 5),
            ),
          ),
        ),
      ]),
    );

/// Balanço suave para cima e para baixo (os objetos "flutuando").
class _Bob extends StatefulWidget {
  final Widget child;
  const _Bob({required this.child});
  @override
  State<_Bob> createState() => _BobState();
}

class _BobState extends State<_Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.translate(offset: Offset(0, -6 + 12 * Curves.easeInOut.transform(_c.value)), child: child),
        child: widget.child,
      );
}