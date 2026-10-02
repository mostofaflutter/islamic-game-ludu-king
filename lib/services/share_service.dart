import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../state/settings_provider.dart';

class ShareService {
  static const String appTitleBn = 'সফর-এ-জান্নাত: সিরাতুল মুস্তাকীম';
  static const String appTitleEn = 'Safar-e-Jannah: Sirat-ul-Mustaqeem';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.islamic.safar_e_jannah';

  static String getShareSubject(AppLanguage language) {
    return language == AppLanguage.bn
        ? 'সফর-এ-জান্নাত: সিরাতুল মুস্তাকীম - ইসলামিক বোর্ড গেম'
        : 'Safar-e-Jannah: Sirat-ul-Mustaqeem - Islamic Board Game';
  }

  static String getShareMessage(AppLanguage language) {
    if (language == AppLanguage.bn) {
      return '''✨ আসসালামু আলাইকুম ওয়া রাহমাতুল্লাহ! 🕌

🎮 *সফর-এ-জান্নাত: সিরাতুল মুস্তাকীম* — একটি অনবদ্য ইসলামিক পারিবারিক বোর্ড গেম!

🕋 ইসলামের ৫টি মূল স্তম্ভ (কালেমা, নামাজ, রোজা, যাকাত, হজ্ব) অর্জন করুন
📖 কুরআন ও সুন্নাহর আলোকে নেকি বৃদ্ধি ও গুনাহ বর্জনের রোমাঞ্চকর যাত্রা
⚖️ আখেরাতের মিজান ও পুলসিরাত পার হয়ে জান্নাতুল ফিরদাউসের চূড়ান্ত বিজয়!

পরিবার ও বন্ধুদের সাথে জ্ঞান ও আনন্দের এই যাত্রা শুরু করতে এখনই ডাউনলোড করুন:
📲 $playStoreUrl

"তোমরা সৎকাজে একে অপরকে সাহায্য করো।" — [সূরা আল-মায়েদা: ২]''';
    } else {
      return '''✨ Assalamu Alaikum wa Rahmatullah! 🕌

🎮 *Safar-e-Jannah: Sirat-ul-Mustaqeem* — An engaging Islamic family board game!

🕋 Collect the 5 Pillars of Islam (Shahada, Salah, Sawm, Zakat, Hajj)
📖 An inspiring journey to earn Hasanah and avoid sins guided by Quran & Sunnah
⚖️ Cross the Mizan and Sirat bridge to reach the ultimate victory in Jannah!

Download today and share this blessed journey with your family & friends:
📲 $playStoreUrl

"Help one another in acts of piety and righteousness." — [Surah Al-Ma'idah: 2]''';
    }
  }

  /// Trigger system share dialog
  static Future<void> shareApp(BuildContext context, {AppLanguage language = AppLanguage.bn}) async {
    final message = getShareMessage(language);
    final subject = getShareSubject(language);

    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      // ignore: deprecated_member_use
      await Share.share(
        message,
        subject: subject,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      // Fallback: Copy to clipboard if system share fails
      if (context.mounted) {
        await copyToClipboard(context, language: language);
      }
    }
  }

  /// Copy share text to device clipboard
  static Future<void> copyToClipboard(BuildContext context, {AppLanguage language = AppLanguage.bn}) async {
    final message = getShareMessage(language);
    await Clipboard.setData(ClipboardData(text: message));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  language == AppLanguage.bn
                      ? 'শেয়ার মেসেজ ক্লিপবোর্ডে কপি করা হয়েছে!'
                      : 'Share message copied to clipboard!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF064E3B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
