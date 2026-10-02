import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_provider.dart';
import '../state/settings_provider.dart';
import '../services/sound_service.dart';
import '../widgets/app_drawer.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _playerCount = 2;
  bool _vsAi = true;
  bool? _lastIsBn;
  final List<TextEditingController> _nameControllers = [
    TextEditingController(text: 'মুসাফির ১'),
    TextEditingController(text: 'মুসাফির ২'),
    TextEditingController(text: 'মুসাফির ৩'),
    TextEditingController(text: 'মুসাফির ৪'),
  ];

  void _syncDefaultNames(bool isBn) {
    if (_lastIsBn == isBn) return;
    _lastIsBn = isBn;

    final defaultBn = ['মুসাফির ১', 'মুসাফির ২', 'মুসাফির ৩', 'মুসাফির ৪'];
    final defaultEn = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];

    for (int i = 0; i < _nameControllers.length; i++) {
      final current = _nameControllers[i].text.trim();
      if (isBn && (current.isEmpty || defaultEn.contains(current))) {
        _nameControllers[i].text = defaultBn[i];
      } else if (!isBn && (current.isEmpty || defaultBn.contains(current))) {
        _nameControllers[i].text = defaultEn[i];
      }
    }
  }

  @override
  void dispose() {
    for (var c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    final game = Provider.of<GameProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final names = _nameControllers.map((c) => c.text.trim()).toList();
    game.startNewGame(
      playerCount: _vsAi ? 2 : _playerCount,
      vsAi: _vsAi,
      customNames: names,
      language: settings.language,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isBn = settings.isBangla;
    final avatar = settings.currentAvatar;
    _syncDefaultNames(isBn);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      drawer: AppDrawer(
        onOpenRules: () => _showRulesDialog(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Drawer Hamburger Button, Narrator Badge, Sound Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Drawer Hamburger Menu Button
                  Builder(
                    builder: (innerContext) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: IconButton(
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: Color(0xFFFCD34D),
                            size: 24,
                          ),
                          tooltip: isBn ? 'মেনু খুলুন' : 'Open Menu',
                          onPressed: () => Scaffold.of(innerContext).openDrawer(),
                        ),
                      );
                    },
                  ),

                  // Active Narrator Avatar Badge
                  InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: avatar.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: avatar.color.withValues(alpha: 0.6), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(avatar.icon, color: avatar.color, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            avatar.getName(settings.language),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: avatar.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sound toggle
                  ValueListenableBuilder<bool>(
                    valueListenable: SoundService().isMutedNotifier,
                    builder: (context, isMuted, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: IconButton(
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: const EdgeInsets.all(6),
                          icon: Icon(
                            isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            color: isMuted ? const Color(0xFF94A3B8) : const Color(0xFFFCD34D),
                            size: 22,
                          ),
                          tooltip: isMuted
                              ? (isBn ? 'সাউন্ড চালু করুন' : 'Unmute sound')
                              : (isBn ? 'সাউন্ড বন্ধ করুন' : 'Mute sound'),
                          onPressed: () => SoundService().toggleMute(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Hero Islamic Emblem Banner
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.35),
                        blurRadius: 28,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/islamicgameludoking.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        padding: const EdgeInsets.all(22),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Color(0xFF065F46), Color(0xFF022C22), Color(0xFF090D16)],
                          ),
                        ),
                        child: const Icon(
                          Icons.mosque,
                          size: 64,
                          color: Color(0xFFFCD34D),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isBn ? 'সফর-এ-জান্নাত' : 'Safar-e-Jannah',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFCD34D),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isBn
                    ? 'সিরাতুল মুস্তাকীমের পথে ইসলামের ৫টি স্তম্ভ নিয়ে জান্নাতের সন্ধানে'
                    : 'Journey on Sirat-ul-Mustaqeem with the 5 Pillars of Islam to Jannah',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 24),

              // Mode Selection Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'খেলার ধরণ নির্বাচন করুন:' : 'Select Game Mode:',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _modeOption(
                            title: isBn ? 'সোলো মোড' : 'Solo Mode',
                            subtitle: isBn ? 'বনাম AI' : 'vs AI',
                            icon: Icons.smart_toy,
                            isSelected: _vsAi,
                            onTap: () => setState(() => _vsAi = true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _modeOption(
                            title: isBn ? 'পাস অ্যান্ড প্লে' : 'Pass & Play',
                            subtitle: isBn ? 'পরিবার/বন্ধু' : 'Family/Friends',
                            icon: Icons.groups,
                            isSelected: !_vsAi,
                            onTap: () => setState(() => _vsAi = false),
                          ),
                        ),
                      ],
                    ),

                    if (!_vsAi) ...[
                      const SizedBox(height: 16),
                      Text(
                        isBn ? 'খেলোয়াড় সংখ্যা:' : 'Player Count:',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [2, 3, 4].map((count) {
                          final isSelected = _playerCount == count;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkWell(
                                onTap: () => setState(() => _playerCount = count),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFF334155),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected) ...[
                                          const Icon(Icons.check, size: 16, color: Colors.white),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          isBn ? '$count জন' : '$count Players',
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Player Name Inputs
                    Text(
                      isBn ? 'খেলোয়াড়দের নাম:' : 'Player Names:',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_vsAi ? 1 : _playerCount, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextField(
                          controller: _nameControllers[index],
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1E293B),
                            prefixIcon: Icon(
                              Icons.person,
                              color: index == 0
                                    ? const Color(0xFF10B981)
                                    : index == 1
                                    ? const Color(0xFF3B82F6)
                                    : index == 2
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFEC4899),
                              size: 20,
                            ),
                            hintText: isBn ? 'খেলোয়াড় ${index + 1} এর নাম' : 'Player ${index + 1} Name',
                            hintStyle: const TextStyle(color: Colors.white38),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Start Journey Button
              ElevatedButton.icon(
                onPressed: _startGame,
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(
                  isBn ? 'বিসমিল্লাহ বলে শুরু করুন' : 'Start Journey with Bismillah',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  shadowColor: const Color(0xFF10B981).withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 12),

              // Rules & How to play
              OutlinedButton.icon(
                onPressed: () => _showRulesDialog(context),
                icon: const Icon(Icons.menu_book, size: 18),
                label: Text(isBn ? 'গেমের নিয়মাবলী ও ৫ স্তম্ভের গাইড' : 'Game Rules & 5 Pillars Guide'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFCD34D),
                  side: const BorderSide(color: Color(0xFFD97706)),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF334155),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF94A3B8), size: 28),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    final isBn = Provider.of<SettingsProvider>(context, listen: false).isBangla;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: Color(0xFFFCD34D)),
            const SizedBox(width: 8),
            Text(
              isBn ? 'খেলার নিয়মাবলী' : 'Game Rules',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isBn ? '১. লক্ষ্য (Ultimate Goal):' : '1. Ultimate Goal:',
                style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                isBn
                    ? 'দুনিয়ার জীবন থেকে ৫২টি ঘর অতিক্রম করে ৫টি স্তম্ভের আইটেম সংগ্রহ ও নেকির পাল্লা ভারী করে জান্নাতে প্রবেশ করা।'
                    : 'Traverse 52 tiles from worldly life, collect all 5 pillars of Islam, keep the scale heavy with Hasanah, and enter Jannah.',
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              Text(
                isBn ? '২. ৫টি স্তম্ভের আইটেম পাওয়ার ক্ষমতা:' : '2. Powers of the 5 Pillars:',
                style: const TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                isBn
                    ? '• কালেমা: যাত্রা শুরুর চাবিকাঠি।\n• নামাজ: ৩ চালের জন্য গুনাহ থেকে প্রটেকশন শিল্ড।\n• রোজা: নফস নিয়ন্ত্রণ ও সরাসরি ৪ ঘর জাম্প।\n• যাকাত: সম্পদ পবিত্র ও দ্বিগুণ নেকি বোনাস।\n• হজ্ব: মেগা নেকি (+১০০) ও পূর্বের পাপ ক্ষমা।'
                    : '• Kalimah: Key to faith and beginning of the journey.\n• Salah: Protection shield guarding against sin traps for 3 turns.\n• Sawm: Self-restraint and a fast 4-tile forward leap.\n• Zakat: Purifies wealth and awards 2x Hasanah bonus.\n• Hajj: Mega reward (+100 Hasanah) and pardon of past sins.',
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              Text(
                isBn ? '৩. মিজান ও আখেরাত:' : '3. Mizan & The Hereafter:',
                style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                isBn
                    ? 'শেষ প্রান্তে মিজান ও পুলসিরাতে নেকি ও গুনাহর বিচার হবে। নেকি বেশি থাকলে জান্নাতুল ফিরদাউসের বিজয় ঘোষিত হবে।'
                    : 'At the final stage at Mizan and Sirat, good deeds and sins are weighed. Having more Hasanah secures victory in Jannat al-Firdaus.',
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isBn ? 'বুঝেছি' : 'Got It'),
          ),
        ],
      ),
    );
  }
}
