import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/board_tile.dart';
import '../models/player.dart';
import '../state/settings_provider.dart';

class IslamicBoardWidget extends StatefulWidget {
  final List<BoardTile> tiles;
  final List<Player> players;
  final int activePlayerIndex;

  const IslamicBoardWidget({
    super.key,
    required this.tiles,
    required this.players,
    required this.activePlayerIndex,
  });

  @override
  State<IslamicBoardWidget> createState() => _IslamicBoardWidgetState();
}

class _IslamicBoardWidgetState extends State<IslamicBoardWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant IslamicBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll to active player position
    if (widget.players.isNotEmpty && widget.activePlayerIndex < widget.players.length) {
      final activePos = widget.players[widget.activePlayerIndex].position;
      final targetRow = (activePos / 6).floor();
      final estimatedOffset = (8 - targetRow) * 78.0;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          estimatedOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    // Generate 9 rows (6 tiles per row, snake pattern from bottom to top)
    const int cols = 6;
    const int totalRows = 9;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: List.generate(totalRows, (rowIndex) {
              // Row 0 is top row (Tile 48 to 52)
              // Row 8 is bottom row (Tile 0 to 5)
              final actualRow = (totalRows - 1) - rowIndex;
              final isLeftToRight = actualRow % 2 == 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(cols, (colIndex) {
                    final actualCol = isLeftToRight ? colIndex : (cols - 1 - colIndex);
                    final tileIndex = actualRow * cols + actualCol;

                    if (tileIndex > 52) {
                      return const Expanded(child: SizedBox(height: 72));
                    }

                    final tile = widget.tiles[tileIndex];
                    final playersOnTile = widget.players.where((p) => p.position == tileIndex).toList();

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: _buildTile(tile, playersOnTile, lang),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BoardTile tile, List<Player> playersOnTile, AppLanguage lang) {
    final isJannah = tile.type == TileType.jannah;
    final isStart = tile.type == TileType.start;
    final isPillar = tile.type == TileType.pillar;
    final isSin = tile.type == TileType.sinTrap;
    final isLadder = tile.isLadder;

    Color tileBg = const Color(0xFF1E293B);
    Color borderColor = const Color(0xFF334155);

    if (isJannah) {
      tileBg = const Color(0xFF065F46);
      borderColor = const Color(0xFF34D399);
    } else if (isStart) {
      tileBg = const Color(0xFF047857);
      borderColor = const Color(0xFF10B981);
    } else if (isPillar) {
      tileBg = tile.color.withValues(alpha: 0.25);
      borderColor = tile.color;
    } else if (isSin) {
      tileBg = const Color(0xFF7F1D1D).withValues(alpha: 0.3);
      borderColor = const Color(0xFFEF4444);
    } else if (isLadder) {
      tileBg = const Color(0xFF075985).withValues(alpha: 0.3);
      borderColor = const Color(0xFF38BDF8);
    }

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isJannah || isPillar
            ? [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 0.5,
          )
        ]
            : [],
      ),
      child: Stack(
        children: [
          // Index badge
          Positioned(
            top: 2,
            left: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${tile.index}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Jump indicator (Ladder / Snake)
          if (tile.jumpTo != null)
            Positioned(
              top: 2,
              right: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: isLadder ? const Color(0xFF0284C7) : const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLadder ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                      size: 8,
                    ),
                    Text(
                      '${tile.jumpTo}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Center Icon & Title
          Positioned.fill(
            top: 12,
            bottom: playersOnTile.isNotEmpty ? 18 : 2,
            left: 2,
            right: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tile.icon,
                  size: 16,
                  color: isJannah ? const Color(0xFF34D399) : tile.color,
                ),
                const SizedBox(height: 1),
                Text(
                  tile.getTitle(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isJannah ? const Color(0xFF6EE7B7) : Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Players on this tile
          if (playersOnTile.isNotEmpty)
            Positioned(
              bottom: 2,
              left: 2,
              right: 2,
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 1.5,
                  runSpacing: 1.5,
                  children: playersOnTile.map((player) {
                    final isActive = widget.players.isNotEmpty &&
                        widget.players[widget.activePlayerIndex].id == player.id;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: player.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? Colors.white : Colors.black87,
                          width: isActive ? 1.5 : 0.8,
                        ),
                        boxShadow: isActive
                            ? [
                          BoxShadow(
                            color: player.color.withValues(alpha: 0.8),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ]
                            : [],
                      ),
                      child: Icon(
                        player.isAi ? Icons.smart_toy : Icons.person,
                        size: isActive ? 9 : 8,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
