import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../state/settings_provider.dart';

class ResultDialog extends StatelessWidget {
  final Player? winner;
  final Player? defeatedPlayer;
  final VoidCallback onPlayAgain;
  final VoidCallback onRetryTawbah;

  const ResultDialog({
    super.key,
    this.winner,
    this.defeatedPlayer,
    required this.onPlayAgain,
    required this.onRetryTawbah,
  });

  @override
  Widget build(BuildContext context) {
    final isWinner = winner != null;
    final player = winner ?? defeatedPlayer;

    if (player == null) return const SizedBox.shrink();

    final settings = Provider.of<SettingsProvider>(context);
    final isBn = settings.isBangla;
    final lang = settings.language;

    final primaryColor = isWinner ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    final secondaryColor = isWinner ? const Color(0xFF10B981) : const Color(0xFFF97316);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: const TextStyle(
            decoration: TextDecoration.none,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isWinner
                    ? const [Color(0xFF0F172A), Color(0xFF064E3B)]
                    : const [Color(0xFF0F172A), Color(0xFF450A0A)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Badge
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(
                    isWinner ? Icons.emoji_events : Icons.warning_amber_rounded,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  isWinner
                      ? (isBn ? '🎉 মাশাআল্লাহ! মোবারকবাদ!' : '🎉 MashaAllah! Congratulations!')
                      : (isBn ? '⚠️ আমলনামায় ঘাটতি!' : '⚠️ Deficit in Good Deeds!'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  isWinner
                      ? (isBn
                          ? '${player.getName(lang)} সফলভাবে জান্নাতুল ফিরদাউসের দ্বারে পৌঁছেছেন!'
                          : '${player.getName(lang)} has successfully reached the gates of Jannat al-Firdaus!')
                      : (isBn
                          ? '${player.getName(lang)} এর নেকির পাল্লা হালকা হয়েছে অথবা প্রয়োজনীয় স্তম্ভ অপূর্ণ রয়েছে।'
                          : '${player.getName(lang)}\'s scale of Hasanah was light or required pillars are incomplete.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE2E8F0),
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 16),

                // Player Stats Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem(isBn ? 'নেকি' : 'Hasanah', '${player.neki}', const Color(0xFF34D399), Icons.add_circle),
                      _statItem(isBn ? 'গুনাহ' : 'Sins', '${player.gunah}', const Color(0xFFF87171), Icons.remove_circle),
                      _statItem(isBn ? 'স্তম্ভ' : 'Pillars', '${player.collectedPillars.length}/5', const Color(0xFFFBBF24), Icons.star),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Hadith/Ayat Quote Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: secondaryColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    isWinner
                        ? (isBn
                            ? '“নিশ্চয়ই যারা ঈমান এনেছে ও সৎকাজ করেছে, তাদের আতিথেয়তার জন্য রয়েছে জান্নাতুল ফিরদাউস।” (সূরা কাহাফ: ১০৭)'
                            : '“Indeed, those who believed and did righteous deeds - they will have the Gardens of Paradise as a lodging.” (Surah Al-Kahf: 107)')
                        : (isBn
                            ? '“তোমরা আল্লাহর রহমত থেকে নিরাশ হয়ো না। নিশ্চয়ই আল্লাহ সমস্ত গুনাহ ক্ষমা করে দেন।” (সূরা যুমার: ৫৩)'
                            : '“Do not despair of the mercy of Allah. Indeed, Allah forgives all sins.” (Surah Az-Zumar: 53)'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFFCD34D),
                      height: 1.4,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                if (isWinner) ...[
                  ElevatedButton.icon(
                    onPressed: onPlayAgain,
                    icon: const Icon(Icons.replay),
                    label: Text(
                      isBn ? 'আবার খেলুন' : 'Play Again',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: onRetryTawbah,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(
                      isBn ? 'তওবা করে আবার চেষ্টা করুন' : 'Repent and Try Again',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onPlayAgain,
                    child: Text(
                      isBn ? 'প্রধান মেন্যুতে ফিরে যান' : 'Return to Main Menu',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
