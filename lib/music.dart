import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Música ambiente de fundo. Começa DESLIGADA e só toca se o usuário ligar em Configurações.
/// Arquivo: assets/audio/emplake_ambient.wav (trilha original, loop de 32 s).
class MusicNotifier extends Notifier<bool> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  bool _loading = false;

  @override
  bool build() {
    ref.onDispose(_player.dispose);
    return ref.read(prefsProvider).getBool('music') ?? false;
  }

  Future<void> _play() async {
    if (_playing || _loading) return;
    _loading = true;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(.35);
      await _player.play(AssetSource('audio/emplake_ambient.wav'));
      _playing = true;
    } catch (_) {
      _playing = false; // o navegador pode bloquear o áudio até o primeiro toque do usuário
    } finally {
      _loading = false;
    }
  }

  Future<void> set(bool on) async {
    state = on;
    ref.read(prefsProvider).setBool('music', on);
    if (on) {
      await _play();
    } else {
      _playing = false;
      await _player.stop();
    }
  }

  /// Chamado no primeiro toque na tela: se a música estava ligada mas o navegador
  /// bloqueou o início automático, ela começa agora.
  void resumeIfNeeded() {
    if (state && !_playing) _play();
  }
}

final musicProvider = NotifierProvider<MusicNotifier, bool>(MusicNotifier.new);