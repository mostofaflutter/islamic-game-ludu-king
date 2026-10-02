import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/settings_provider.dart';
import '../views/settings_screen.dart';
import 'share_dialog.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onOpenRules;

  const AppDrawer({super.key, this.onOpenRules});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isBn = settings.isBangla;
        final avatar = settings.currentAvatar;

        return Drawer(
          backgroundColor: const Color(0xFF090D16),
          child: Column(
            children: [
              // 1. Islamic Gradient Drawer Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF022C22), Color(0xFF090D16)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF10B981), width: 1.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F172A),
                            border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/islamicgameludoking.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.mosque,
                                color: Color(0xFFFCD34D),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'সফর-এ-জান্নাত' : 'Safar-e-Jannah',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFCD34D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                isBn ? 'সিরাতুল মুস্তাকীমের পথে' : 'Path of Sirat-ul-Mustaqeem',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Active Narrator Avatar Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: avatar.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: avatar.color.withValues(alpha: 0.7), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(avatar.icon, color: avatar.color, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            isBn ? 'কার্ড পাঠক: ' : 'Narrator: ',
                            style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
                          ),
                          Text(
                            avatar.getName(settings.language),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: avatar.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  children: [
                    // Setting Option
                    _buildDrawerTile(
                      icon: Icons.settings_suggest_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: isBn ? 'সেটিংস' : 'Settings',
                      subtitle: isBn ? 'ভাষা ও কার্ড রিডার অ্যাভাটার' : 'Language & Narrator Avatar',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),


                    // Share App Option
                    _buildDrawerTile(
                      icon: Icons.share_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: isBn ? 'অ্যাপ শেয়ার' : 'Share App',
                      subtitle: isBn ? 'পরিবার ও বন্ধুদের সাথে শেয়ার করুন' : 'Share with family & friends',
                      onTap: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (_) => const ShareDialog(),
                        );
                      },
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Divider(color: Color(0xFF1E293B)),
                    ),

                    // Rules Guide Option
                    if (onOpenRules != null)
                      _buildDrawerTile(
                        icon: Icons.menu_book_rounded,
                        iconColor: const Color(0xFFC084FC),
                        title: isBn ? 'গেমের নিয়মাবলী' : 'Game Rules',
                        subtitle: isBn ? '৫টি স্তম্ভ ও মিজানের গাইড' : '5 Pillars & Mizan guide',
                        onTap: () {
                          Navigator.of(context).pop();
                          onOpenRules!();
                        },
                      ),

                    // Voice narration quick toggle in drawer
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: SwitchListTile(
                        value: settings.isVoiceEnabled,
                        activeColor: const Color(0xFF10B981),
                        title: Text(
                          isBn ? 'কার্ড ভয়েস পাঠ' : 'Card Voice Reading',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        secondary: Icon(
                          settings.isVoiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: settings.isVoiceEnabled ? const Color(0xFF10B981) : const Color(0xFF64748B),
                          size: 20,
                        ),
                        onChanged: (val) => settings.setVoiceEnabled(val),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                ),
                child: Column(
                  children: [
                    Text(
                      isBn
                          ? '“তোমরা সৎকাজে একে অপরের সাহায্য করো।”'
                          : '“Help one another in acts of piety.”',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isBn
                          ? 'সংস্করণ ১.০.০+১ (সিরাতুল মুস্তাকীম)'
                          : 'Version 1.0.0+1 (Sirat-ul-Mustaqeem)',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF475569), size: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }
}
