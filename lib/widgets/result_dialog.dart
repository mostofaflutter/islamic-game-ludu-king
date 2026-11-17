import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../state/settings_provider.dart';

class ResultDialog extends StatefulWidget {
  final Player? winner;
  final Player? firstWinner;
  final Player? secondWinner;
  final List<Player>? winners;
  final Player? defeatedPlayer;
  final bool isIntermediate;
  final VoidCallback onPlayAgain;
  final VoidCallback onRetryTawbah;
  final VoidCallback? onContinueGame;

  const ResultDialog({
    super.key,
    this.winner,
    this.firstWinner,
    this.secondWinner,
    this.winners,
    this.defeatedPlayer,
    this.isIntermediate = false,
    required this.onPlayAgain,
    required this.onRetryTawbah,
    this.onContinueGame,
  });

  @override
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> {
  @override
  void initState() {
    super.initState();
    final p1 = widget.firstWinner ??
        (widget.winners != null && widget.winners!.isNotEmpty ? widget.winners![0] : widget.winner);
    if (widget.isIntermediate && p1?.isAi == true) {
      Future.delayed(const Duration(milliseconds: 3200), () {
        if (mounted) {
          (widget.onContinueGame ?? widget.onPlayAgain).call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p1 = widget.firstWinner ??
        (widget.winners != null && widget.winners!.isNotEmpty ? widget.winners![0] : widget.winner);
    final p2 = widget.secondWinner ??
        (widget.winners != null && widget.winners!.length > 1 ? widget.winners![1] : null);

    final isDefeated = widget.defeatedPlayer != null;
    final isTwoWinners = !widget.isIntermediate && !isDefeated && p1 != null && p2 != null;
    final isWinner = !isDefeated && p1 != null;

    if (!isDefeated && p1 == null) return const SizedBox.shrink();

    final settings = Provider.of<SettingsProvider>(context);
    final isBn = settings.isBangla;
    final lang = settings.language;

    final primaryColor = isWinner ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    final secondaryColor = isWinner ? const Color(0xFF10B981) : const Color(0xFFF97316);

    String titleText;
    String subtitleText;

    if (isDefeated) {
      titleText = isBn ? '⚠️ আমলনামায় ঘাটতি!' : '⚠️ Deficit in Good Deeds!';
      subtitleText = isBn
          ? '${widget.defeatedPlayer!.getName(lang)} এর নেকির পাল্লা হালকা হয়েছে অথবা প্রয়োজনীয় স্তম্ভ অপূর্ণ রয়েছে।'
          : '${widget.defeatedPlayer!.getName(lang)}\'s scale of Hasanah was light or required pillars are incomplete.';
    } else if (widget.isIntermediate) {
      titleText = isBn ? '🎉 মাশাআল্লাহ! ফার্স্ট উইনার!' : '🎉 MashaAllah! 1st Winner!';
      subtitleText = isBn
          ? '${p1!.getName(lang)} ১ম স্থান অর্জন করেছেন! সেকেন্ড উইনার হওয়ার জন্য বাকিদের খেলা চলবে।'
          : '${p1!.getName(lang)} has secured 1st place! Game continues for 2nd Winner.';
    } else if (isTwoWinners) {
      titleText = isBn ? '🎉 মাশাআল্লাহ! খেলা সমাপ্ত!' : '🎉 MashaAllah! Game Completed!';
      subtitleText = isBn
          ? 'সফলভাবে ১ম ও ২য় বিজয়ী জান্নাতুল ফিরদাউসে পৌঁছেছেন!'
          : '1st & 2nd Winners have reached Jannat al-Firdaus!';
    } else {
      titleText = isBn ? '🎉 মাশাআল্লাহ! মোবারকবাদ!' : '🎉 MashaAllah! Congratulations!';
      subtitleText = isBn
          ? '${p1!.getName(lang)} সফলভাবে জান্নাতুল ফিরদাউসের দ্বারে পৌঁছেছেন!'
          : '${p1!.getName(lang)} has successfully reached the gates of Jannat al-Firdaus!';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: const TextStyle(
            decoration: TextDecoration.none,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Badge
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      size: 42,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    subtitleText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFE2E8F0),
                      height: 1.4,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Player Cards
                  if (isDefeated) ...[
                    _buildStatsBox(widget.defeatedPlayer!, isBn),
                  ] else if (isTwoWinners) ...[
                    _buildWinnerCard(
                      player: p1,
                      rankLabel: isBn ? '🥇 ফার্স্ট উইনার (১ম স্থান)' : '🥇 1st Winner (1st Place)',
                      medalColor: const Color(0xFFF59E0B),
                      rankIcon: Icons.emoji_events,
                      lang: lang,
                      isBn: isBn,
                    ),
                    const SizedBox(height: 10),
                    _buildWinnerCard(
                      player: p2,
                      rankLabel: isBn ? '🥈 সেকেন্ড উইনার (২য় স্থান)' : '🥈 2nd Winner (2nd Place)',
                      medalColor: const Color(0xFF38BDF8),
                      rankIcon: Icons.military_tech,
                      lang: lang,
                      isBn: isBn,
                    ),
                  ] else if (widget.isIntermediate) ...[
                    _buildWinnerCard(
                      player: p1!,
                      rankLabel: isBn ? '🥇 ফার্স্ট উইনার (১ম স্থান)' : '🥇 1st Winner (1st Place)',
                      medalColor: const Color(0xFFF59E0B),
                      rankIcon: Icons.emoji_events,
                      lang: lang,
                      isBn: isBn,
                    ),
                  ] else ...[
                    _buildWinnerCard(
                      player: p1!,
                      rankLabel: isBn ? '🥇 ফার্স্ট উইনার (বিজয়ী)' : '🥇 1st Winner',
                      medalColor: const Color(0xFFF59E0B),
                      rankIcon: Icons.emoji_events,
                      lang: lang,
                      isBn: isBn,
                    ),
                  ],

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
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFFCD34D),
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Action Buttons
                  if (widget.isIntermediate) ...[
                    ElevatedButton.icon(
                      onPressed: widget.onContinueGame ?? widget.onPlayAgain,
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: Text(
                        isBn ? 'খেলা কন্টিনিউ করুন (২য় বিজয়ী)' : 'Continue Game (2nd Winner)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ] else if (isWinner) ...[
                    ElevatedButton.icon(
                      onPressed: widget.onPlayAgain,
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
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: widget.onPlayAgain,
                      child: Text(
                        isBn ? 'প্রধান মেন্যুতে ফিরে যান' : 'Return to Main Menu',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: widget.onRetryTawbah,
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
                      onPressed: widget.onPlayAgain,
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
      ),
    );
  }

  Widget _buildWinnerCard({
    required Player player,
    required String rankLabel,
    required Color medalColor,
    required IconData rankIcon,
    required AppLanguage lang,
    required bool isBn,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: medalColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: medalColor.withValues(alpha: 0.15),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: medalColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: medalColor, width: 1.2),
                ),
                child: Icon(rankIcon, color: medalColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rankLabel,
                      style: TextStyle(
                        color: medalColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      player.getName(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(isBn ? 'নেকি' : 'Hasanah', '${player.neki}', const Color(0xFF34D399), Icons.add_circle),
              _statItem(isBn ? 'গুনাহ' : 'Sins', '${player.gunah}', const Color(0xFFF87171), Icons.remove_circle),
              _statItem(isBn ? 'স্তম্ভ' : 'Pillars', '${player.collectedPillars.length}/5', const Color(0xFFFBBF24), Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBox(Player player, bool isBn) {
    return Container(
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
