import 'package:flutter/material.dart';
import 'player.dart';
import '../state/settings_provider.dart';

enum TileType {
  start,
  goodDeed,
  sinTrap,
  pillar,
  quiz,
  tawbah,
  mizan,
  sirat,
  jannah,
  safe,
}

class BoardTile {
  final int index;
  final String title;
  final String description;
  final String? hadithOrAyat;
  final String? titleEn;
  final String? descriptionEn;
  final String? hadithOrAyatEn;
  final TileType type;
  final int nekiDelta;
  final int gunahDelta;
  final int? jumpTo; // ladder (forward) or snake (backward)
  final PillarType? pillarReward;
  final IconData icon;
  final Color color;

  const BoardTile({
    required this.index,
    required this.title,
    required this.description,
    this.hadithOrAyat,
    this.titleEn,
    this.descriptionEn,
    this.hadithOrAyatEn,
    required this.type,
    this.nekiDelta = 0,
    this.gunahDelta = 0,
    this.jumpTo,
    this.pillarReward,
    required this.icon,
    required this.color,
  });

  bool get isLadder => jumpTo != null && jumpTo! > index;
  bool get isSnake => jumpTo != null && jumpTo! < index;

  String getTitle([AppLanguage? lang]) =>
      (lang == AppLanguage.en && titleEn != null) ? titleEn! : title;

  String getDescription([AppLanguage? lang]) =>
      (lang == AppLanguage.en && descriptionEn != null) ? descriptionEn! : description;

  String? getHadithOrAyat([AppLanguage? lang]) =>
      (lang == AppLanguage.en && hadithOrAyatEn != null) ? hadithOrAyatEn : hadithOrAyat;
}

class BoardData {
  static List<BoardTile> generateBoard() {
    final List<BoardTile> tiles = [];

    for (int i = 0; i <= 52; i++) {
      tiles.add(_getTile(i));
    }

    return tiles;
  }

  static BoardTile _getTile(int i) {
    switch (i) {
      case 0:
        return const BoardTile(
          index: 0,
          title: 'দুনিয়ার জীবন (সূচনা)',
          titleEn: 'Life of this World (Start)',
          description: 'কালেমার উপর ঈমান এনে জান্নাতের উদ্দেশ্যে সফল সফর শুরু করুন।',
          descriptionEn: 'Begin your blessed journey towards Jannah with faith in the Kalimah.',
          hadithOrAyat: '“লা ইলাহা ইল্লাল্লাহু মুহাম্মাদুর রাসুলুল্লাহ”',
          hadithOrAyatEn: '“La Ilaha Illallah Muhammadur Rasulullah”',
          type: TileType.start,
          pillarReward: PillarType.kalima,
          icon: Icons.flag,
          color: Color(0xFF10B981),
        );

      case 2:
        return const BoardTile(
          index: 2,
          title: 'সালামের প্রচার',
          titleEn: 'Spreading Salam',
          description: 'পরিচিত-অপরিচিত সকলকে সালাম দেওয়া সুন্নাত।',
          descriptionEn: 'Greeting everyone you know and do not know with Salam is a Sunnah.',
          hadithOrAyat: '“তোমরা পরস্পরের মাঝে সালামের প্রসার ঘটাও।” [মুসলিম]',
          hadithOrAyatEn: '“Spread Salam among yourselves.” [Muslim]',
          type: TileType.goodDeed,
          nekiDelta: 15,
          icon: Icons.record_voice_over,
          color: Color(0xFF059669),
        );

      case 4:
        return const BoardTile(
          index: 4,
          title: 'সাদাকাহ দান',
          titleEn: 'Giving Charity (Sadaqah)',
          description: 'হাসিমুখে কথা বলা ও বিপদগ্রস্তকে সাহায্য করা সাদাকাহ।',
          descriptionEn: 'Speaking with a smile and helping those in distress is charity.',
          hadithOrAyat: '“সাদাকাহ গুনাহকে মিটিয়ে দেয় যেমন পানি আগুনকে নেভায়।” [তিরমিযী]',
          hadithOrAyatEn: '“Charity extinguishes sin just as water extinguishes fire.” [Tirmidhi]',
          type: TileType.goodDeed,
          nekiDelta: 20,
          jumpTo: 8,
          icon: Icons.favorite,
          color: Color(0xFF0D9488),
        );

      case 6:
        return const BoardTile(
          index: 6,
          title: 'অহেতুক রাগ প্রকাশ',
          titleEn: 'Uncontrolled Anger',
          description: 'রাগ নিয়ন্ত্রণ না করা শয়তানের ফাঁদ।',
          descriptionEn: 'Failing to control anger is a trap of Satan.',
          hadithOrAyat: '“প্রকৃত বীর সে-ই, যে রাগের সময় নিজেকে সংবরণ করে।” [বুখারী]',
          hadithOrAyatEn: '“The strong person is the one who controls himself during anger.” [Bukhari]',
          type: TileType.sinTrap,
          gunahDelta: 10,
          jumpTo: 3,
          icon: Icons.sentiment_very_dissatisfied,
          color: Color(0xFFEF4444),
        );

      case 7:
        return const BoardTile(
          index: 7,
          title: 'নামাজ (সালাত)',
          titleEn: 'Prayer (Salah)',
          description: 'নামাজ কায়েম করুন! আপনি ৩ রাউন্ডের জন্য প্রটেকশন শিল্ড পেয়েছেন।',
          descriptionEn: 'Establish prayer! You have earned a protection shield for 3 rounds.',
          hadithOrAyat: '“নামাজ দ্বীনের খুঁটি।” [বায়হাকী]',
          hadithOrAyatEn: '“Prayer is the pillar of faith.” [Bayhaqi]',
          type: TileType.pillar,
          pillarReward: PillarType.namaz,
          nekiDelta: 40,
          icon: Icons.shield,
          color: Color(0xFF2563EB),
        );

      case 10:
        return const BoardTile(
          index: 10,
          title: 'মিথ্যা কথা বলা',
          titleEn: 'Telling Lies',
          description: 'মিথ্যা সকল পাপের মূল। শয়তানের ধোঁকায় আপনি পিছিয়ে গেলেন।',
          descriptionEn: 'Lying is the root of all sins. Deceived by Satan, you fell back.',
          hadithOrAyat: '“মিথ্যা মানুষকে ধ্বংসের দিকে নিয়ে যায়।” [বুখারী]',
          hadithOrAyatEn: '“Lying leads towards destruction.” [Bukhari]',
          type: TileType.sinTrap,
          gunahDelta: 20,
          jumpTo: 5,
          icon: Icons.warning_amber_rounded,
          color: Color(0xFFDC2626),
        );

      case 12:
        return const BoardTile(
          index: 12,
          title: 'ইসলামিক কুইজ',
          titleEn: 'Islamic Quiz',
          description: 'সঠিক উত্তর দিয়ে জ্ঞানের আলো ও নেকি অর্জন করুন।',
          descriptionEn: 'Answer correctly to gain the light of Islamic knowledge and rewards.',
          type: TileType.quiz,
          icon: Icons.help_outline,
          color: Color(0xFF8B5CF6),
        );

      case 14:
        return const BoardTile(
          index: 14,
          title: 'কুরআন তিলাওয়াত',
          titleEn: 'Reciting Quran',
          description: 'কুরআনের প্রতিটি হরফে রয়েছে ১০টি করে নেকি।',
          descriptionEn: 'There are ten rewards for reciting every single letter of the Quran.',
          hadithOrAyat: '“যে ব্যক্তি কুরআনের একটি হরফ পড়বে সে দশটি নেকি পাবে।” [তিরমিযী]',
          hadithOrAyatEn: '“Whoever recites a letter of the Quran will get ten rewards.” [Tirmidhi]',
          type: TileType.goodDeed,
          nekiDelta: 30,
          jumpTo: 18,
          icon: Icons.menu_book,
          color: Color(0xFF10B981),
        );

      case 16:
        return const BoardTile(
          index: 16,
          title: 'গীবত ও পরনিন্দা',
          titleEn: 'Backbiting & Slander',
          description: 'মৃত ভাইয়ের গোশত খাওয়ার মতো মারাত্মক পাপ।',
          descriptionEn: 'A grave sin, like eating the flesh of one\'s deceased brother.',
          hadithOrAyat: '“তোমরা একে অপরের গীবত করো না।” [সূরা হুজুরাত: ১২]',
          hadithOrAyatEn: '“And do not backbite one another.” [Surah Al-Hujurat: 12]',
          type: TileType.sinTrap,
          gunahDelta: 25,
          jumpTo: 9,
          icon: Icons.person_off,
          color: Color(0xFFB91C1C),
        );

      case 19:
        return const BoardTile(
          index: 19,
          title: 'তওবা ও ইস্তিগফার',
          titleEn: 'Repentance & Istighfar',
          description: 'খাঁটি মনে তওবা করুন, অতীতের গুনাহ মাফ হয়ে যাবে।',
          descriptionEn: 'Repent sincerely, and previous sins will be forgiven.',
          hadithOrAyat: '“গুনাহ থেকে তওবাকারী ব্যক্তি যেন নিষ্পাপ।” [ইবনে মাজাহ]',
          hadithOrAyatEn: '“The one who repents from sin is like one without sin.” [Ibn Majah]',
          type: TileType.tawbah,
          icon: Icons.replay,
          color: Color(0xFF06B6D4),
        );

      case 21:
        return const BoardTile(
          index: 21,
          title: 'মিসওয়াক ও পবিত্রতা',
          titleEn: 'Miswak & Purity',
          description: 'পবিত্রতা ঈমানের অঙ্গ এবং আল্লাহর নৈকট্যের উপায়।',
          descriptionEn: 'Cleanliness and purity are part of faith and lead to closeness to Allah.',
          hadithOrAyat: '“পবিত্রতা ঈমানের অর্ধেক।” [মুসলিম]',
          hadithOrAyatEn: '“Purity is half of faith.” [Muslim]',
          type: TileType.goodDeed,
          nekiDelta: 20,
          icon: Icons.water_drop,
          color: Color(0xFF0284C7),
        );

      case 22:
        return const BoardTile(
          index: 22,
          title: 'রোজা (সওম)',
          titleEn: 'Fasting (Sawm)',
          description: 'নফস নিয়ন্ত্রণ ও ধৈর্য অর্জন! রোজার বরকতে ৪ ঘর দ্রুত এগিয়ে গেলেন।',
          descriptionEn: 'Controlling desires and gaining patience! Advanced 4 tiles forward with the blessing of fasting.',
          hadithOrAyat: '“রোজা ঢালস্বরূপ।” [বুখারী ও মুসলিম]',
          hadithOrAyatEn: '“Fasting is a shield.” [Bukhari & Muslim]',
          type: TileType.pillar,
          pillarReward: PillarType.roza,
          nekiDelta: 50,
          jumpTo: 26,
          icon: Icons.nightlight_round,
          color: Color(0xFF7C3AED),
        );

      case 25:
        return const BoardTile(
          index: 25,
          title: 'ইসলামিক কুইজ',
          titleEn: 'Islamic Quiz',
          description: 'দ্বীনি জ্ঞানের উত্তর দিয়ে নেকি বৃদ্ধি করুন।',
          descriptionEn: 'Increase rewards by demonstrating Islamic knowledge.',
          type: TileType.quiz,
          icon: Icons.psychology,
          color: Color(0xFF9333EA),
        );

      case 28:
        return const BoardTile(
          index: 28,
          title: 'অহংকার ও রিয়া (লোকদেখানো আমল)',
          titleEn: 'Arrogance & Showing Off (Riya)',
          description: 'অহংকার জান্নাত থেকে বঞ্চিত করে।',
          descriptionEn: 'Arrogance deprives one from entering Paradise.',
          hadithOrAyat: '“যার অন্তরে কণা পরিমাণ অহংকার থাকবে সে জান্নাতে প্রবেশ করবে না।” [মুসলিম]',
          hadithOrAyatEn: '“No one who has an atom\'s weight of pride will enter Paradise.” [Muslim]',
          type: TileType.sinTrap,
          gunahDelta: 30,
          jumpTo: 17,
          icon: Icons.sentiment_dissatisfied,
          color: Color(0xFF991B1B),
        );

      case 30:
        return const BoardTile(
          index: 30,
          title: 'পিতা-মাতার সেবা',
          titleEn: 'Serving Parents',
          description: 'পিতা-মাতার সন্তুষ্টিতেই আল্লাহর সন্তুষ্টি।',
          descriptionEn: 'The pleasure of Allah lies in the pleasure of parents.',
          hadithOrAyat: '“মায়ের পায়ের নিচে সন্তানের জান্নাত।” [নাসায়ী]',
          hadithOrAyatEn: '“Paradise lies beneath the feet of mothers.” [Nasai]',
          type: TileType.goodDeed,
          nekiDelta: 45,
          jumpTo: 36,
          icon: Icons.family_restroom,
          color: Color(0xFF059669),
        );

      case 33:
        return const BoardTile(
          index: 33,
          title: 'যাকাত প্রদান',
          titleEn: 'Giving Zakat',
          description: 'গরিবের হক আদায় করে নিজের সম্পদ পবিত্র করুন। দ্বিগুণ নেকি বোনাস!',
          descriptionEn: 'Purify your wealth by fulfilling the rights of the poor. Double deeds bonus!',
          hadithOrAyat: '“তোমরা নামাজ কায়েম কর এবং যাকাত প্রদান কর।” [সূরা বাকারা]',
          hadithOrAyatEn: '“Establish prayer and give Zakat.” [Surah Al-Baqarah]',
          type: TileType.pillar,
          pillarReward: PillarType.zakat,
          nekiDelta: 60,
          icon: Icons.volunteer_activism,
          color: Color(0xFFD97706),
        );

      case 35:
        return const BoardTile(
          index: 35,
          title: 'প্রতিবেশীর অধিকার রক্ষা',
          titleEn: 'Rights of Neighbors',
          description: 'প্রতিবেশীর সাথে উত্তম আচরণ করা ঈমানের লক্ষণ।',
          descriptionEn: 'Treating neighbors kindly is a sign of true faith.',
          hadithOrAyat: '“যে আল্লাহ ও পরকালে বিশ্বাস করে সে যেন তার প্রতিবেশীকে কষ্ট না দেয়।” [বুখারী]',
          hadithOrAyatEn: '“Whoever believes in Allah and the Last Day should not harm his neighbor.” [Bukhari]',
          type: TileType.goodDeed,
          nekiDelta: 25,
          icon: Icons.home,
          color: Color(0xFF10B981),
        );

      case 38:
        return const BoardTile(
          index: 38,
          title: 'হারাম উপার্জন ও সুদ',
          titleEn: 'Haram Earnings & Interest (Riba)',
          description: 'হারাম রুজি ইবাদত কবুলের অন্তরায়। শয়তানের ফাঁদে বড় ক্ষতি!',
          descriptionEn: 'Unlawful wealth blocks acceptance of worship. Severe loss in Satan\'s trap!',
          hadithOrAyat: '“আল্লাহ সুদকে ধ্বংস করেন এবং দানকে বর্ধিত করেন।” [সূরা বাকারা]',
          hadithOrAyatEn: '“Allah destroys interest and gives increase for charities.” [Surah Al-Baqarah]',
          type: TileType.sinTrap,
          gunahDelta: 35,
          jumpTo: 24,
          icon: Icons.money_off,
          color: Color(0xFF7F1D1D),
        );

      case 40:
        return const BoardTile(
          index: 40,
          title: 'তওবা ও রোনাজারি',
          titleEn: 'Repentance & Supplication',
          description: 'রাতের আঁধারে আল্লাহর কাছে ক্ষমা প্রার্থনা।',
          descriptionEn: 'Seeking forgiveness from Allah in the darkness of night.',
          type: TileType.tawbah,
          icon: Icons.auto_awesome,
          color: Color(0xFF0EA5E9),
        );

      case 42:
        return const BoardTile(
          index: 42,
          title: 'ইসলামিক কুইজ',
          titleEn: 'Islamic Quiz',
          description: 'আখেরাতের প্রস্তুতিতে বিশেষ কুইজ।',
          descriptionEn: 'Special quiz on preparing for the Hereafter.',
          type: TileType.quiz,
          icon: Icons.school,
          color: Color(0xFF6366F1),
        );

      case 44:
        return const BoardTile(
          index: 44,
          title: 'পবিত্র হজ্ব পালন',
          titleEn: 'Performing Hajj',
          description: 'লাব্বায়েক আল্লাহুম্মা লাব্বায়েক! মাবরুর হজ্বের প্রতিদান কেবলই জান্নাত।',
          descriptionEn: 'Labbayk Allahumma Labbayk! The reward of an accepted Hajj is nothing but Paradise.',
          hadithOrAyat: '“কবুল হজ্বের প্রতিদান জান্নাত ছাড়া আর কিছু নয়।” [বুখারী]',
          hadithOrAyatEn: '“An accepted Hajj has no reward other than Paradise.” [Bukhari]',
          type: TileType.pillar,
          pillarReward: PillarType.hajj,
          nekiDelta: 100,
          icon: Icons.mosque,
          color: Color(0xFFDB2777),
        );

      case 47:
        return const BoardTile(
          index: 47,
          title: 'তাহাজ্জুদ ও জিকির',
          titleEn: 'Tahajjud & Dhikr',
          description: 'গভীর রাতে আল্লাহর স্মরণে মন প্রশান্ত ও মর্যাদা বৃদ্ধি।',
          descriptionEn: 'Remembrance of Allah in the dead of night brings peace of mind and elevates status.',
          hadithOrAyat: '“রমজানের পর সর্বোত্তম রোজা মহররমের এবং ফরজ নামাজের পর সেরা নামাজ তাহাজ্জুদ।” [মুসলিম]',
          hadithOrAyatEn: '“The best prayer after obligatory prayers is the night prayer (Tahajjud).” [Muslim]',
          type: TileType.goodDeed,
          nekiDelta: 35,
          jumpTo: 49,
          icon: Icons.brightness_3,
          color: Color(0xFF047857),
        );

      case 49:
        return const BoardTile(
          index: 49,
          title: 'মিজান (আমলনামা ওজন)',
          titleEn: 'Mizan (Weighing of Deeds)',
          description: 'আখেরাতের চূড়ান্ত বিচারের পাল্লা! নেকির পাল্লা ভারী থাকলে পুলসিরাত পার হওয়া সহজ।',
          descriptionEn: 'The final scale of judgment! If the scale of good deeds is heavy, crossing the Sirat is easy.',
          hadithOrAyat: '“কেয়ামতের দিন আমি ন্যায়ের দাঁড়িপাল্লা স্থাপন করব।” [সূরা আম্বিয়া: ৪৭]',
          hadithOrAyatEn: '“We shall set up scales of justice on the Day of Resurrection.” [Surah Al-Anbiya: 47]',
          type: TileType.mizan,
          icon: Icons.balance,
          color: Color(0xFFF59E0B),
        );

      case 51:
        return const BoardTile(
          index: 51,
          title: 'পুলসিরাত পারাপার',
          titleEn: 'Crossing the Sirat',
          description: 'অন্ধকার পারাপারের একমাত্র আলো হলো আপনার জীবনের নেক আমল ও ঈমান।',
          descriptionEn: 'The only light on this dark crossing is your life\'s righteous deeds and faith.',
          hadithOrAyat: '“মুমিনরা তাদের আমলের আলো অনুযায়ী দ্রুত পুলসিরাত অতিক্রম করবে।” [তিরমিযী]',
          hadithOrAyatEn: '“Believers will cross the Sirat according to the light of their deeds.” [Tirmidhi]',
          type: TileType.sirat,
          icon: Icons.alt_route,
          color: Color(0xFF38BDF8),
        );

      case 52:
        return const BoardTile(
          index: 52,
          title: 'জান্নাতুল ফিরদাউস',
          titleEn: 'Jannat al-Firdous',
          description: 'আলহামদুলিল্লাহ! চির শান্তির অনন্ত নিবাস ও আল্লাহর সন্তুষ্টি।',
          descriptionEn: 'Alhamdulillah! The eternal abode of peace and the pleasure of Allah.',
          hadithOrAyat: '“তাদের জন্য রয়েছে এমন নিয়ামত যা কোনো চোখ দেখেনি, কোনো কান শোনেনি।” [বুখারী]',
          hadithOrAyatEn: '“For them are blessings no eye has seen, and no ear has heard.” [Bukhari]',
          type: TileType.jannah,
          nekiDelta: 200,
          icon: Icons.star,
          color: Color(0xFF10B981),
        );

      default:
        return BoardTile(
          index: i,
          title: 'নিরাপদ ঘর ($i)',
          titleEn: 'Safe Tile ($i)',
          description: 'আল্লাহর স্মরণে জিকির করুন: সুবহানাল্লাহ, আলহামদুলিল্লাহ, আল্লাহু আকবার।',
          descriptionEn: 'Remember Allah with Dhikr: Subhanallah, Alhamdulillah, Allahu Akbar.',
          hadithOrAyat: '“যে ব্যক্তি আল্লাহর জিকির করে আর যে করে না, তাদের তুলনা জীবিত ও মৃতের মতো।” [বুখারী]',
          hadithOrAyatEn: '“The likeness of the one who remembers his Lord and the one who does not is like the living and the dead.” [Bukhari]',
          type: TileType.safe,
          nekiDelta: 5,
          icon: Icons.shield_outlined,
          color: const Color(0xFF34D399),
        );
    }
  }
}
