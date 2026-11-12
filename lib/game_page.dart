import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'engine.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'widgets.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return FutureBuilder<int?>(
      future: ref.watch(numberProvider),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const Loader();
        if (snap.hasError) {
          return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l.loadError('${snap.error}')),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => ref.invalidate(numberProvider), child: Text(l.retry)),
          ]));
        }
        final n = snap.data;
        if (n == null) {
          return Center(child: Text(l.allSolved, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall));
        }
        return _Playfield(key: ValueKey(n), number: n);
      },
    );
  }
}

class _Playfield extends ConsumerStatefulWidget {
  final int number;
  const _Playfield({super.key, required this.number});
  @override
  ConsumerState<_Playfield> createState() => _PlayfieldState();
}

class _PlayfieldState extends ConsumerState<_Playfield> {
  String? _msg;
  bool _busy = false;
  bool _launching = false;

  static const _planetColors = [
    [Color(0xFFFFB74D), Color(0xFFE65100)],
    [Color(0xFF4FC3F7), Color(0xFF01579B)],
    [Color(0xFFBA68C8), Color(0xFF4A148C)],
    [Color(0xFF81C784), Color(0xFF1B5E20)],
  ];

  String _errText(AppLocalizations l, GameErrorKind k) => switch (k) {
        GameErrorKind.syntax => l.errSyntax,
        GameErrorKind.noEq => l.errNoEq,
        GameErrorKind.divInt => l.errDivInt,
        GameErrorKind.divZero => l.errDivZero,
        GameErrorKind.domain => l.errDomain,
      };

  void _setLevel(Level v) {
    ref.read(levelProvider.notifier).set(v);
    ref.read(boardProvider.notifier).clear();
    setState(() => _msg = null);
  }

  Future<void> _returnAndClear() async {
    ref.read(boardProvider.notifier).startReturn(); // fichas voltam para a paleta
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    ref.read(boardProvider.notifier).clear();
  }

  Future<void> _check(List<String> tokens, Level level) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _msg = null;
    });
    try {
      final r = evaluateEquation(tokens, level);
      if (r.ok) {
        await ref.read(repoProvider).markSolved(FirebaseAuth.instance.currentUser!.uid, widget.number, level.points);
        if (!mounted) return;
        playSfx(ref, Sfx.success);
        messenger.showSnackBar(SnackBar(content: Text(l.correct(level.points))));
        ref.read(boardProvider.notifier).startReturn();
        setState(() => _launching = true); // foguete decola!
        playSfx(ref, Sfx.launch);
        await Future.delayed(const Duration(milliseconds: 950));
        if (!mounted) return;
        ref.read(numberProvider.notifier).next();
      } else {
        playSfx(ref, Sfx.error);
        setState(() => _msg = l.notEqual(fmtNum(r.left), fmtNum(r.right)));
        await _returnAndClear();
      }
    } on GameError catch (e) {
      if (!mounted) return;
      playSfx(ref, Sfx.error);
      setState(() => _msg = _errText(l, e.kind));
    } catch (e) {
      if (mounted) setState(() => _msg = l.loadError('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final level = ref.watch(levelProvider);
    final board = ref.watch(boardProvider);
    final notifier = ref.read(boardProvider.notifier);
    final digits = widget.number.toString().padLeft(4, '0').split('');
    final tokens = flatten(board.slots, digits);
    final tex = buildLatex(tokens);

    Widget panel(Widget child) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: .6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.primary.withValues(alpha: .35)),
          ),
          child: child,
        );

    final header = Column(children: [
      Wrap(spacing: 8, alignment: WrapAlignment.center, children: [
        for (final v in Level.values)
          ChoiceChip(label: Text(levelName(l, v)), selected: v == level, onSelected: (_) => _setLevel(v)),
      ]),
      const SizedBox(height: 16),
      Text(l.yourNumber, style: tt.labelLarge),
      Text(digits.join(),
          style: GoogleFonts.orbitron(fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: 10, color: cs.onSurface)),
    ]);

    // Rota: doca, planeta, doca, planeta ... doca
    // Tudo numa linha só: se ficar largo demais, a rota inteira encolhe para caber.
    final route = panel(Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < 5; i++) ...[
              _dock(i, board, notifier, cs),
              if (i < 4) ...[
                const SizedBox(width: 6),
                _Floating(index: i, child: _planet(digits[i], i)),
                const SizedBox(width: 6),
              ],
            ],
          ],
        ),
      ),
    ));

    final latexPanel = panel(Column(children: [
      Text(l.formulaLatex, style: tt.labelMedium),
      const SizedBox(height: 8),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: tex == null
            ? Text(l.latexPending, style: tt.bodyMedium?.copyWith(color: cs.outline))
            : Math.tex(tex, textStyle: TextStyle(fontSize: 26, color: cs.onSurface), onErrorFallback: (_) => Text(tex)),
      ),
    ]));

    final palette = panel(Column(children: [
      Text(l.tapSlotHint, textAlign: TextAlign.center, style: tt.bodySmall),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
        for (final t in level.tokens)
          FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: const Size(56, 48)),
            onPressed: (t == '=' && board.hasEq)
                ? null
                : () {
                    notifier.add(t);
                    playSfx(ref, Sfx.click);
                  },
            child: Text(tokenLabel(t), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
      ]),
    ]));

    final actions = Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [
      FilledButton.icon(
          onPressed: _busy ? null : () => _check(tokens, level), icon: const Icon(Icons.rocket_launch), label: Text(l.check)),
      OutlinedButton.icon(onPressed: _busy ? null : _returnAndClear, icon: const Icon(Icons.restart_alt), label: Text(l.clear)),
      TextButton.icon(
          onPressed: _busy ? null : () => ref.read(numberProvider.notifier).next(skip: widget.number),
          icon: const Icon(Icons.skip_next),
          label: Text(l.skip)),
    ]);

    final message = _msg == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Card(
                color: cs.errorContainer,
                child: Padding(padding: const EdgeInsets.all(12), child: Text(_msg!, style: TextStyle(color: cs.onErrorContainer)))),
          );

    const gap = SizedBox(height: 20);
    return Stack(fit: StackFit.expand, children: [
      LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final left = [header, gap, route, gap, latexPanel, message];
        final right = [palette, gap, actions];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: wide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 3, child: Column(children: left)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: Column(children: right)),
                    ])
                  : Column(children: [...left, gap, ...right]),
            ),
          ),
        );
      }),
      if (_launching) const _RocketLaunch(),
    ]);
  }

  Widget _planet(String d, int i) {
    final p = _planetColors[i % 4];
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(center: const Alignment(-.4, -.4), colors: p),
        boxShadow: [BoxShadow(color: p[0].withValues(alpha: .5), blurRadius: 14, spreadRadius: 1)],
      ),
      child: Text(d, style: GoogleFonts.orbitron(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _dock(int i, BoardState board, BoardNotifier n, ColorScheme cs) {
    final sel = board.selected == i;
    final toks = board.slots[i];
    return InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: () => n.select(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: sel ? cs.primaryContainer.withValues(alpha: .8) : cs.surfaceContainerHighest.withValues(alpha: .35),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: sel ? cs.primary : cs.outlineVariant, width: sel ? 2 : 1),
          boxShadow: sel ? [BoxShadow(color: cs.primary.withValues(alpha: .6), blurRadius: 14)] : null,
        ),
        child: toks.isEmpty
            ? Icon(Icons.add, size: 16, color: cs.outline)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                for (var k = 0; k < toks.length; k++)
                  _TokenChip(
                    key: ValueKey('$i-$k-${toks[k]}'),
                    label: tokenLabel(toks[k]),
                    returning: board.returning,
                    onTap: () => n.removeAt(i, k),
                  ),
              ]),
      ),
    );
  }
}

/// Planeta flutuando suavemente (cada um com uma fase diferente).
class _Floating extends StatefulWidget {
  final int index;
  final Widget child;
  const _Floating({required this.index, required this.child});
  @override
  State<_Floating> createState() => _FloatingState();
}

class _FloatingState extends State<_Floating> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3), value: (widget.index * .27) % 1)..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.translate(offset: Offset(0, -5 + 10 * Curves.easeInOut.transform(_c.value)), child: child),
        child: widget.child,
      );
}

/// Ficha: aparece com "pop" e, ao verificar, desliza para baixo e some.
class _TokenChip extends StatelessWidget {
  final String label;
  final bool returning;
  final VoidCallback onTap;
  const _TokenChip({super.key, required this.label, required this.returning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .4, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: AnimatedSlide(
        offset: returning ? const Offset(0, 3) : Offset.zero,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
        child: AnimatedOpacity(
          opacity: returning ? 0 : 1,
          duration: const Duration(milliseconds: 400),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 32),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.primary.withValues(alpha: .6)),
              ),
              child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSecondaryContainer)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Foguete que decola ao acertar a equação.
class _RocketLaunch extends StatelessWidget {
  const _RocketLaunch();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeIn,
        builder: (_, v, __) => Align(
          alignment: Alignment(0, 1.1 - 2.6 * v),
          child: Opacity(
            opacity: 1 - v * .4,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Transform.rotate(angle: -math.pi / 4, child: Icon(Icons.rocket_launch, size: 80, color: cs.primary)),
              const Icon(Icons.local_fire_department, size: 40, color: Colors.orange),
            ]),
          ),
        ),
      ),
    );
  }
}