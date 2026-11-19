import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'engine.dart';

final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// ------------------------------------------------------------ Configurações
class SettingsState {
  final ThemeMode mode;
  final double scale;
  final String font;
  final int seed;
  final bool sound;
  final Locale? locale;
  const SettingsState({required this.mode, required this.scale, required this.font, required this.seed, required this.sound, this.locale});

  SettingsState copyWith({ThemeMode? mode, double? scale, String? font, int? seed, bool? sound, Locale? locale}) =>
      SettingsState(
          mode: mode ?? this.mode,
          scale: scale ?? this.scale,
          font: font ?? this.font,
          seed: seed ?? this.seed,
          sound: sound ?? this.sound,
          locale: locale ?? this.locale);
}

class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _p;

  @override
  SettingsState build() {
    _p = ref.read(prefsProvider);
    final lang = _p.getString('lang');
    return SettingsState(
      mode: ThemeMode.values[_p.getInt('mode') ?? 0], // 0 = system (padrão do dispositivo)
      scale: _p.getDouble('scale') ?? 1.0,
      font: _p.getString('font') ?? 'Exo 2',
      seed: _p.getInt('seed') ?? 0xFF3F51B5,
      sound: _p.getBool('sound') ?? false, // som começa DESLIGADO
      locale: lang == null ? null : Locale(lang),
    );
  }

  void setMode(ThemeMode m) {
    state = state.copyWith(mode: m);
    _p.setInt('mode', m.index);
  }

  void setScale(double v) {
    state = state.copyWith(scale: v);
    _p.setDouble('scale', v);
  }

  void setFont(String f) {
    state = state.copyWith(font: f);
    _p.setString('font', f);
  }

  void setSeed(int c) {
    state = state.copyWith(seed: c);
    _p.setInt('seed', c);
  }

  void setSound(bool v) {
    state = state.copyWith(sound: v);
    _p.setBool('sound', v);
  }

  void setLocale(Locale l) {
    state = state.copyWith(locale: l);
    _p.setString('lang', l.languageCode);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

// ------------------------------------------------------------ Nível e tabuleiro
class LevelNotifier extends Notifier<Level> {
  @override
  Level build() => Level.easy;
  void set(Level l) => state = l;
}

final levelProvider = NotifierProvider<LevelNotifier, Level>(LevelNotifier.new);

class BoardState {
  final List<List<String>> slots; // 5 docas: antes/entre/depois dos 4 dígitos
  final int slot; // doca onde está o cursor
  final int index; // posição do cursor dentro da doca (0..tamanho)
  final bool returning; // true durante a animação de "voltar para a paleta"
  BoardState(this.slots, this.slot, this.index, this.returning);
  factory BoardState.empty() => BoardState(List.generate(5, (_) => <String>[]), 0, 0, false);
  bool get hasEq => slots.any((s) => s.contains('='));
}

class BoardNotifier extends Notifier<BoardState> {
  @override
  BoardState build() => BoardState.empty();

  List<List<String>> _copy() => [for (final s in state.slots) [...s]];

  /// Move o cursor. Sem [index], vai para o fim da doca.
  void select(int slot, [int? index]) =>
      state = BoardState(state.slots, slot, index ?? state.slots[slot].length, false);

  /// Insere a ficha NA POSIÇÃO DO CURSOR (pode ser entre duas fichas já colocadas).
  void add(String t) {
    if (state.returning || (t == '=' && state.hasEq)) return;
    final c = _copy();
    final i = state.index.clamp(0, c[state.slot].length);
    c[state.slot].insert(i, t);
    state = BoardState(c, state.slot, i + 1, false);
  }

  /// Apaga a ficha logo antes do cursor (como a tecla Backspace).
  void backspace() {
    if (state.returning) return;
    final c = _copy();
    var s = state.slot;
    var i = state.index.clamp(0, c[s].length);
    if (i == 0) {
      var p = s - 1;
      while (p >= 0 && c[p].isEmpty) {
        p--;
      }
      if (p < 0) return;
      s = p;
      i = c[s].length;
    }
    c[s].removeAt(i - 1);
    state = BoardState(c, s, i - 1, false);
  }

  void startReturn() => state = BoardState(state.slots, state.slot, state.index, true);
  void clear() => state = BoardState.empty();
}

final boardProvider = NotifierProvider<BoardNotifier, BoardState>(BoardNotifier.new);

// ------------------------------------------------------------ Firestore
class Progress {
  final List<int> solved;
  final int score;
  Progress(this.solved, this.score);
}

class ProgressRepo {
  final _db = FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> _doc(String uid) => _db.collection('users').doc(uid);

  Future<Progress> load(String uid) async {
    final d = (await _doc(uid).get()).data() ?? {};
    final solved = ((d['solved'] as List?) ?? []).map((e) => (e as num).toInt()).toList();
    return Progress(solved, (d['score'] as num?)?.toInt() ?? 0);
  }

  /// Sorteia um número de 1000..9999 que o usuário ainda NÃO resolveu.
  Future<int?> nextUnsolved(String uid, Set<int> skipped) async {
    final solved = (await load(uid)).solved.toSet();
    var pool = [for (var n = 1000; n <= 9999; n++) if (!solved.contains(n) && !skipped.contains(n)) n];
    if (pool.isEmpty) pool = [for (var n = 1000; n <= 9999; n++) if (!solved.contains(n)) n];
    if (pool.isEmpty) return null;
    return pool[Random().nextInt(pool.length)];
  }

  Future<void> markSolved(String uid, int n, int points) => _doc(uid).set({
        'solved': FieldValue.arrayUnion([n]),
        'score': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
}

final repoProvider = Provider<ProgressRepo>((ref) => ProgressRepo());

/// Guarda o Future do número atual (sobrevive à troca de abas do menu).
class NumberNotifier extends Notifier<Future<int?>> {
  final Set<int> _skipped = {};

  @override
  Future<int?> build() {
    _skipped.clear();
    return _fetch();
  }

  Future<int?> _fetch() => ref.read(repoProvider).nextUnsolved(FirebaseAuth.instance.currentUser!.uid, _skipped);

  void next({int? skip}) {
    if (skip != null) _skipped.add(skip);
    ref.read(boardProvider.notifier).clear();
    state = _fetch();
  }
}

final numberProvider = NotifierProvider<NumberNotifier, Future<int?>>(NumberNotifier.new);