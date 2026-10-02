import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DiceWidget extends StatelessWidget {
  final int value;
  final bool isRolling;
  final bool isEnabled;
  final VoidCallback onRoll;

  const DiceWidget({
    super.key,
    required this.value,
    required this.isRolling,
    required this.isEnabled,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && !isRolling ? onRoll : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isEnabled
                    ? [const Color(0xFFFBBF24), const Color(0xFFD97706), const Color(0xFFB45309)]
                    : [const Color(0xFF64748B), const Color(0xFF475569)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: isEnabled
                  ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
                  : [],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: isRolling
                  ? const Icon(
                Icons.casino,
                size: 40,
                color: Colors.white,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: const Duration(milliseconds: 300))
                  : _buildDiceFace(value),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isEnabled ? const Color(0xFF10B981) : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isEnabled
                  ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
                  : [],
            ),
            child: Text(
              isRolling ? 'ঘুরছে...' : (isEnabled ? 'চাল দিন' : 'অপেক্ষা করুন'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceFace(int val) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dotSize = constraints.maxWidth * 0.22;
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 _dot(val >= 2, dotSize),
                  _dot(false, dotSize),
                  _dot(val >= 4, dotSize),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dot(val == 6, dotSize),
                  _dot(val % 2 == 1, dotSize),
                  _dot(val == 6, dotSize),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dot(val >= 4, dotSize),
                 _dot(false, dotSize),
                  _dot(val >= 2, dotSize),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dot(bool visible, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: visible ? Colors.white : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: visible
            ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
          )
        ]
            : [],
      ),
    );
  }
}
