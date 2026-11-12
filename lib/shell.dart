import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/app_localizations.dart';
import 'music.dart';
import 'widgets.dart';

const kTabs = ['/game', '/progress', '/settings'];

void showHelp(BuildContext context) {
  final l = AppLocalizations.of(context)!;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.help_outline),
      title: Text(l.helpTitle),
      content: SingleChildScrollView(child: Text(l.helpBody)),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.close))],
    ),
  );
}

class AppShell extends ConsumerStatefulWidget {
  final String location;
  final Widget child;
  const AppShell({super.key, required this.location, required this.child});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _navKey = GlobalKey<CurvedNavigationBarState>();

  int get _index {
    final i = kTabs.indexWhere((p) => widget.location.startsWith(p));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    Widget item(IconData i, String tip) => Tooltip(message: tip, child: Icon(i, color: cs.onPrimary));
    return Scaffold(
      extendBody: true,
      body: Listener(
        // Navegadores só liberam áudio depois de um toque: se a música estava ligada, ela começa aqui.
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => ref.read(musicProvider.notifier).resumeIfNeeded(),
        child: SpaceBackground(child: SafeArea(child: widget.child)),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _navKey,
        index: _index,
        height: 60,
        backgroundColor: Colors.transparent,
        color: cs.primary,
        buttonBackgroundColor: cs.primary,
        items: [
          item(Icons.rocket_launch, l.navGame),
          item(Icons.insights, l.navProgress),
          item(Icons.settings, l.navSettings),
          item(Icons.help_outline, l.navHelp),
        ],
        onTap: (i) {
          if (i == 3) {
            showHelp(context);
            _navKey.currentState?.setPage(_index);
          } else {
            context.go(kTabs[i]);
          }
        },
      ),
    );
  }
}