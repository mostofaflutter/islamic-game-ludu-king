import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../state/settings_provider.dart';

class MizanMeterWidget extends StatelessWidget {
  final Player player;

  const MizanMeterWidget({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isBn = settings.isBangla;
    final ratio = player.mizanRatio;
    final nekiPercent = (ratio * 100).toInt();
    final gunahPercent = 100 - nekiPercent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.balance, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      isBn ? 'মিজান:' : 'Mizan:',
                      style: const TextStyle(
                        color: Color(0xFFFCD34D),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (player.hasShield) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield, color: Colors.blueAccent, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              isBn ? 'শিল্ড (${player.salahShieldTurns})' : 'Shield (${player.salahShieldTurns})',
                              style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  player.getName(settings.language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: player.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  // Neki Portion (Green)
                  Expanded(
                    flex: (ratio * 100).round().clamp(1, 100),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                        ),
                      ),
                    ),
                  ),
                  // Gunah Portion (Red)
                  Expanded(
                    flex: ((1.0 - ratio) * 100).round().clamp(1, 100),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_upward, color: Color(0xFF10B981), size: 14),
                  Text(
                    isBn
                        ? 'নেকি: ${player.neki} ($nekiPercent%)'
                        : 'Hasanah: ${player.neki} ($nekiPercent%)',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    isBn
                        ? 'গুনাহ: ${player.gunah} ($gunahPercent%)'
                        : 'Sins: ${player.gunah} ($gunahPercent%)',
                    style: const TextStyle(
                      color: Color(0xFFF87171),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Icon(Icons.arrow_downward, color: Color(0xFFEF4444), size: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
