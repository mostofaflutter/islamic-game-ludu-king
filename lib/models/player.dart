import 'package:flutter/material.dart';
import '../state/settings_provider.dart';

enum PillarType {
  kalima,
  namaz,
  roza,
  zakat,
  hajj,
}

extension PillarTypeExtension on PillarType {
  String get nameBn {
    switch (this) {
      case PillarType.kalima:
        return 'কালেমা (ঈমান)';
      case PillarType.namaz:
        return 'নামাজ (সালাত)';
      case PillarType.roza:
        return 'রোজা (সওম)';
      case PillarType.zakat:
        return 'যাকাত (দান)';
      case PillarType.hajj:
        return 'হজ্ব (সফর)';
    }
  }

  String get nameEn {
    switch (this) {
      case PillarType.kalima:
        return 'Kalimah (Faith)';
      case PillarType.namaz:
        return 'Salah (Prayer)';
      case PillarType.roza:
        return 'Sawm (Fasting)';
      case PillarType.zakat:
        return 'Zakat (Charity)';
      case PillarType.hajj:
        return 'Hajj (Pilgrimage)';
    }
  }

  String getName([AppLanguage? lang]) => lang == AppLanguage.en ? nameEn : nameBn;

  String get description {
    switch (this) {
      case PillarType.kalima:
        return 'ঈমানের চাবিকাঠি ও সফরের সূচনা';
      case PillarType.namaz:
        return '৩ চালের জন্য গুনাহের ফাঁদ থেকে প্রটেকশন শিল্ড';
      case PillarType.roza:
        return 'নফস নিয়ন্ত্রণ ও ৪ কদম দ্রুত অগ্রগতির সুযোগ';
      case PillarType.zakat:
        return 'সম্পদ পবিত্রকরণ ও দ্বিগুণ নেকি বোনাস';
      case PillarType.hajj:
        return 'মেগা নেকি (+১০০) ও পূর্বের ছোট গুনাহ মার্জনা';
    }
  }

  String get descriptionEn {
    switch (this) {
      case PillarType.kalima:
        return 'Key to faith and the start of the blessed journey';
      case PillarType.namaz:
        return 'Protection shield from sin traps for 3 turns';
      case PillarType.roza:
        return 'Self-restraint and fast 4-tile advancement opportunity';
      case PillarType.zakat:
        return 'Purification of wealth and double good deeds bonus';
      case PillarType.hajj:
        return 'Mega reward (+100 Hasanah) and pardon of previous minor sins';
    }
  }

  String getDescription([AppLanguage? lang]) => lang == AppLanguage.en ? descriptionEn : description;

  IconData get icon {
    switch (this) {
      case PillarType.kalima:
        return Icons.verified;
      case PillarType.namaz:
        return Icons.shield;
      case PillarType.roza:
        return Icons.nightlight_round;
      case PillarType.zakat:
        return Icons.volunteer_activism;
      case PillarType.hajj:
        return Icons.mosque;
    }
  }

  Color get color {
    switch (this) {
      case PillarType.kalima:
        return const Color(0xFF10B981); // Emerald
      case PillarType.namaz:
        return const Color(0xFF3B82F6); // Blue
      case PillarType.roza:
        return const Color(0xFF8B5CF6); // Purple
      case PillarType.zakat:
        return const Color(0xFFF59E0B); // Amber
      case PillarType.hajj:
        return const Color(0xFFEC4899); // Pink
    }
  }
}

class Player {
  final int id;
  final String nameBn;
  final String nameEn;
  final String? customName;
  final Color color;
  final bool isAi;
  int position;
  bool hasStarted;
  int neki;
  int gunah;
  int salahShieldTurns;
  final Set<PillarType> collectedPillars;
  bool isCompleted;
  bool isFailed;
  String statusMessage;

  Player({
    required this.id,
    String? name,
    String? nameBn,
    String? nameEn,
    this.customName,
    required this.color,
    this.isAi = false,
    this.position = 0,
    this.hasStarted = true,
    this.neki = 50,
    this.gunah = 0,
    this.salahShieldTurns = 0,
    Set<PillarType>? collectedPillars,
    this.isCompleted = false,
    this.isFailed = false,
    this.statusMessage = 'সফর শুরু হয়েছে...',
  })  : nameBn = nameBn ?? (name ?? 'মুসাফির ${id + 1}'),
        nameEn = nameEn ?? (name ?? 'Player ${id + 1}'),
        collectedPillars = collectedPillars ?? <PillarType>{PillarType.kalima};

  String get name => getName();

  String getName([AppLanguage? lang]) {
    if (customName != null && customName!.trim().isNotEmpty) {
      final defaultBn = ['মুসাফির ১', 'মুসাফির ২', 'মুসাফির ৩', 'মুসাফির ৪'];
      final defaultEn = ['Player 1', 'Player 2', 'Player 3', 'Player 4', 'Musafir 1', 'Musafir 2', 'Musafir 3', 'Musafir 4'];
      if (!defaultBn.contains(customName) && !defaultEn.contains(customName)) {
        return customName!;
      }
    }
    return (lang == AppLanguage.en) ? nameEn : nameBn;
  }

  bool get hasShield => salahShieldTurns > 0;

  double get mizanRatio {
    final total = (neki + gunah).toDouble();
    if (total == 0) return 0.5;
    return (neki / total).clamp(0.0, 1.0);
  }

  void addNeki(int amount) {
    neki += amount;
  }

  void addGunah(int amount) {
    if (hasShield) {
      statusMessage = '🛡️ নামাজের শিল্ড থাকায় গুনাহ থেকে রক্ষা পেয়েছেন!';
    } else {
      gunah += amount;
    }
  }

  void unlockPillar(PillarType pillar) {
    collectedPillars.add(pillar);
  }

  void decrementShield() {
    if (salahShieldTurns > 0) {
      salahShieldTurns--;
    }
  }

  void reset() {
    position = 0;
    hasStarted = true;
    neki = 50;
    gunah = 0;
    salahShieldTurns = 0;
    collectedPillars.clear();
    collectedPillars.add(PillarType.kalima);
    isCompleted = false;
    isFailed = false;
    statusMessage = 'নতুন সফর শুরু হলো...';
  }
}
