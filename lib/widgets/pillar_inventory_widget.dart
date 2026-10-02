import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../state/settings_provider.dart';

class PillarInventoryWidget extends StatelessWidget {
  final Player player;

  const PillarInventoryWidget({super.key, required this.player});

  int _getPillarTileNumber(PillarType pillar) {
    switch (pillar) {
      case PillarType.kalima:
        return 0;
      case PillarType.namaz:
        return 7;
      case PillarType.roza:
        return 22;
      case PillarType.zakat:
        return 33;
      case PillarType.hajj:
        return 44;
    }
  }

  void _showPillarDetails(BuildContext context, PillarType pillar, bool isUnlocked) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isBn = settings.isBangla;
    final lang = settings.language;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: pillar.color.withValues(alpha: 0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: pillar.color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Icon & Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: pillar.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: pillar.color, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: pillar.color.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(pillar.icon, color: pillar.color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pillar.getName(lang),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: pillar.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isUnlocked ? const Color(0xFF10B981) : Colors.white24,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isUnlocked
                                ? (isBn ? '✨ অর্জিত হয়েছে (${player.getName(lang)})' : '✨ Unlocked (${player.getName(lang)})')
                                : (isBn
                                    ? '🔒 এখনো অর্জন করা হয়নি (ঘর নং: ${_getPillarTileNumber(pillar)})'
                                    : '🔒 Not yet unlocked (Tile: ${_getPillarTileNumber(pillar)})'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isUnlocked ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'স্তম্ভের তাৎপর্য ও গেম বোনাস:' : 'Significance & Game Bonus:',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFCD34D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pillar.getDescription(lang),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFFE2E8F0),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pillar.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isBn ? 'ঠিক আছে' : 'OK',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isBn = settings.isBangla;
    final lang = settings.language;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'ইসলামের ৫টি স্তম্ভ (টোকেন):' : '5 Pillars of Islam (Tokens):',
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                isBn ? '${player.collectedPillars.length}/5 অর্জিত' : '${player.collectedPillars.length}/5 Collected',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: PillarType.values.map((pillar) {
              final isUnlocked = player.collectedPillars.contains(pillar);
              return Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 3),
                message: '${pillar.getName(lang)}\n${pillar.getDescription(lang)}',
                child: InkWell(
                  onTap: () => _showPillarDetails(context, pillar, isUnlocked),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? pillar.color.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isUnlocked ? pillar.color : Colors.white24,
                        width: isUnlocked ? 2 : 1,
                      ),
                      boxShadow: isUnlocked
                          ? [
                        BoxShadow(
                          color: pillar.color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                          : [],
                    ),
                    child: Icon(
                      pillar.icon,
                      size: 20,
                      color: isUnlocked ? pillar.color : Colors.white30,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
