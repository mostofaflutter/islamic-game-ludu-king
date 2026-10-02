import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../services/tts_service.dart';
import '../state/settings_provider.dart';

class TawbahDialog extends StatefulWidget {
  final Player player;
  final VoidCallback onTawbah;

  const TawbahDialog({
    super.key,
    required this.player,
    required this.onTawbah,
  });

  @override
  State<TawbahDialog> createState() => _TawbahDialogState();
}

class _TawbahDialogState extends State<TawbahDialog> with SingleTickerProviderStateMixin {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && TtsService().isVoiceEnabled) {
          final settings = Provider.of<SettingsProvider>(context, listen: false);
          TtsService().speakTawbah(language: settings.language);
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
      TtsService().speakTawbah(language: settings.language);
    }
  }

  void _handleTawbah() {
    TtsService().stop();
    widget.onTawbah();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isBn = settings.isBangla;
    final avatar = settings.currentAvatar;

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
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0F172A), Color(0xFF022C22)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF0EA5E9), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 42,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      isBn ? 'তওবা ও ইস্তিগফার' : 'Repentance & Istighfar',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF38BDF8),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      isBn
                          ? '“হে ঈমানদারগণ! তোমরা আল্লাহর কাছে খাঁটি তওবা করো, আশা করা যায় তোমাদের প্রতিপালক তোমাদের পাপসমূহ ক্ষমা করে দেবেন।”'
                          : '“O you who believe! Turn to Allah with sincere repentance, perhaps your Lord will expiate from you your sins.”',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFFCD34D),
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isBn
                            ? 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ\n“আস্তাগফিরুল্লাহাল আজিম ওয়া আতূবু ইলাইহি”'
                            : 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ\n“Astaghfirullah al-Azeem wa atoobu ilayh”',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF67E8F9),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            isBn ? '✨ ৫০% গুনাহ মাফ' : '✨ 50% Sins Forgiven',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            isBn ? '✨ +৩০ নেকি বোনাস' : '✨ +30 Hasanah Bonus',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Audio Reader Action Pill with Narrator Avatar
                    ValueListenableBuilder<bool>(
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
                                      ? (isBn
                                          ? '${avatar.getName(settings.language)} পাঠ করছেন...'
                                          : '${avatar.getName(settings.language)} is reading...')
                                      : (isBn
                                          ? '${avatar.getName(settings.language)} এর কণ্ঠে শুনুন'
                                          : 'Listen with ${avatar.getName(settings.language)}'),
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
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _handleTawbah,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        isBn ? 'তওবা কবুল করুন' : 'Accept Repentance',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                        color: isSpeaking ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
                        size: 24,
                      ),
                      tooltip: isSpeaking
                          ? (isBn ? 'ভয়েস বন্ধ করুন' : 'Stop voice')
                          : (isBn ? 'পড়ে শোনান' : 'Read aloud'),
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
}
