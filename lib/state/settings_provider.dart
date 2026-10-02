import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../services/tts_service.dart';

enum AppLanguage {
  bn,
  en,
}

class NarratorAvatar {
  final String id;
  final String nameBn;
  final String nameEn;
  final String titleBn;
  final String titleEn;
  final String descriptionBn;
  final String descriptionEn;
  final String sampleGreetingBn;
  final String sampleGreetingEn;
  final double pitch;
  final double speechRate;
  final Color color;
  final IconData icon;

  const NarratorAvatar({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.titleBn,
    required this.titleEn,
    required this.descriptionBn,
    required this.descriptionEn,
    required this.sampleGreetingBn,
    required this.sampleGreetingEn,
    required this.pitch,
    required this.speechRate,
    required this.color,
    required this.icon,
  });

  String getName(AppLanguage lang) => lang == AppLanguage.bn ? nameBn : nameEn;
  String getTitle(AppLanguage lang) => lang == AppLanguage.bn ? titleBn : titleEn;
  String getDescription(AppLanguage lang) => lang == AppLanguage.bn ? descriptionBn : descriptionEn;
  String getGreeting(AppLanguage lang) => lang == AppLanguage.bn ? sampleGreetingBn : sampleGreetingEn;

  static const List<NarratorAvatar> defaultAvatars = [
    NarratorAvatar(
      id: 'umar',
      nameBn: 'শায়খ উমর',
      nameEn: 'Sheikh Umar',
      titleBn: 'প্রজ্ঞাবান আলেম',
      titleEn: 'Wise Scholar',
      descriptionBn: 'গম্ভীর, শান্ত ও প্রজ্ঞাময় কণ্ঠে কার্ড পাঠ করেন।',
      descriptionEn: 'Narrates cards with a deep, dignified and calm voice.',
      sampleGreetingBn: 'বিসমিল্লাহির রাহমানির রাহিম। আমি শায়খ উমর, আপনাদের জান্নাতের কাফেলায় স্বাগতম।',
      sampleGreetingEn: 'In the name of Allah. I am Sheikh Umar, welcome to your journey toward Jannah.',
      pitch: 0.95,
      speechRate: 0.46,
      color: Color(0xFF10B981), // Emerald Green
      icon: Icons.record_voice_over_rounded,
    ),
    NarratorAvatar(
      id: 'ahmad',
      nameBn: 'কারী আহমাদ',
      nameEn: 'Qari Ahmad',
      titleBn: 'মিষ্টি সুরের কারী',
      titleEn: 'Melodious Reciter',
      descriptionBn: 'স্পষ্ট, সুললিত ও বিশুদ্ধ উচ্চারণে পড়ে শোনান।',
      descriptionEn: 'Narrates clearly with a melodious, recitation-like tone.',
      sampleGreetingBn: 'আসসালামু আলাইকুম। আমি কারী আহমাদ, দ্বীনি বার্তার পথপ্রদর্শক।',
      sampleGreetingEn: 'Assalamu Alaikum. I am Qari Ahmad, your guide through Islamic wisdom.',
      pitch: 1.0,
      speechRate: 0.48,
      color: Color(0xFFF59E0B), // Golden Amber
      icon: Icons.menu_book_rounded,
    ),
    NarratorAvatar(
      id: 'maryam',
      nameBn: 'হাফেজা মরিয়ম',
      nameEn: 'Hafeza Maryam',
      titleBn: 'শান্ত ও মমতাময়ী শিক্ষক',
      titleEn: 'Gentle Educator',
      descriptionBn: 'কোমল, মধুর ও স্নেহমাখা কন্ঠে প্রতিটি শব্দ শোনান।',
      descriptionEn: 'Narrates gently with a warm, caring feminine voice.',
      sampleGreetingBn: 'আসসালামু আলাইকুম প্রিয় ভাই ও বোনেরা। আমি মরিয়ম, চলুন একসাথে দ্বীন শিখি।',
      sampleGreetingEn: 'Assalamu Alaikum dear companions. I am Maryam, let us learn our Deen together.',
      pitch: 1.25,
      speechRate: 0.48,
      color: Color(0xFFEC4899), // Rose Pink
      icon: Icons.auto_stories_rounded,
    ),
    NarratorAvatar(
      id: 'zayed',
      nameBn: 'তরুণ দায়ী জায়েদ',
      nameEn: 'Zayed the Da\'ee',
      titleBn: 'উদ্যমী তরুণ প্রচারক',
      titleEn: 'Energetic Youth Da\'ee',
      descriptionBn: 'উদ্যমী, প্রাণবন্ত ও দ্রুতগতিতে উৎসাহ যোগান।',
      descriptionEn: 'Narrates with an energetic, spirited and motivating pace.',
      sampleGreetingBn: 'আসসালামু আলাইকুম বন্ধু! আমি জায়েদ, চলুন নেকির প্রতিযোগিতায় এগিয়ে যাই!',
      sampleGreetingEn: 'Assalamu Alaikum my friend! I am Zayed, let us race toward good deeds!',
      pitch: 1.10,
      speechRate: 0.52,
      color: Color(0xFF38BDF8), // Sky Blue
      icon: Icons.campaign_rounded,
    ),
  ];
}

class SettingsProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.bn;
  NarratorAvatar _currentAvatar = NarratorAvatar.defaultAvatars[0];
  bool _isVoiceEnabled = true;
  bool _isSoundEnabled = true;
  double _speechRateMultiplier = 1.0;
  double _pitchMultiplier = 1.0;
  double _ttsVolume = 1.0;
  double _soundVolume = 1.0;

  AppLanguage get language => _language;
  bool get isBangla => _language == AppLanguage.bn;
  NarratorAvatar get currentAvatar => _currentAvatar;
  List<NarratorAvatar> get availableAvatars => NarratorAvatar.defaultAvatars;
  bool get isVoiceEnabled => _isVoiceEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  double get speechRateMultiplier => _speechRateMultiplier;
  double get pitchMultiplier => _pitchMultiplier;
  double get ttsVolume => _ttsVolume;
  double get soundVolume => _soundVolume;

  SettingsProvider() {
    _syncWithTts();
    SoundService().setMasterVolume(_soundVolume);
    TtsService().setVolume(_ttsVolume);
  }

  void setTtsVolume(double volume) {
    _ttsVolume = volume.clamp(0.0, 1.0);
    TtsService().setVolume(_ttsVolume);
    notifyListeners();
  }

  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
    SoundService().setMasterVolume(_soundVolume);
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    if (_language == lang) return;
    _language = lang;
    _syncWithTts();
    notifyListeners();
  }

  void setAvatar(NarratorAvatar avatar) {
    _currentAvatar = avatar;
    _syncWithTts();
    notifyListeners();
  }

  void toggleVoice() {
    _isVoiceEnabled = !_isVoiceEnabled;
    TtsService().setVoiceEnabled(_isVoiceEnabled);
    notifyListeners();
  }

  void setVoiceEnabled(bool enabled) {
    _isVoiceEnabled = enabled;
    TtsService().setVoiceEnabled(enabled);
    notifyListeners();
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    SoundService().setMute(!_isSoundEnabled);
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
    SoundService().setMute(!enabled);
    notifyListeners();
  }

  void setSpeechRateMultiplier(double rate) {
    _speechRateMultiplier = rate;
    _syncWithTts();
    notifyListeners();
  }

  void setPitchMultiplier(double pitch) {
    _pitchMultiplier = pitch;
    _syncWithTts();
    notifyListeners();
  }

  void _syncWithTts() {
    final effectivePitch = (_currentAvatar.pitch * _pitchMultiplier).clamp(0.5, 2.0);
    final effectiveRate = (_currentAvatar.speechRate * _speechRateMultiplier).clamp(0.3, 1.0);
    TtsService().configureVoice(
      language: _language,
      pitch: effectivePitch,
      rate: effectiveRate,
      avatarName: _currentAvatar.getName(_language),
    );
  }

  Future<void> previewAvatarVoice(NarratorAvatar avatar) async {
    final effectivePitch = (avatar.pitch * _pitchMultiplier).clamp(0.5, 2.0);
    final effectiveRate = (avatar.speechRate * _speechRateMultiplier).clamp(0.3, 1.0);
    await TtsService().previewAvatarSpeech(
      text: avatar.getGreeting(_language),
      language: _language,
      pitch: effectivePitch,
      rate: effectiveRate,
    );
  }
}
