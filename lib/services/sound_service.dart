import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;

  static const int _poolSize = 4;
  final List<AudioPlayer> _players = List.generate(_poolSize, (_) => AudioPlayer());
  int _playerIndex = 0;

  bool _isMuted = false;
  double _masterVolume = 1.0;

  bool get isMuted => _isMuted;
  double get masterVolume => _masterVolume;

  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> volumeNotifier = ValueNotifier<double>(1.0);

  SoundService._internal() {
    _initAudioContext();
  }

  void _initAudioContext() {
    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );

      for (final p in _players) {
        p.setPlayerMode(PlayerMode.lowLatency);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configuring audio context: $e');
      }
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    isMutedNotifier.value = _isMuted;
  }

  void setMute(bool mute) {
    _isMuted = mute;
    isMutedNotifier.value = mute;
  }

  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    volumeNotifier.value = _masterVolume;
  }

  Future<void> _playSound(String assetPath, {double volume = 1.0}) async {
    if (_isMuted) return;
    try {
      final player = _players[_playerIndex];
      _playerIndex = (_playerIndex + 1) % _poolSize;

      final effectiveVolume = (_masterVolume * volume).clamp(0.0, 1.0);
      await player.stop();
      await player.setVolume(effectiveVolume);
      await player.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        print('Sound error on $assetPath: $e');
      }
    }
  }

  // 1. Dice Roll Sound
  Future<void> playDiceRoll() async {
    await _playSound('sounds/dice_roll.wav', volume: 1.0);
  }

  // 2. Token Step Sound
  Future<void> playStep() async {
    await _playSound('sounds/step.wav', volume: 1.0);
  }

  // 3. Good Deed / Neki Chime
  Future<void> playNeki() async {
    await _playSound('sounds/neki.wav', volume: 1.0);
  }

  // 4. Pillar Unlocked Chime
  Future<void> playPillar() async {
    await _playSound('sounds/pillar.wav', volume: 1.0);
  }

  // 5. Sin / Warning Tone
  Future<void> playSinWarning() async {
    await _playSound('sounds/sin.wav', volume: 1.0);
  }

  // 6. Tawbah Peace Tone
  Future<void> playTawbah() async {
    await _playSound('sounds/tawbah.wav', volume: 1.0);
  }

  // 7. Quiz Correct Tone
  Future<void> playQuizCorrect() async {
    await _playSound('sounds/quiz_correct.wav', volume: 1.0);
  }

  // 8. Quiz Wrong Tone
  Future<void> playQuizWrong() async {
    await _playSound('sounds/quiz_wrong.wav', volume: 1.0);
  }

  // 9. Victory Fanfare
  Future<void> playVictory() async {
    await _playSound('sounds/victory.wav', volume: 1.0);
  }

  void dispose() {
    for (final p in _players) {
      p.dispose();
    }
  }
}
