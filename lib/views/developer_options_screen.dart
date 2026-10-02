import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_provider.dart';
import '../state/settings_provider.dart';
import '../services/sound_service.dart';
import '../services/tts_service.dart';

class DeveloperOptionsScreen extends StatefulWidget {
  const DeveloperOptionsScreen({super.key});

  @override
  State<DeveloperOptionsScreen> createState() => _DeveloperOptionsScreenState();
}

class _DeveloperOptionsScreenState extends State<DeveloperOptionsScreen> {
  int _selectedTileIndex = 0;
  final TextEditingController _ttsTestController =
      TextEditingController(text: 'আলহামদুলিল্লাহ! সফর-এ-জান্নাত গেমের ভয়েস টেস্ট সফল হয়েছে।');

  @override
  void dispose() {
    _ttsTestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, SettingsProvider>(
      builder: (context, game, settings, child) {
        final isBn = settings.isBangla;
        final hasActiveGame = game.players.isNotEmpty;
        final player = hasActiveGame ? game.currentPlayer : null;

        return Scaffold(
          backgroundColor: const Color(0xFF090D16),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 4,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCD34D), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.terminal_rounded, color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 8),
                Text(
                  isBn ? 'ডেভেলপার অপশন' : 'Developer Options',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFFCD34D),
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF34D399), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn
                              ? '🛠️ ডিবাগ টুলস: গেমের প্রতিটি ইভেন্ট, ডাইস, সাউন্ড ও বিজয় দৃশ্য টেস্ট করুন।'
                              : '🛠️ Debug Tools: Test every event, dice roll, sound, and victory scene.',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 1. Current Player Overview
                if (hasActiveGame && player != null) ...[
                  _buildSectionHeader(
                    icon: Icons.person_rounded,
                    title: isBn ? 'বর্তমান সক্রিয় খেলোয়াড়' : 'Current Active Player',
                    subtitle: '${player.name} (ঘর #${player.position})',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: player.color.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              player.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: player.color),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: player.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                player.isAi ? 'AI' : 'Human',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: player.color),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statChip('নেকি', '${player.neki}', const Color(0xFF10B981)),
                            _statChip('গুনাহ', '${player.gunah}', const Color(0xFFEF4444)),
                            _statChip('স্তম্ভ', '${player.collectedPillars.length}/5', const Color(0xFFF59E0B)),
                            _statChip('শিল্ড', player.hasShield ? '${player.salahShieldTurns} চাল' : 'বন্ধ', Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Dice Manipulation
                  _buildSectionHeader(
                    icon: Icons.casino_rounded,
                    title: isBn ? 'ডাইস ফোর্স রোল (Cheat Roll)' : 'Force Dice Roll',
                    subtitle: isBn ? 'যেকোনো নম্বরে ক্লিক করলে সরাসরি সেই চাল দেবে' : 'Tap to force specific roll and move',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [1, 2, 3, 4, 5, 6].map((dice) {
                      return InkWell(
                        onTap: () {
                          game.devRollSpecificDice(dice);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isBn ? 'ডাইস $dice চাল দেওয়া হয়েছে!' : 'Forced dice $dice rolled!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF065F46), Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF34D399)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            '$dice',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 3. Tile Teleport / Jump
                  _buildSectionHeader(
                    icon: Icons.flight_takeoff_rounded,
                    title: isBn ? 'সরাসরি নির্দিষ্ট ঘরে জাম্প' : 'Jump Directly to Tile',
                    subtitle: isBn ? 'যেকোনো বিশেষ ঘটনা টেস্ট করতে ট্যাপ করুন' : 'Teleport active player to any tile',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _jumpChip(context, game, 4, 'টাইল ৪ (দান-সদকা)'),
                      _jumpChip(context, game, 10, 'টাইল ১০ (গীবত - সাপ)'),
                      _jumpChip(context, game, 15, 'টাইল ১৫ (কুরআন - সিঁড়ি)'),
                      _jumpChip(context, game, 18, 'টাইল ১৮ (নামাজ স্তম্ভ)'),
                      _jumpChip(context, game, 26, 'টাইল ২৬ (রোজা স্তম্ভ)'),
                      _jumpChip(context, game, 35, 'টাইল ৩৫ (যাকাত স্তম্ভ)'),
                      _jumpChip(context, game, 42, 'টাইল ৪২ (হজ্ব স্তম্ভ)'),
                      _jumpChip(context, game, 45, 'টাইল ৪৫ (তওবা)'),
                      _jumpChip(context, game, 50, 'টাইল ৫০ (মিজান বিচার)'),
                      _jumpChip(context, game, 51, 'টাইল ৫১ (পুলসিরাত)'),
                      _jumpChip(context, game, 52, 'টাইল ৫২ (জান্নাত বিজয়!)'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Custom Slider Jump
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _selectedTileIndex.toDouble(),
                          min: 0,
                          max: 52,
                          divisions: 52,
                          label: 'Tile $_selectedTileIndex',
                          activeColor: const Color(0xFFF59E0B),
                          inactiveColor: const Color(0xFF334155),
                          onChanged: (val) {
                            setState(() {
                              _selectedTileIndex = val.toInt();
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          game.devJumpToTile(_selectedTileIndex);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isBn ? 'টাইল $_selectedTileIndex এ জাম্প করা হয়েছে!' : 'Jumped to tile $_selectedTileIndex!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(isBn ? '$_selectedTileIndex এ জাম্প' : 'Jump to $_selectedTileIndex'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. Player State Modifier
                  _buildSectionHeader(
                    icon: Icons.auto_fix_high_rounded,
                    title: isBn ? 'প্লেয়ার স্ট্যাটাস এডিটর' : 'Player State Modifiers',
                    subtitle: isBn ? 'পয়েন্ট ও স্তম্ভ তাত্ক্ষণিকভাবে পরিবর্তন করুন' : 'Instantly modify points and pillars',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.add_circle, color: Color(0xFF10B981), size: 18),
                        label: const Text('+৫০ নেকি'),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        onPressed: () => game.devAddNeki(50),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.add_circle, color: Color(0xFF10B981), size: 18),
                        label: const Text('+১০০ নেকি'),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        onPressed: () => game.devAddNeki(100),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.cleaning_services_rounded, color: Color(0xFF38BDF8), size: 18),
                        label: const Text('গুনাহ শূন্য (০) করুন'),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        onPressed: () => game.devClearGunah(),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                        label: const Text('+২০ গুনাহ'),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        onPressed: () => game.devAddGunah(20),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                        label: const Text('৫টি স্তম্ভই আনলক'),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        onPressed: () => game.devUnlockAllPillars(),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.shield_rounded, color: Colors.blue, size: 18),
                        label: const Text('শিল্ড অন/অফ'),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        onPressed: () => game.devToggleShield(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isBn
                          ? 'গেম বোর্ডে প্রবেশের পর প্লেয়ার সংক্রান্ত টুলস সক্রিয় হবে। তবে অডিও ও ডায়াগনস্টিক টেস্ট নিচে এখনই করতে পারেন।'
                          : 'Player manipulation tools activate once a game is started. Audio diagnostics are available below.',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 5. Soundboard Audio Diagnostics
                _buildSectionHeader(
                  icon: Icons.music_note_rounded,
                  title: isBn ? 'সাউন্ডবোর্ড টেস্ট (Soundboard)' : 'Soundboard Audio Test',
                  subtitle: isBn ? 'গেমের প্রতিটি অডিও ক্লিপ টেস্ট করুন' : 'Test every sound effect in the game',
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _soundChip('🎲 ডাইস রোল', () => SoundService().playDiceRoll()),
                    _soundChip('👣 চালের শব্দ', () => SoundService().playStep()),
                    _soundChip('✨ নেকি অর্জন', () => SoundService().playNeki()),
                    _soundChip('🕋 স্তম্ভ আনলক', () => SoundService().playPillar()),
                    _soundChip('⚠️ গুনাহ সতর্কবার্তা', () => SoundService().playSinWarning()),
                    _soundChip('🤲 তওবা সুর', () => SoundService().playTawbah()),
                    _soundChip('✅ কুইজ সঠিক', () => SoundService().playQuizCorrect()),
                    _soundChip('❌ কুইজ ভুল', () => SoundService().playQuizWrong()),
                    _soundChip('🏆 বিজয় সঙ্গীত', () => SoundService().playVictory()),
                  ],
                ),
                const SizedBox(height: 20),

                // 6. TTS Speech Console
                _buildSectionHeader(
                  icon: Icons.record_voice_over_rounded,
                  title: isBn ? 'টিটিএস ভয়েস কনসোল' : 'TTS Voice Console',
                  subtitle: isBn ? 'বর্তমান অ্যাভাটার দিয়ে কাস্টম টেক্সট পড়ুন' : 'Test custom speech with active avatar',
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ttsTestController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    hintText: 'টেক্সট লিখুন...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF334155)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF334155)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          TtsService().speak(_ttsTestController.text.trim());
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(isBn ? 'টেক্সট পড়ুন' : 'Speak Text'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => TtsService().stop(),
                      icon: const Icon(Icons.stop_rounded, size: 20),
                      label: Text(isBn ? 'থামুন' : 'Stop'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 7. System Diagnostic Info
                _buildSectionHeader(
                  icon: Icons.info_rounded,
                  title: isBn ? 'সিস্টেম ও বিল্ড তথ্য' : 'System & Build Info',
                  subtitle: 'App & Environment Diagnostics',
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: const Column(
                    children: [
                      _InfoRow(label: 'App Name', value: 'Safar-e-Jannah'),
                      _InfoRow(label: 'Version', value: '1.0.0+1'),
                      _InfoRow(label: 'Flutter SDK', value: '3.32.7 (Stable)'),
                      _InfoRow(label: 'Dart SDK', value: '3.8.1'),
                      _InfoRow(label: 'Total Tiles', value: '52 + Jannah'),
                      _InfoRow(label: 'Theme', value: 'Dark Islamic Emerald'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF34D399), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _jumpChip(BuildContext context, GameProvider game, int tile, String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: const TextStyle(color: Color(0xFFFCD34D), fontSize: 11.5, fontWeight: FontWeight.w600),
      side: const BorderSide(color: Color(0xFF334155)),
      onPressed: () {
        game.devJumpToTile(tile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('জাম্প করা হলো: $label'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  Widget _soundChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFCBD5E1))),
        ],
      ),
    );
  }
}
