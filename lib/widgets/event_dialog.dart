import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/board_tile.dart';
import '../models/player.dart';
import '../services/tts_service.dart';
import '../state/settings_provider.dart';

class EventDialog extends StatefulWidget {
  final BoardTile tile;
  final Player player;
  final VoidCallback onDismiss;

  const EventDialog({
    super.key,
    required this.tile,
    required this.player,
    required this.onDismiss,
  });

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto read after a short delay so the dialog animation completes smoothly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && TtsService().isVoiceEnabled) {
          final settings = Provider.of<SettingsProvider>(context, listen: false);
          TtsService().speakTile(widget.tile, language: settings.language);
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    TtsService().stop();
    super.dispose();
  }

  void _toggleAudio() {
    if (TtsService().isSpeaking) {
      TtsService().stop();
    } else {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      TtsService().speakTile(widget.tile, language: settings.language);
    }
  }

  void _dismissAndNextTurn() {
    TtsService().stop();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isBn = settings.isBangla;
    final lang = settings.language;
    final tile = widget.tile;
    final player = widget.player;
    final isGood = tile.gunahDelta == 0 && tile.type != TileType.sinTrap;
    final primaryColor = isGood
        ? (tile.color == const Color(0xFF1E293B) ? const Color(0xFF34D399) : tile.color)
        : const Color(0xFFEF4444);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: const TextStyle(
            decoration: TextDecoration.none,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  // বর্ডারের সবুজ রঙের দাগ ও স্ট্রাইপ দূর করতে বর্ডার হালকা করা হয়েছে
                  border: Border.all(
                    color: const Color(0xFF1E293B),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        tile.icon,
                        size: 42,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      tile.getTitle(lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      tile.getDescription(lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE2E8F0),
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),

                    if (tile.getHadithOrAyat(lang) != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Text(
                          tile.getHadithOrAyat(lang)!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFFCD34D),
                            height: 1.35,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Rewards / Penalties indicator
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (tile.nekiDelta > 0)
                          _badge(isBn ? '+${tile.nekiDelta} নেকি' : '+${tile.nekiDelta} Hasanah', const Color(0xFF10B981), Icons.add_circle),
                        if (tile.gunahDelta > 0)
                          _badge(
                            player.hasShield
                                ? (isBn ? 'শিল্ড দ্বারা রদ!' : 'Blocked by Shield!')
                                : (isBn ? '+${tile.gunahDelta} গুনাহ' : '+${tile.gunahDelta} Sins'),
                            player.hasShield ? Colors.blue : const Color(0xFFEF4444),
                            player.hasShield ? Icons.shield : Icons.warning,
                          ),
                        if (tile.pillarReward != null)
                          _badge(
                            isBn ? '${tile.pillarReward!.nameBn} অর্জিত!' : '${tile.pillarReward!.getName(AppLanguage.en)} Unlocked!',
                            const Color(0xFFF59E0B),
                            Icons.star,
                          ),
                        if (tile.isLadder)
                          _badge(
                            isBn ? 'সিঁড়ি দিয়ে ${tile.jumpTo} এ গমন!' : 'Climbed to ${tile.jumpTo}!',
                            const Color(0xFF38BDF8),
                            Icons.north,
                          ),
                        if (tile.isSnake)
                          _badge(
                            isBn ? 'পিছলে ${tile.jumpTo} এ পতন!' : 'Slid down to ${tile.jumpTo}!',
                            const Color(0xFFF87171),
                            Icons.south,
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Audio Reader Action Pill with Narrator Avatar
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        final avatar = settings.currentAvatar;
                        final isBn = settings.isBangla;

                        return ValueListenableBuilder<bool>(
                          valueListenable: TtsService().isSpeakingNotifier,
                          builder: (context, isSpeaking, child) {
                            return InkWell(
                              onTap: _toggleAudio,
                              borderRadius: BorderRadius.circular(24),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSpeaking
                                      ? avatar.color.withValues(alpha: 0.2)
                                      : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSpeaking ? avatar.color : const Color(0xFF475569),
                                    width: 1.4,
                                  ),
                                  boxShadow: isSpeaking
                                      ? [
                                    BoxShadow(
                                      color: avatar.color.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSpeaking)
                                      ScaleTransition(
                                        scale: _pulseScale,
                                        child: Icon(avatar.icon, color: avatar.color, size: 18),
                                      )
                                    else
                                      Icon(avatar.icon, color: avatar.color, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      isSpeaking
                                          ? (isBn ? '${avatar.getName(settings.language)} পাঠ করছেন...' : '${avatar.getName(settings.language)} is reading...')
                                          : (isBn ? '${avatar.getName(settings.language)} এর কণ্ঠে শুনুন' : 'Listen with ${avatar.getName(settings.language)}'),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSpeaking ? avatar.color : const Color(0xFFCBD5E1),
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      isSpeaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                                      color: isSpeaking ? avatar.color : const Color(0xFF94A3B8),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // Button to proceed to next turn
                    ElevatedButton(
                      onPressed: _dismissAndNextTurn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isGood ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(180, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isBn ? 'চালিয়ে যান' : 'Continue',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Speaker Quick-Toggle button in top-right corner
              Positioned(
                top: 12,
                right: 12,
                child: ValueListenableBuilder<bool>(
                  valueListenable: TtsService().isSpeakingNotifier,
                  builder: (context, isSpeaking, child) {
                    return IconButton(
                      icon: Icon(
                        isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                        color: isSpeaking ? const Color(0xFF34D399) : const Color(0xFF64748B),
                        size: 24,
                      ),
                      tooltip: isSpeaking ? (isBn ? 'ভয়েস বন্ধ করুন' : 'Stop voice') : (isBn ? 'পড়ে শোনান' : 'Read aloud'),
                      onPressed: _toggleAudio,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}