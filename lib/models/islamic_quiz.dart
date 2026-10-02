import '../state/settings_provider.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int rewardNeki;

  final String? questionEn;
  final List<String>? optionsEn;
  final String? explanationEn;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.rewardNeki = 30,
    this.questionEn,
    this.optionsEn,
    this.explanationEn,
  });

  String getQuestion([AppLanguage? lang]) =>
      (lang == AppLanguage.en && questionEn != null) ? questionEn! : question;

  List<String> getOptions([AppLanguage? lang]) =>
      (lang == AppLanguage.en && optionsEn != null) ? optionsEn! : options;

  String getExplanation([AppLanguage? lang]) =>
      (lang == AppLanguage.en && explanationEn != null) ? explanationEn! : explanation;
}

class QuizBank {
  static final List<QuizQuestion> questions = [
    const QuizQuestion(
      question: 'ইসলামের ভিত্তি মোট কয়টি বিষয়ের উপর স্থাপিত?',
      questionEn: 'How many pillars is Islam built upon?',
      options: ['৩টি', '৪টি', '৫টি', '৬টি'],
      optionsEn: ['3', '4', '5', '6'],
      correctIndex: 2,
      explanation: 'ইসলামের ভিত্তি পাঁচটি: কালেমা, নামাজ, রোজা, যাকাত ও হজ্ব।',
      explanationEn: 'Islam is built on five pillars: Kalimah, Salah, Sawm, Zakat, and Hajj.',
      rewardNeki: 25,
    ),
    const QuizQuestion(
      question: 'কোন ফরজ ইবাদতটি প্রতিদিন পাঁচবার আদায় করতে হয়?',
      questionEn: 'Which obligatory act of worship must be performed five times daily?',
      options: ['রোজা', 'নামাজ', 'হজ্ব', 'সাদাকাহ'],
      optionsEn: ['Fasting', 'Prayer (Salah)', 'Hajj', 'Charity'],
      correctIndex: 1,
      explanation: 'দৈনিক ৫ ওয়াক্ত নামাজ আদায় করা প্রতিটি প্রাপ্তবয়স্ক মুসলিমের জন্য ফরজ।',
      explanationEn: 'Performing five daily prayers is obligatory for every adult Muslim.',
      rewardNeki: 25,
    ),
    const QuizQuestion(
      question: 'পবিত্র কুরআনুল কারীমের মোট কতটি সূরা রয়েছে?',
      questionEn: 'How many Surahs are there in the Holy Quran?',
      options: ['১১০টি', '১১৪টি', '১২০টি', '১২৪টি'],
      optionsEn: ['110', '114', '120', '124'],
      correctIndex: 1,
      explanation: 'কুরআন মাজীদে মোট ১১৪টি সূরা রয়েছে।',
      explanationEn: 'There are a total of 114 Surahs in the Holy Quran.',
      rewardNeki: 30,
    ),
    const QuizQuestion(
      question: 'মাহে রমজানে কোন ইবাদতটি ফরজ করা হয়েছে?',
      questionEn: 'Which act of worship is made obligatory during the month of Ramadan?',
      options: ['হজ্ব', 'রোজা (সওম)', 'কুরবানি', 'ইতিকাফ'],
      optionsEn: ['Hajj', 'Fasting (Sawm)', 'Qurbani', 'Itikaf'],
      correctIndex: 1,
      explanation: 'রমজান মাসে পূর্ণ এক মাস সিয়াম বা রোজা পালন করা ফরজ।',
      explanationEn: 'Fasting the whole month of Ramadan is obligatory upon Muslims.',
      rewardNeki: 25,
    ),
    const QuizQuestion(
      question: 'সর্বশ্রেষ্ঠ ও সর্বশেষ নবী ও রাসূল কে?',
      questionEn: 'Who is the greatest and the final Prophet and Messenger of Allah?',
      options: [
        'হযরত ইব্রাহিম (আ.)',
        'হযরত মূসা (আ.)',
        'হযরত ঈসা (আ.)',
        'হযরত মুহাম্মদ (সা.)'
      ],
      optionsEn: [
        'Prophet Ibrahim (AS)',
        'Prophet Musa (AS)',
        'Prophet Isa (AS)',
        'Prophet Muhammad (SAW)'
      ],
      correctIndex: 3,
      explanation: 'হযরত মুহাম্মদ (সা.) হলেন খাতামুন নাবিয়্যীন বা শেষ নবী।',
      explanationEn: 'Prophet Muhammad (SAW) is Khatam an-Nabiyyin, the final Prophet.',
      rewardNeki: 30,
    ),
    const QuizQuestion(
      question: 'ইসলামে নেসাব পরিমাণ সম্পদের উপর শতকরা কত ভাগ যাকাত দেওয়া ফরজ?',
      questionEn: 'What percentage of Zakat is obligatory on wealth reaching Nisab in Islam?',
      options: ['২.৫%', '৫%', '১০%', '১.৫%'],
      optionsEn: ['2.5%', '5%', '10%', '1.5%'],
      correctIndex: 0,
      explanation: 'যাকাতের নির্ধারিত হার হলো শতকরা আড়াই ভাগ বা ২.৫%।',
      explanationEn: 'The prescribed rate of Zakat is 2.5% on qualifying wealth.',
      rewardNeki: 35,
    ),
    const QuizQuestion(
      question: 'কুরআন মাজীদের সর্বপ্রথম নাযিলকৃত আয়াত কোন সূরার?',
      questionEn: 'From which Surah were the very first verses of the Holy Quran revealed?',
      options: ['সূরা ফাতিহা', 'সূরা ইখলাস', 'সূরা আলাক্ব', 'সূরা বাকারা'],
      optionsEn: ['Surah Al-Fatiha', 'Surah Al-Ikhlas', 'Surah Al-Alaq', 'Surah Al-Baqarah'],
      correctIndex: 2,
      explanation: 'হেরা গুহায় সূরা আলাক্বের প্রথম ৫টি আয়াত সর্বপ্রথম নাযিল হয়।',
      explanationEn: 'The first five verses of Surah Al-Alaq were revealed first at Cave Hira.',
      rewardNeki: 35,
    ),
    const QuizQuestion(
      question: 'জান্নাতের সুসংবাদপ্রাপ্ত ১০ জন সাহাবীকে কী বলা হয়?',
      questionEn: 'What are the 10 companions who were promised Paradise called?',
      options: ['আসহাবে সুফফা', 'আশারায়ে মুবাশশারা', 'আনসার', 'মুহাজির'],
      optionsEn: ['Ashab as-Suffah', 'Ashara Mubashshara', 'Ansar', 'Muhajir'],
      correctIndex: 1,
      explanation: 'আশারায়ে মুবাশশারা অর্থ জান্নাতের সুসংবাদপ্রাপ্ত ১০ জন সম্মানিত সাহাবী।',
      explanationEn: 'Ashara Mubashshara means the ten companions given glad tidings of Jannah.',
      rewardNeki: 40,
    ),
  ];

  static QuizQuestion getRandomQuiz() {
    questions.shuffle();
    return questions.first;
  }
}
