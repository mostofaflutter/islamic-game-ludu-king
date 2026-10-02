import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../state/settings_provider.dart';

class PlayerPodWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentTurn;
  final int diceValue;
  final bool isRolling;
  final bool isMoving;
  final VoidCallback onRoll;

  const PlayerPodWidget({
    super.key,
    required this.player,
    required this.isCurrentTurn,
    required this.diceValue,
    required this.isRolling,
    required this.isMoving,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final bool canRoll = isCurrentTurn && !player.isAi && !isRolling && !isMoving;

    return GestureDetector(
      onTap: canRoll ? onRoll : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentTurn
              ? player.color.withValues(alpha: 0.18)
              : const Color(0xFF0F172A).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentTurn ? player.color : const Color(0xFF334155),
            width: isCurrentTurn ? 2.2 : 1.2,
          ),
          boxShadow: isCurrentTurn
              ? [
            BoxShadow(
              color: player.color.withValues(alpha: 0.45),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Player Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar + Name + Roll Prompt
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: player.color,
                          shape: BoxShape.circle,
                          boxShadow: isCurrentTurn
                              ? [
                            BoxShadow(
                              color: player.color.withValues(alpha: 0.6),
                              blurRadius: 8,
                            )
                          ]
                              : [],
                        ),
                        child: Icon(
                          player.isAi ? Icons.smart_toy : Icons.person,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          player.getName(settings.language),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCurrentTurn ? Colors.white : const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Neki, Pillars & Tap to Roll hint
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          '🌟 ${player.neki}',
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ⭐️ ${player.collectedPillars.length}/5',
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (player.hasShield) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.shield, color: Colors.blueAccent, size: 12),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Dice Box
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCurrentTurn
                      ? [const Color(0xFFFBBF24), const Color(0xFFD97706)]
                      : [const Color(0xFF475569), const Color(0xFF334155)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrentTurn ? Colors.white : Colors.white24,
                  width: isCurrentTurn ? 1.5 : 1,
                ),
                boxShadow: isCurrentTurn
                    ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Center(
                child: isCurrentTurn && isRolling
                    ? const Icon(
                  Icons.casino,
                  size: 26,
                  color: Colors.white,
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: const Duration(milliseconds: 250))
                    : _buildMiniDiceFace(isCurrentTurn ? diceValue : 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniDiceFace(int val) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniDot(val >= 2),
              _miniDot(false),
              _miniDot(val >= 4),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniDot(val == 6),
              _miniDot(val % 2 == 1),
              _miniDot(val == 6),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniDot(val >= 4),
              _miniDot(false),
              _miniDot(val >= 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniDot(bool visible) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: visible ? Colors.white : Colors.transparent,
        shape: BoxShape.circle,
      ),
    );
  }
}
