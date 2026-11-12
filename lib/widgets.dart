import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'engine.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'sfx.dart';

export 'sfx.dart' show Sfx;

/// Indicador de progresso customizado (não é o CircularProgressIndicator padrão).
class Loader extends StatelessWidget {
  const Loader({super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Theme.of(context).colorScheme.primary, size: 56));
}

String tokenLabel(String t) => switch (t) {
      'sqrt(' => '√(',
      'cbrt(' => '∛(',
      _ => t,
    };

String levelName(AppLocalizations l, Level v) => switch (v) {
      Level.easy => l.levelEasy,
      Level.medium => l.levelMedium,
      Level.advanced => l.levelAdvanced,
      Level.hard => l.levelHard,
    };

/// Som opcional: só toca se o usuário ligou em Configurações.
void playSfx(WidgetRef ref, Sfx sfx) {
  if (!ref.read(settingsProvider).sound) return;
  SfxPlayer.play(sfx);
}

/// Seletor de idioma com bandeirinhas. Funciona na tela de login e nas configurações.
class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = Localizations.localeOf(context).languageCode == 'pt' ? 'pt' : 'en';

    Widget chip(String value, String label) => ChoiceChip(
          label: Text(label, maxLines: 1, softWrap: false),
          selected: code == value,
          onSelected: (_) => ref.read(settingsProvider.notifier).setLocale(Locale(value)),
        );

    return Material(
      type: MaterialType.transparency,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          chip('pt', '🇧🇷 Português'),
          chip('en', '🇺🇸 English'),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ Fundo espacial
class _Star {
  final double x, y, r, phase;
  final int k;
  _Star(this.x, this.y, this.r, this.phase, this.k);
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  final Color color;
  final double maxAlpha;
  _StarPainter(this.stars, this.t, this.color, this.maxAlpha);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final a = (.2 + .6 * (.5 + .5 * sin(2 * pi * (t * s.k + s.phase)))) * maxAlpha;
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.r, Paint()..color = color.withValues(alpha: a));
    }
    // Estrela cadente: cruza o céu uma vez a cada ciclo da animação.
    final p = (t - .15) / .12;
    if (p >= 0 && p <= 1) {
      final dx = size.width * .5, dy = size.height * .35;
      final len = sqrt(dx * dx + dy * dy);
      final head = Offset(size.width * (.1 + .5 * p), size.height * (.08 + .35 * p));
      for (var i = 0; i < 10; i++) {
        final pos = head - Offset(dx / len, dy / len) * (i * 9.0);
        canvas.drawCircle(pos, 2.4 - i * .2, Paint()..color = color.withValues(alpha: (1 - i / 10) * maxAlpha));
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.t != t || old.color != color;
}

/// Céu com gradiente e estrelas que cintilam. Acompanha o tema claro/escuro.
class SpaceBackground extends StatefulWidget {
  final Widget child;
  const SpaceBackground({super.key, required this.child});
  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  late final List<_Star> _stars = () {
    final rnd = Random(7);
    return List.generate(
        110, (_) => _Star(rnd.nextDouble(), rnd.nextDouble(), rnd.nextDouble() * 1.4 + .5, rnd.nextDouble(), rnd.nextInt(3) + 1));
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget blob(Alignment a, Color c) => Align(
          alignment: a,
          child: Container(
            width: 460,
            height: 460,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [c.withValues(alpha: dark ? .24 : .16), Colors.transparent]),
            ),
          ),
        );
    return Stack(children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? const [Color(0xFF05060F), Color(0xFF111033), Color(0xFF1B1346)]
                  : const [Color(0xFFEEF0FF), Color(0xFFDDE3FF), Color(0xFFF3E8FF)],
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: Stack(children: [
            blob(const Alignment(-1.1, -.8), const Color(0xFF7C4DFF)),
            blob(const Alignment(1.1, .1), const Color(0xFF00B0FF)),
            blob(const Alignment(-.2, 1.2), const Color(0xFFFF4081)),
          ]),
        ),
      ),
      Positioned.fill(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              painter: _StarPainter(_stars, _c.value, dark ? Colors.white : const Color(0xFF3F3D8F), dark ? 1 : .5),
            ),
          ),
        ),
      ),
      widget.child,
    ]);
  }
}