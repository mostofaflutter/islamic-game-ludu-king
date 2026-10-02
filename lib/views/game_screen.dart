import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_provider.dart';
import '../services/sound_service.dart';
import '../services/tts_service.dart';
import '../widgets/mizan_meter_widget.dart';
import '../widgets/pillar_inventory_widget.dart';
import '../widgets/player_pod_widget.dart';
import '../widgets/islamic_board_widget.dart';
import '../widgets/event_dialog.dart';
import '../widgets/quiz_dialog.dart';
import '../widgets/tawbah_dialog.dart';
import '../widgets/result_dialog.dart';
import '../widgets/share_dialog.dart';
import 'settings_screen.dart';
import 'developer_options_screen.dart';
import '../state/settings_provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isBn = settings.isBangla;

    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final activePlayer = game.currentPlayer;

        // Auto show dialogs based on state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (game.winner != null || game.defeatedPlayer != null) {
            _showResultDialog(context, game);
          } else if (game.activeQuiz != null) {
            _showQuizDialog(context, game);
          } else if (game.showTawbahDialog) {
            _showTawbahDialog(context, game);
          } else if (game.activeEventTile != null) {
            _showEventDialog(context, game);
          }
        });

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldLeave = await _showExitConfirmDialog(context);
            if (shouldLeave == true && context.mounted) {
              TtsService().stop();
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF090D16),
            appBar: AppBar(
              backgroundColor: const Color(0xFF0F172A),
              elevation: 4,
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFBBF24)),
                onPressed: () async {
                  final shouldLeave = await _showExitConfirmDialog(context);
                  if (shouldLeave == true && context.mounted) {
                    TtsService().stop();
                    Navigator.of(context).pop();
                  }
                },
              ),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mosque, color: Color(0xFF34D399), size: 18),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isBn ? 'সফর-এ-জান্নাত' : 'Safar-e-Jannah',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFCD34D),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Card TTS Voice Narration toggle button
                ValueListenableBuilder<bool>(
                  valueListenable: TtsService().isVoiceEnabledNotifier,
                  builder: (context, isVoiceEnabled, child) {
                    return IconButton(
                      icon: Icon(
                        isVoiceEnabled ? Icons.record_voice_over_rounded : Icons.voice_over_off_rounded,
                        color: isVoiceEnabled ? const Color(0xFF34D399) : const Color(0xFF64748B),
                        size: 20,
                      ),
                      tooltip: isBn
                          ? (isVoiceEnabled ? 'কার্ড ভয়েস পাঠ চালু আছে' : 'কার্ড ভয়েস পাঠ বন্ধ')
                          : (isVoiceEnabled ? 'Card voice is ON' : 'Card voice is OFF'),
                      onPressed: () => TtsService().toggleVoiceEnabled(),
                    );
                  },
                ),

                // Sound toggle button
                ValueListenableBuilder<bool>(
                  valueListenable: SoundService().isMutedNotifier,
                  builder: (context, isMuted, child) {
                    return IconButton(
                      icon: Icon(
                        isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: isMuted ? const Color(0xFF94A3B8) : const Color(0xFFFCD34D),
                        size: 20,
                      ),
                      tooltip: isBn
                          ? (isMuted ? 'সাউন্ড চালু করুন' : 'সাউন্ড বন্ধ করুন')
                          : (isMuted ? 'Turn Sound ON' : 'Mute Sound'),
                      onPressed: () => SoundService().toggleMute(),
                    );
                  },
                ),

                // Active player turn indicator badge
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: activePlayer.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: activePlayer.color, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 4.5,
                          backgroundColor: activePlayer.color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isBn
                              ? '${activePlayer.getName(settings.language)} এর চাল'
                              : "${activePlayer.getName(settings.language)}'s Turn",
                          style: TextStyle(
                            color: activePlayer.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick menu for Settings, Dev Options, Share
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                  color: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF334155)),
                  ),
                  onSelected: (value) {
                    if (value == 'settings') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    } else if (value == 'dev') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DeveloperOptionsScreen()),
                      );
                    } else if (value == 'share') {
                      showDialog(
                        context: context,
                        builder: (_) => const ShareDialog(),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          const Icon(Icons.settings_suggest_rounded, color: Color(0xFF10B981), size: 18),
                          const SizedBox(width: 8),
                          Text(isBn ? 'সেটিংস ও অ্যাভাটার' : 'Settings & Avatar', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'dev',
                      child: Row(
                        children: [
                          const Icon(Icons.terminal_rounded, color: Color(0xFF38BDF8), size: 18),
                          const SizedBox(width: 8),
                          Text(isBn ? 'ডেভেলপার অপশন' : 'Developer Options', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          const Icon(Icons.share_rounded, color: Color(0xFFF59E0B), size: 18),
                          const SizedBox(width: 8),
                          Text(isBn ? 'অ্যাপ শেয়ার' : 'Share App', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // 5 Pillars Token Inventory (placed at top in place of Musafir 2 & 3)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
                    child: PillarInventoryWidget(player: activePlayer),
                  ),

                  // Active Player HUD (Mizan Meter)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: MizanMeterWidget(player: activePlayer),
                  ),

                  // Top Players: Player 2 & Player 3 Pods (placed here directly above board)
                  if (game.players.length > 1)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 2, 10, 4),
                      child: _buildTopPlayersRow(game),
                    ),

                  // Middle Interactive Board
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: IslamicBoardWidget(
                        tiles: game.tiles,
                        players: game.players,
                        activePlayerIndex: game.currentPlayerIndex,
                      ),
                    ),
                  ),

                  // Status Log Ticker
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            game.getGameLog(settings.language),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Row: Player 1 & Player 4 Pods
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                    child: _buildBottomPlayersRow(game),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopPlayersRow(GameProvider game) {
    final players = game.players;
    if (players.length <= 1) return const SizedBox.shrink();

    if (players.length == 2) {
      // 2 Players: Player 2 at top
      final p2 = players[1];
      return Row(
        children: [
          Expanded(
            child: PlayerPodWidget(
              player: p2,
              isCurrentTurn: game.currentPlayerIndex == 1,
              diceValue: game.diceValue,
              isRolling: game.isRolling,
              isMoving: game.isMoving,
              onRoll: () => game.rollDice(),
            ),
          ),
        ],
      );
    }

    // 3 or 4 Players: Top Left = Player 2, Top Right = Player 3
    final p2 = players[1];
    final p3 = players.length >= 3 ? players[2] : null;

    return Row(
      children: [
        Expanded(
          child: PlayerPodWidget(
            player: p2,
            isCurrentTurn: game.currentPlayerIndex == 1,
            diceValue: game.diceValue,
            isRolling: game.isRolling,
            isMoving: game.isMoving,
            onRoll: () => game.rollDice(),
          ),
        ),
        const SizedBox(width: 8),
        if (p3 != null)
          Expanded(
            child: PlayerPodWidget(
              player: p3,
              isCurrentTurn: game.currentPlayerIndex == 2,
              diceValue: game.diceValue,
              isRolling: game.isRolling,
              isMoving: game.isMoving,
              onRoll: () => game.rollDice(),
            ),
          )
        else
          const Spacer(),
      ],
    );
  }

  Widget _buildBottomPlayersRow(GameProvider game) {
    final players = game.players;
    final p1 = players.isNotEmpty ? players[0] : null;
    if (p1 == null) return const SizedBox.shrink();

    if (players.length <= 3) {
      // 1, 2 or 3 Players: Player 1 at bottom
      return Row(
        children: [
          Expanded(
            child: PlayerPodWidget(
              player: p1,
              isCurrentTurn: game.currentPlayerIndex == 0,
              diceValue: game.diceValue,
              isRolling: game.isRolling,
              isMoving: game.isMoving,
              onRoll: () => game.rollDice(),
            ),
          ),
        ],
      );
    }

    // 4 Players: Bottom Left = Player 1, Bottom Right = Player 4
    final p4 = players[3];

    return Row(
      children: [
        Expanded(
          child: PlayerPodWidget(
            player: p1,
            isCurrentTurn: game.currentPlayerIndex == 0,
            diceValue: game.diceValue,
            isRolling: game.isRolling,
            isMoving: game.isMoving,
            onRoll: () => game.rollDice(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PlayerPodWidget(
            player: p4,
            isCurrentTurn: game.currentPlayerIndex == 3,
            diceValue: game.diceValue,
            isRolling: game.isRolling,
            isMoving: game.isMoving,
            onRoll: () => game.rollDice(),
          ),
        ),
      ],
    );
  }

  void _showEventDialog(BuildContext context, GameProvider game) {
    final tile = game.activeEventTile;
    if (tile == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EventDialog(
        tile: tile,
        player: game.currentPlayer,
        onDismiss: () {
          Navigator.of(ctx).pop();
          game.dismissEventDialog();
        },
      ),
    );
  }

  void _showQuizDialog(BuildContext context, GameProvider game) {
    final quiz = game.activeQuiz;
    if (quiz == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => QuizDialog(
        question: quiz,
        player: game.currentPlayer,
        onAnswer: (index) {
          Navigator.of(ctx).pop();
          game.answerQuiz(index);
        },
      ),
    );
  }

  void _showTawbahDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TawbahDialog(
        player: game.currentPlayer,
        onTawbah: () {
          Navigator.of(ctx).pop();
          game.performTawbah();
        },
      ),
    );
  }

  void _showResultDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ResultDialog(
        winner: game.winner,
        defeatedPlayer: game.defeatedPlayer,
        onPlayAgain: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
        onRetryTawbah: () {
          Navigator.of(ctx).pop();
          game.retryAfterFailure();
        },
      ),
    );
  }

  Future<bool?> _showExitConfirmDialog(BuildContext context) {
    final isBn = Provider.of<SettingsProvider>(context, listen: false).isBangla;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isBn ? 'খেলা সমাপ্ত করবেন?' : 'Exit Game?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isBn
              ? 'আপনি কি নিশ্চিত যে খেলা ছেড়ে প্রধান মেন্যুতে ফিরে যেতে চান?'
              : 'Are you sure you want to leave the game and return to the main menu?',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              isBn ? 'না, খেলবো' : 'No, Keep Playing',
              style: const TextStyle(color: Color(0xFF10B981)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: Text(isBn ? 'হ্যাঁ, প্রস্থান' : 'Yes, Exit'),
          ),
        ],
      ),
    );
  }
}
