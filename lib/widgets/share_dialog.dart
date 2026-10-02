import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/share_service.dart';
import '../state/settings_provider.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;
    final isBn = lang == AppLanguage.bn;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: const TextStyle(
            decoration: TextDecoration.none,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                      ),
                      child: const Icon(Icons.share_rounded, color: Color(0xFFFCD34D), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'সফর-এ-জান্নাত শেয়ার করুন' : 'Share Safar-e-Jannah',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFCD34D),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            isBn
                                ? 'সদকায়ে জারিয়া হিসেবে পরিবার ও বন্ধুদের আমন্ত্রণ জানান'
                                : 'Invite family and friends as Sadaqah Jariyah',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Message Preview Box
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      ShareService.getShareMessage(lang),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFCBD5E1),
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ShareService.copyToClipboard(context, language: lang);
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text(
                          isBn ? 'কপি করুন' : 'Copy Text',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFCD34D),
                          side: const BorderSide(color: Color(0xFFD97706)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ShareService.shareApp(context, language: lang);
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          isBn ? 'শেয়ার করুন' : 'Share Now',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
