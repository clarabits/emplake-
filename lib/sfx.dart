import 'package:audioplayers/audioplayers.dart';

/// Efeitos sonoros do jogo (arquivos em assets/audio/).
enum Sfx { click, error, success, launch }

class SfxPlayer {
  static final Map<Sfx, AudioPlayer> _players = {};

  static const _files = {
    Sfx.click: 'audio/sfx_click.wav',
    Sfx.error: 'audio/sfx_error.wav',
    Sfx.success: 'audio/sfx_success.wav',
    Sfx.launch: 'audio/sfx_launch.wav',
  };

  static Future<void> play(Sfx s) async {
    try {
      final p = _players.putIfAbsent(s, () => AudioPlayer());
      await p.setVolume(.6);
      await p.stop(); // permite repetir o mesmo efeito em toques rápidos
      await p.play(AssetSource(_files[s]!));
    } catch (_) {
      // se o navegador bloquear o áudio, o jogo continua normalmente
    }
  }
}