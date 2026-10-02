import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/board_tile.dart';
import '../models/islamic_quiz.dart';
import '../models/player.dart';
import '../state/settings_provider.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Global toggle for card voice narration
  final ValueNotifier<bool> isVoiceEnabledNotifier = ValueNotifier<bool>(true);
  bool get isVoiceEnabled => isVoiceEnabledNotifier.value;

  /// State indicating whether TTS is currently speaking
  final ValueNotifier<bool> isSpeakingNotifier = ValueNotifier<bool>(false);
  bool get isSpeaking => isSpeakingNotifier.value;

  /// Current avatar name for display
  final ValueNotifier<String> currentAvatarNameNotifier = ValueNotifier<String>('শায়খ উমর');
  String get currentAvatarName => currentAvatarNameNotifier.value;

  double _volume = 1.0;
  double get volume => _volume;
  final ValueNotifier<double> volumeNotifier = ValueNotifier<double>(1.0);

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    volumeNotifier.value = _volume;
    _flutterTts.setVolume(_volume);
  }

  AppLanguage _currentLanguage = AppLanguage.bn;
  double _currentPitch = 0.95;
  double _currentSpeechRate = 0.46;

  Future<void> _initTts() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    } catch (e) {
      if (kDebugMode) {
        print('TTS iOS audio setup note: $e');
      }
    }

    try {
      await _updateLanguageSetting();
    } catch (e) {
      if (kDebugMode) {
        print('TTS language setup error: $e');
      }
    }

    await _flutterTts.setSpeechRate(_currentSpeechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_currentPitch);

    _flutterTts.setStartHandler(() {
      isSpeakingNotifier.value = true;
    });

    _flutterTts.setCompletionHandler(() {
      isSpeakingNotifier.value = false;
    });

    _flutterTts.setCancelHandler(() {
      isSpeakingNotifier.value = false;
    });

    _flutterTts.setErrorHandler((msg) {
      if (kDebugMode) {
        print('TTS runtime error: $msg');
      }
      isSpeakingNotifier.value = false;
    });

    _isInitialized = true;
  }

  Future<void> _updateLanguageSetting() async {
    try {
      final dynamic languages = await _flutterTts.getLanguages;
      if (_currentLanguage == AppLanguage.bn) {
        if (languages is List) {
          if (languages.contains('bn-BD')) {
            await _flutterTts.setLanguage('bn-BD');
          } else if (languages.contains('bn-IN')) {
            await _flutterTts.setLanguage('bn-IN');
          } else {
            await _flutterTts.setLanguage('bn');
          }
        } else {
          await _flutterTts.setLanguage('bn-BD');
        }
      } else {
        if (languages is List) {
          if (languages.contains('en-US')) {
            await _flutterTts.setLanguage('en-US');
          } else if (languages.contains('en-GB')) {
            await _flutterTts.setLanguage('en-GB');
          } else {
            await _flutterTts.setLanguage('en');
          }
        } else {
          await _flutterTts.setLanguage('en-US');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('TTS setLanguage error: $e');
      }
    }
  }

  /// Configure voice parameters from selected avatar and language
  Future<void> configureVoice({
    required AppLanguage language,
    required double pitch,
    required double rate,
    String? avatarName,
  }) async {
    _currentLanguage = language;
    _currentPitch = pitch;
    _currentSpeechRate = rate;
    if (avatarName != null) {
      currentAvatarNameNotifier.value = avatarName;
    }

    try {
      await _initTts();
      await _updateLanguageSetting();
      await _flutterTts.setPitch(_currentPitch);
      await _flutterTts.setSpeechRate(_currentSpeechRate);
      await _flutterTts.setVolume(_volume);
    } catch (e) {
      if (kDebugMode) {
        print('TTS configureVoice error: $e');
      }
    }
  }

  /// Preview speech for a given avatar
  Future<void> previewAvatarSpeech({
    required String text,
    required AppLanguage language,
    required double pitch,
    required double rate,
  }) async {
    await stop();
    try {
      _currentLanguage = language;
      await _initTts();
      await _updateLanguageSetting();
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.speak(text, focus: true);
    } catch (e) {
      if (kDebugMode) {
        print('TTS preview speech error: $e');
      }
    }
  }

  void toggleVoiceEnabled() {
    isVoiceEnabledNotifier.value = !isVoiceEnabledNotifier.value;
    if (!isVoiceEnabledNotifier.value) {
      stop();
    }
  }

  void setVoiceEnabled(bool enabled) {
    isVoiceEnabledNotifier.value = enabled;
    if (!enabled) {
      stop();
    }
  }

  /// Format and speak the entire event tile content clearly
  Future<void> speakTile(BoardTile tile, {AppLanguage? language}) async {
    if (!isVoiceEnabled) return;
    await stop();

    final lang = language ?? _currentLanguage;
    _currentLanguage = lang;
    final StringBuffer sb = StringBuffer();

    if (lang == AppLanguage.bn) {
      sb.write(tile.title);
      sb.write('। ');
      sb.write(tile.description);
      sb.write('। ');

      if (tile.hadithOrAyat != null && tile.hadithOrAyat!.trim().isNotEmpty) {
        final cleanQuote = tile.hadithOrAyat!
            .replaceAll('“', '')
            .replaceAll('”', '')
            .replaceAll('"', '')
            .replaceAll('[', '(')
            .replaceAll(']', ')');
        sb.write('উদ্ধৃতি: $cleanQuote। ');
      }

      if (tile.nekiDelta > 0) {
        sb.write('আপনি ${tile.nekiDelta} নেকি পেলেন। ');
      }
      if (tile.gunahDelta > 0) {
        sb.write('সাবধান! ${tile.gunahDelta} গুনাহ যুক্ত হলো। ');
      }
      if (tile.isLadder) {
        sb.write('সিঁড়ি দিয়ে ${tile.jumpTo} নম্বর ঘরে উন্নীত হলেন! ');
      } else if (tile.isSnake) {
        sb.write('পিছলে ${tile.jumpTo} নম্বর ঘরে নেমে গেলেন! ');
      }
      if (tile.pillarReward != null) {
        sb.write('আপনি ${tile.pillarReward!.nameBn} স্তম্ভ অর্জন করেছেন! ');
      }
    } else {
      // English card narration
      final enTitle = tile.getTitle(AppLanguage.en);
      final enDesc = tile.getDescription(AppLanguage.en);
      sb.write(enTitle);
      sb.write('. ');
      sb.write(enDesc);
      sb.write('. ');

      final quote = tile.getHadithOrAyat(AppLanguage.en);
      if (quote != null && quote.trim().isNotEmpty) {
        final cleanQuote = quote
            .replaceAll('“', '')
            .replaceAll('”', '')
            .replaceAll('"', '')
            .replaceAll('[', '(')
            .replaceAll(']', ')');
        sb.write('Reference: $cleanQuote. ');
      }

      if (tile.nekiDelta > 0) {
        sb.write('You gained ${tile.nekiDelta} good deeds. ');
      }
      if (tile.gunahDelta > 0) {
        sb.write('Warning! ${tile.gunahDelta} sins added. ');
      }
      if (tile.isLadder) {
        sb.write('Climbed the ladder to tile number ${tile.jumpTo}! ');
      } else if (tile.isSnake) {
        sb.write('Slid down to tile number ${tile.jumpTo}! ');
      }
      if (tile.pillarReward != null) {
        sb.write('You unlocked the pillar of ${tile.pillarReward!.getName(AppLanguage.en)}! ');
      }
    }

    await speak(sb.toString());
  }

  /// Speak quiz question and choices
  Future<void> speakQuiz(QuizQuestion quiz, {AppLanguage? language}) async {
    if (!isVoiceEnabled) return;
    await stop();

    final lang = language ?? _currentLanguage;
    _currentLanguage = lang;
    final StringBuffer sb = StringBuffer();

    if (lang == AppLanguage.bn) {
      sb.write('প্রশ্ন: ');
      sb.write(quiz.question);
      sb.write('। অপশনগুলো হলো: ');
      for (int i = 0; i < quiz.options.length; i++) {
        sb.write('অপশন ${i + 1}: ${quiz.options[i]}। ');
      }
    } else {
      sb.write('Question: ');
      sb.write(quiz.getQuestion(AppLanguage.en));
      sb.write('. The options are: ');
      final options = quiz.getOptions(AppLanguage.en);
      for (int i = 0; i < options.length; i++) {
        sb.write('Option ${i + 1}: ${options[i]}. ');
      }
    }

    await speak(sb.toString());
  }

  /// Speak Tawbah card guidance
  Future<void> speakTawbah({AppLanguage? language}) async {
    if (!isVoiceEnabled) return;
    await stop();

    final lang = language ?? _currentLanguage;
    _currentLanguage = lang;
    final StringBuffer sb = StringBuffer();

    if (lang == AppLanguage.bn) {
      sb.write('তওবা ও ইস্তিগফার। ');
      sb.write('হে ঈমানদারগণ! তোমরা আল্লাহর কাছে খাঁটি তওবা করো, আশা করা যায় তোমাদের প্রতিপালক তোমাদের পাপসমূহ ক্ষমা করে দেবেন। ');
      sb.write('আস্তাগফিরুল্লাহাল আজিম ওয়া আতূবু ইলাইহি। ');
      sb.write('পঞ্চাশ শতাংশ গুনাহ মাফ এবং ত্রিশ নেকি বোনাস। ');
    } else {
      sb.write('Repentance and Istighfar. ');
      sb.write('O you who believe! Turn to Allah with sincere repentance, perhaps your Lord will expiate from you your sins. ');
      sb.write('Astaghfirullah al-Azeem wa atoobu ilayh. ');
      sb.write('Fifty percent of sins forgiven and thirty bonus good deeds. ');
    }

    await speak(sb.toString());
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _initTts();
      await _updateLanguageSetting();
      await _flutterTts.setPitch(_currentPitch);
      await _flutterTts.setSpeechRate(_currentSpeechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.speak(text, focus: true);
    } catch (e) {
      if (kDebugMode) {
        print('TTS speak failed: $e');
      }
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      isSpeakingNotifier.value = false;
    } catch (e) {
      if (kDebugMode) {
        print('TTS stop failed: $e');
      }
    }
  }
}
