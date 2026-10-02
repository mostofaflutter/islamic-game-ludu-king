import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sound_service.dart';
import '../state/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final lang = settings.language;
        final isBn = lang == AppLanguage.bn;

        return Scaffold(
          backgroundColor: const Color(0xFF090D16),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 4,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCD34D), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              isBn ? 'সেটিংস ও পছন্দসমূহ' : 'Settings & Preferences',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFFFCD34D),
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Language Section
                _buildSectionHeader(
                  icon: Icons.language_rounded,
                  title: isBn ? 'ভাষা নির্বাচন (Language)' : 'Language Selection',
                  subtitle: isBn
                      ? 'অ্যাপের ভাষা ও কার্ড পাঠের ভাষা নির্ধারণ করুন'
                      : 'Choose app language and card reading language',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageCard(
                        title: 'বাংলা',
                        subtitle: 'ডিফল্ট ভাষা',
                        flagEmoji: '🇧🇩',
                        isSelected: isBn,
                        onTap: () => settings.setLanguage(AppLanguage.bn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLanguageCard(
                        title: 'English',
                        subtitle: 'International',
                        flagEmoji: '🇬🇧',
                        isSelected: !isBn,
                        onTap: () => settings.setLanguage(AppLanguage.en),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Card Reader Narrator Avatar Section
                _buildSectionHeader(
                  icon: Icons.record_voice_over_rounded,
                  title: isBn ? 'কার্ড রিডার অ্যাভাটার' : 'Card Narrator Avatar',
                  subtitle: isBn
                      ? 'কার্ড যে পড়ে শোনাচ্ছে তাকে পরিবর্তন করুন'
                      : 'Choose who reads the event and quiz cards out loud',
                ),
                const SizedBox(height: 12),

                ...settings.availableAvatars.map((avatar) {
                  final isSelected = settings.currentAvatar.id == avatar.id;
                  return _buildAvatarCard(
                    context: context,
                    avatar: avatar,
                    isSelected: isSelected,
                    isBn: isBn,
                    settings: settings,
                  );
                }),
                const SizedBox(height: 20),

                // 3. Audio & Voice Settings
                _buildSectionHeader(
                  icon: Icons.tune_rounded,
                  title: isBn ? 'সাউন্ড ও ভয়েস কন্ট্রোল' : 'Sound & Voice Controls',
                  subtitle: isBn ? 'অডিও ও পাঠের গতি নিয়ন্ত্রণ করুন' : 'Fine-tune sound and speech parameters',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    children: [
                      // Voice narration toggle
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          isBn ? 'কার্ড ভয়েস পাঠ চালু রাখুন' : 'Enable Card Voice Narration',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        subtitle: Text(
                          isBn
                              ? 'কার্ড ও কুইজ আসলে নির্বাচিত অ্যাভাটার পড়ে শোনাবে'
                              : 'Selected avatar automatically reads out cards',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                        value: settings.isVoiceEnabled,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (val) => settings.setVoiceEnabled(val),
                      ),

                      if (settings.isVoiceEnabled) ...[
                        const SizedBox(height: 6),
                        // Avatar Voice Volume Slider with live preview button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.record_voice_over_rounded, size: 16, color: Color(0xFF34D399)),
                                    const SizedBox(width: 6),
                                    Text(
                                      isBn ? 'অ্যাভাটার ভয়েস সাউন্ড:' : 'Avatar Voice Volume:',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        '${(settings.ttsVolume * 100).round()}%',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => settings.previewAvatarVoice(settings.currentAvatar),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E293B),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF334155)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFF38BDF8)),
                                            const SizedBox(width: 4),
                                            Text(
                                              isBn ? 'টেস্ট' : 'Test',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF38BDF8)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Slider(
                              value: settings.ttsVolume,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              activeColor: const Color(0xFF10B981),
                              inactiveColor: const Color(0xFF334155),
                              onChanged: (val) => settings.setTtsVolume(val),
                            ),
                          ],
                        ),
                      ],

                      const Divider(color: Color(0xFF1E293B)),

                      // Sound effects toggle
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          isBn ? 'গেম সাউন্ড ইফেক্টস' : 'Game Sound Effects',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        subtitle: Text(
                          isBn ? 'ডাইস রোল, চালের শব্দ, নেকি, সতর্কবার্তা ও বিজয়' : 'Dice rolls, steps, coins, alerts and victory',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                        value: settings.isSoundEnabled,
                        activeColor: const Color(0xFFF59E0B),
                        onChanged: (val) => settings.setSoundEnabled(val),
                      ),

                      if (settings.isSoundEnabled) ...[
                        const SizedBox(height: 6),
                        // Game Sound Volume Slider with live preview button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.music_note_rounded, size: 16, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 6),
                                    Text(
                                      isBn ? 'গেম সাউন্ড ভলিউম:' : 'Game SFX Volume:',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        '${(settings.soundVolume * 100).round()}%',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => SoundService().playNeki(),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E293B),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF334155)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.play_arrow_rounded, size: 14, color: Color(0xFFF59E0B)),
                                            const SizedBox(width: 4),
                                            Text(
                                              isBn ? 'টেস্ট' : 'Test',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Slider(
                              value: settings.soundVolume,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              activeColor: const Color(0xFFF59E0B),
                              inactiveColor: const Color(0xFF334155),
                              onChanged: (val) => settings.setSoundVolume(val),
                            ),
                          ],
                        ),
                      ],

                      const Divider(color: Color(0xFF1E293B)),

                      // Speech Rate Slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isBn ? 'পড়ার গতি (Speech Rate):' : 'Speech Rate:',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
                              ),
                              Text(
                                '${settings.speechRateMultiplier.toStringAsFixed(2)}x',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                              ),
                            ],
                          ),
                          Slider(
                            value: settings.speechRateMultiplier,
                            min: 0.7,
                            max: 1.4,
                            divisions: 7,
                            activeColor: const Color(0xFF10B981),
                            inactiveColor: const Color(0xFF334155),
                            onChanged: (val) => settings.setSpeechRateMultiplier(val),
                          ),
                        ],
                      ),

                      // Pitch Slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isBn ? 'কণ্ঠস্বরের সুর (Pitch):' : 'Voice Pitch:',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
                              ),
                              Text(
                                '${settings.pitchMultiplier.toStringAsFixed(2)}x',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                              ),
                            ],
                          ),
                          Slider(
                            value: settings.pitchMultiplier,
                            min: 0.7,
                            max: 1.4,
                            divisions: 7,
                            activeColor: const Color(0xFF38BDF8),
                            inactiveColor: const Color(0xFF334155),
                            onChanged: (val) => settings.setPitchMultiplier(val),
                          ),
                        ],
                      ),
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF34D399), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required String subtitle,
    required String flagEmoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.18) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E293B),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(flagEmoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard({
    required BuildContext context,
    required NarratorAvatar avatar,
    required bool isSelected,
    required bool isBn,
    required SettingsProvider settings,
  }) {
    final themeColor = avatar.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () => settings.setAvatar(avatar),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? themeColor.withValues(alpha: 0.15) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? themeColor : const Color(0xFF1E293B),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.25),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Avatar Icon Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColor, width: 1.5),
                ),
                child: Icon(avatar.icon, color: themeColor, size: 26),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            avatar.getName(settings.language),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            avatar.getTitle(settings.language),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: themeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      avatar.getDescription(settings.language),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Preview button and Selection status
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Test Voice Button
                  OutlinedButton.icon(
                    onPressed: () => settings.previewAvatarVoice(avatar),
                    icon: const Icon(Icons.volume_up_rounded, size: 14),
                    label: Text(
                      isBn ? 'শুনুন' : 'Test',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeColor,
                      side: BorderSide(color: themeColor.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(60, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isBn ? 'নির্বাচিত' : 'Selected',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    )
                  else
                    const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFF475569), size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
