import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'widgets.dart';

class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});
  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> {
  late final Future<Progress> _future = ref.read(repoProvider).load(FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    return FutureBuilder<Progress>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const Loader();
        if (snap.hasError) return Center(child: Text(l.loadError('${snap.error}')));
        final p = snap.data!;
        final solved = [...p.solved]..sort();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l.progressTitle, style: tt.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Card(child: ListTile(leading: const Icon(Icons.emoji_events), title: Text(l.scoreLabel(p.score), style: tt.titleLarge))),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.solvedCount(solved.length), style: tt.titleMedium),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: solved.length / 9000, minHeight: 8, borderRadius: BorderRadius.circular(8)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (solved.isEmpty)
                    Text(l.noneSolved, textAlign: TextAlign.center)
                  else
                    Wrap(spacing: 6, runSpacing: 6, children: [for (final n in solved) Chip(label: Text('$n'))]),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}