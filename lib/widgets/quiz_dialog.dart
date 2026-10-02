import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/islamic_quiz.dart';
import '../models/player.dart';
import '../services/tts_service.dart';
import '../state/settings_provider.dart';

class QuizDialog extends StatefulWidget {
  final QuizQuestion question;
  final Player player;
  final Function(int) onAnswer;

  const QuizDialog({
    super.key,
    required this.question,
    required this.player,
    required this.onAnswer,
  });

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog> {
  int? _selectedIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && TtsService().isVoiceEnabled) {
          final settings = Provider.of<SettingsProvider>(context, listen: false);
          TtsService().speakQuiz(widget.question, language: settings.language);
        }
      });
    });
  }

  @override
  void dispose() {
    TtsService().stop();
    super.dispose();
  }

  void _toggleSpeak() {
    if (TtsService().isSpeaking) {
      TtsService().stop();
    } else {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      TtsService().speakQuiz(widget.question, language: settings.language);
    }
  }

  void _handleSelect(int index) {
    if (_answered) return;
    TtsService().stop();
    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        widget.onAnswer(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isBn = settings.isBangla;
    final lang = settings.language;
    final questionText = widget.question.getQuestion(lang);
    final optionsList = widget.question.getOptions(lang);
    final explanationText = widget.question.getExplanation(lang);

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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.psychology, color: Color(0xFFC084FC), size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'ইসলামিক কুইজ' : 'Islamic Quiz',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC084FC),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                isBn
                                    ? '+${widget.question.rewardNeki} নেকি'
                                    : '+${widget.question.rewardNeki} Hasanah',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: settings.currentAvatar.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(settings.currentAvatar.icon, size: 11, color: settings.currentAvatar.color),
                                    const SizedBox(width: 3),
                                    Text(
                                      settings.currentAvatar.getName(settings.language),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: settings.currentAvatar.color,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: TtsService().isSpeakingNotifier,
                      builder: (context, isSpeaking, child) {
                        return IconButton(
                          icon: Icon(
                            isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                            color: isSpeaking ? const Color(0xFFC084FC) : const Color(0xFF64748B),
                            size: 24,
                          ),
                          tooltip: isSpeaking ? (isBn ? 'ভয়েস বন্ধ করুন' : 'Stop voice') : (isBn ? 'প্রশ্নটি পড়ে শোনান' : 'Read Question'),
                          onPressed: _toggleSpeak,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Question Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Text(
                    questionText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Options
                ...List.generate(optionsList.length, (index) {
                  final optionText = optionsList[index];
                  Color borderColor = const Color(0xFF334155);
                  Color bgColor = const Color(0xFF1E293B);
                  Color textColor = Colors.white;

                  if (_answered) {
                    if (index == widget.question.correctIndex) {
                      borderColor = const Color(0xFF10B981);
                      bgColor = const Color(0xFF10B981).withValues(alpha: 0.2);
                      textColor = const Color(0xFF34D399);
                    } else if (index == _selectedIndex) {
                      borderColor = const Color(0xFFEF4444);
                      bgColor = const Color(0xFFEF4444).withValues(alpha: 0.2);
                      textColor = const Color(0xFFF87171);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => _handleSelect(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: borderColor,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                optionText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            if (_answered && index == widget.question.correctIndex)
                              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                            if (_answered && index == _selectedIndex && index != widget.question.correctIndex)
                              const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                if (_answered) ...[
                  const SizedBox(height: 8),
                  Text(
                    explanationText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFCD34D),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
