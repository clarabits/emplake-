import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/app_localizations.dart';
import 'music.dart';
import 'providers.dart';
import 'widgets.dart';

const kFonts = ['Exo 2', 'Orbitron', 'Roboto', 'EB Garamond', 'Lato', 'Merriweather', 'Open Sans', 'Nunito', 'Fira Code'];
const kSeeds = [0xFF3F51B5, 0xFF009688, 0xFFE91E63, 0xFFFF9800, 0xFF4CAF50, 0xFF9C27B0, 0xFF795548, 0xFF607D8B, 0xFFF44336, 0xFF00BCD4];

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final music = ref.watch(musicProvider);
    final tt = Theme.of(context).textTheme;
    Widget title(String t) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: Text(t, style: tt.titleMedium));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.settingsTitle, style: tt.headlineMedium),
              title(l.themeMode),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.brightness_auto), label: Text(l.themeSystem)),
                  ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode), label: Text(l.themeLight)),
                  ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode), label: Text(l.themeDark)),
                ],
                selected: {s.mode},
                onSelectionChanged: (v) => n.setMode(v.first),
              ),
              title(l.fontSize),
              Slider(min: .8, max: 1.6, divisions: 8, value: s.scale, label: '${(s.scale * 100).round()}%', onChanged: n.setScale),
              title(l.fontFamily),
              DropdownButton<String>(
                value: s.font,
                items: [for (final f in kFonts) DropdownMenuItem(value: f, child: Text(f, style: GoogleFonts.getFont(f)))],
                onChanged: (v) => v == null ? null : n.setFont(v),
              ),
              title(l.seedColor),
              Wrap(spacing: 10, runSpacing: 10, children: [
                for (final c in kSeeds)
                  GestureDetector(
                    onTap: () => n.setSeed(c),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(width: 3, color: s.seed == c ? Theme.of(context).colorScheme.onSurface : Colors.transparent),
                      ),
                      child: s.seed == c ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  ),
              ]),
              title(l.language),
              const LanguagePicker(),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.library_music),
                title: Text(l.music),
                subtitle: Text(l.musicDesc),
                value: music,
                onChanged: (v) => ref.read(musicProvider.notifier).set(v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.volume_up),
                title: Text(l.sound),
                subtitle: Text(l.soundDesc),
                value: s.sound,
                onChanged: n.setSound,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text(l.signOut),
                onPressed: () async {
                  ref.invalidate(numberProvider);
                  ref.invalidate(boardProvider);
                  await FirebaseUIAuth.signOut(context: context);
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}