import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/board_tile.dart';
import '../models/islamic_quiz.dart';
import '../services/sound_service.dart';
import '../services/tts_service.dart';
import 'settings_provider.dart';

class GameProvider extends ChangeNotifier {
  final SoundService soundService = SoundService();
  final List<BoardTile> tiles = BoardData.generateBoard();
  List<Player> _players = [];
  int _currentPlayerIndex = 0;
  int _diceValue = 1;
  bool _isRolling = false;
  bool _isMoving = false;

  BoardTile? _activeEventTile;
  QuizQuestion? _activeQuiz;
  String _gameLogBn = 'বিসমিল্লাহ বলে খেলা শুরু করুন!';
  String _gameLogEn = 'Start the game with Bismillah!';
  Player? _winner;
  Player? _defeatedPlayer;
  bool _showTawbahDialog = false;

  // Getters
  List<Player> get players => _players;
  int get currentPlayerIndex => _currentPlayerIndex;
  Player get currentPlayer => _players.isNotEmpty
      ? _players[_currentPlayerIndex]
      : Player(id: 0, nameBn: 'খেলোয়াড়', nameEn: 'Player', color: Colors.green);
  int get diceValue => _diceValue;
  bool get isRolling => _isRolling;
  bool get isMoving => _isMoving;
  BoardTile? get activeEventTile => _activeEventTile;
  QuizQuestion? get activeQuiz => _activeQuiz;
  String get gameLog => _gameLogBn;
  String getGameLog([AppLanguage? lang]) => (lang == AppLanguage.en) ? _gameLogEn : _gameLogBn;
  Player? get winner => _winner;
  Player? get defeatedPlayer => _defeatedPlayer;
  bool get showTawbahDialog => _showTawbahDialog;

  void _setLog({required String bn, required String en}) {
    _gameLogBn = bn;
    _gameLogEn = en;
  }

  void startNewGame({
    required int playerCount,
    required bool vsAi,
    List<String>? customNames,
    AppLanguage language = AppLanguage.bn,
  }) {
    final defaultColors = [
      const Color(0xFF10B981), // Emerald Green
      const Color(0xFF3B82F6), // Royal Blue
      const Color(0xFFF59E0B), // Golden Amber
      const Color(0xFFEC4899), // Rose Pink
    ];

    final defaultBnNames = ['মুসাফির ১', 'মুসাফির ২', 'মুসাফির ৩', 'মুসাফির ৪'];
    final defaultEnNames = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];

    _players = List.generate(playerCount, (index) {
      final custom = (customNames != null && index < customNames.length && customNames[index].isNotEmpty)
          ? customNames[index]
          : null;

      final isAiPlayer = vsAi && index > 0;
      final nameBn = isAiPlayer ? 'AI সঙ্গী $index' : defaultBnNames[index];
      final nameEn = isAiPlayer ? 'AI Companion $index' : defaultEnNames[index];

      return Player(
        id: index,
        nameBn: nameBn,
        nameEn: nameEn,
        customName: custom,
        color: defaultColors[index % defaultColors.length],
        isAi: isAiPlayer,
      );
    });

    _currentPlayerIndex = 0;
    _diceValue = 1;
    _isRolling = false;
    _isMoving = false;
    _activeEventTile = null;
    _activeQuiz = null;
    _winner = null;
    _defeatedPlayer = null;
    _showTawbahDialog = false;
    _setLog(
      bn: 'খেলা শুরু হলো! ${_players.first.getName(AppLanguage.bn)} এর চাল।',
      en: 'Game started! ${_players.first.getName(AppLanguage.en)}\'s turn.',
    );
    notifyListeners();
  }

  Future<void> rollDice() async {
    if (_isRolling || _isMoving || _winner != null || _activeEventTile != null || _activeQuiz != null || _showTawbahDialog) {
      return;
    }

    _isRolling = true;
    notifyListeners();

    // Trigger Dice roll SFX
    soundService.playDiceRoll();

    // Dice animation frames
    final random = Random();
    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 70));
      _diceValue = random.nextInt(6) + 1;
      notifyListeners();
    }

    _isRolling = false;
    notifyListeners();

    await _moveCurrentPlayer(_diceValue);
  }

  Future<void> _moveCurrentPlayer(int steps) async {
    _isMoving = true;
    final player = currentPlayer;
    final targetPosition = min(52, player.position + steps);
    _setLog(
      bn: '${player.getName(AppLanguage.bn)} ছক্কায় পেলেন $steps! এগিয়ে যাচ্ছেন...',
      en: '${player.getName(AppLanguage.en)} rolled $steps! Moving forward...',
    );
    notifyListeners();

    // Smooth step-by-step movement
    while (player.position < targetPosition) {
      await Future.delayed(const Duration(milliseconds: 250));
      player.position++;
      soundService.playStep();
      notifyListeners();
    }

    _isMoving = false;
    notifyListeners();

    // Handle the tile player landed on
    final landedTile = tiles[player.position];
    await _handleTileLanded(player, landedTile);
  }

  Future<void> _handleTileLanded(Player player, BoardTile tile) async {
    // Collect Pillar token if present
    if (tile.pillarReward != null) {
      player.unlockPillar(tile.pillarReward!);
      soundService.playPillar();
      if (tile.pillarReward == PillarType.namaz) {
        player.salahShieldTurns = 3;
      }
    } else if (tile.type == TileType.sinTrap || tile.gunahDelta > 0) {
      soundService.playSinWarning();
    } else if (tile.nekiDelta > 0) {
      soundService.playNeki();
    }

    // Add Neki
    if (tile.nekiDelta > 0) {
      player.addNeki(tile.nekiDelta);
    }

    // Add Gunah (Shield checked inside player.addGunah)
    if (tile.gunahDelta > 0) {
      player.addGunah(tile.gunahDelta);
    }

    // Handle special tile types
    switch (tile.type) {
      case TileType.quiz:
        _activeQuiz = QuizBank.getRandomQuiz();
        _setLog(
          bn: '${player.getName(AppLanguage.bn)} ইসলামিক কুইজ ঘরে পড়েছেন!',
          en: '${player.getName(AppLanguage.en)} landed on an Islamic Quiz tile!',
        );
        notifyListeners();
        // If AI, answer automatically after delay
        if (player.isAi) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            answerQuiz(_activeQuiz!.correctIndex);
          });
        }
        return;

      case TileType.tawbah:
        _showTawbahDialog = true;
        soundService.playTawbah();
        _setLog(
          bn: '${player.getName(AppLanguage.bn)} তওবা ও ইস্তিগফারের বিশেষ ঘরে এসেছেন।',
          en: '${player.getName(AppLanguage.en)} landed on the Repentance & Istighfar tile.',
        );
        notifyListeners();
        if (player.isAi) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            performTawbah();
          });
        }
        return;

      case TileType.jannah:
        _checkJannahVictory(player);
        return;

      default:
      // Regular tile or ladder/snake
        _activeEventTile = tile;
        notifyListeners();
        if (player.isAi) {
          // If voice narration is enabled, give enough time for players to hear the card before auto-dismissing
          final autoDismissDelay = TtsService().isVoiceEnabled
              ? const Duration(milliseconds: 6000)
              : const Duration(milliseconds: 1800);
          Future.delayed(autoDismissDelay, () {
            if (_activeEventTile != null) {
              dismissEventDialog();
            }
          });
        }
        break;
    }
  }

  Future<void> dismissEventDialog() async {
    if (_activeEventTile == null) return;
    TtsService().stop();

    final player = currentPlayer;
    final tile = _activeEventTile!;
    _activeEventTile = null;
    notifyListeners();

    // Check ladder or snake jump
    if (tile.jumpTo != null) {
      final jumpTarget = tile.jumpTo!;
      _setLog(
        bn: tile.isLadder
            ? '🌟 নেক আমলের বরকতে ${player.getName(AppLanguage.bn)} $jumpTarget নম্বর ঘরে পৌঁছালেন!'
            : '⚠️ সতর্কবার্তা! পিছলে ${player.getName(AppLanguage.bn)} $jumpTarget নম্বর ঘরে নেমে গেলেন।',
        en: tile.isLadder
            ? '🌟 Blessed by good deeds, ${player.getName(AppLanguage.en)} climbed to tile $jumpTarget!'
            : '⚠️ Warning! ${player.getName(AppLanguage.en)} slid down to tile $jumpTarget.',
      );
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 400));
      player.position = jumpTarget;
      if (tile.isLadder) {
        soundService.playNeki();
      } else {
        soundService.playSinWarning();
      }
      notifyListeners();
    }

    _finishTurn();
  }

  void answerQuiz(int selectedOptionIndex) {
    if (_activeQuiz == null) return;
    TtsService().stop();
    final player = currentPlayer;
    final isCorrect = selectedOptionIndex == _activeQuiz!.correctIndex;

    if (isCorrect) {
      player.addNeki(_activeQuiz!.rewardNeki);
      soundService.playQuizCorrect();
      _setLog(
        bn: '🎉 মাশাআল্লাহ! সঠিক উত্তরে ${player.getName(AppLanguage.bn)} +${_activeQuiz!.rewardNeki} নেকি পেয়েছেন!',
        en: '🎉 MashaAllah! Correct answer! ${player.getName(AppLanguage.en)} gained +${_activeQuiz!.rewardNeki} Hasanah!',
      );
    } else {
      soundService.playQuizWrong();
      final optBn = _activeQuiz!.options[_activeQuiz!.correctIndex];
      final optEn = _activeQuiz!.getOptions(AppLanguage.en)[_activeQuiz!.correctIndex];
      _setLog(
        bn: '❌ ভুল উত্তর। সঠিক উত্তর ছিল: $optBn',
        en: '❌ Incorrect answer. The correct answer was: $optEn',
      );
    }

    _activeQuiz = null;
    notifyListeners();
    _finishTurn();
  }

  void performTawbah() {
    TtsService().stop();
    final player = currentPlayer;
    // Repentance clears half of gunah and grants neki
    final forgivenGunah = (player.gunah / 2).round();
    player.gunah = (player.gunah - forgivenGunah).clamp(0, 9999);
    player.addNeki(30);
    soundService.playTawbah();
    _setLog(
      bn: '✨ আস্তাগফিরুল্লাহ! খাঁটি তওবার মাধ্যমে ${player.getName(AppLanguage.bn)} এর $forgivenGunah গুনাহ মাফ হলো ও +৩০ নেকি পেলেন!',
      en: '✨ Astaghfirullah! Through sincere repentance, ${player.getName(AppLanguage.en)} had $forgivenGunah sins forgiven and received +30 Hasanah!',
    );

    _showTawbahDialog = false;
    notifyListeners();
    _finishTurn();
  }

  void _checkJannahVictory(Player player) {
    // Check condition for Jannah:
    // 1. All 5 pillars (or at least 3)
    // 2. Neki > Gunah
    if (player.neki >= player.gunah && player.collectedPillars.length >= 3) {
      player.isCompleted = true;
      _winner = player;
      soundService.playVictory();
      _setLog(
        bn: '🏆 আলহামদুলিল্লাহ! ${player.getName(AppLanguage.bn)} পুলসিরাত পার হয়ে জান্নাতুল ফিরদাউসে পৌঁছেছেন!',
        en: '🏆 Alhamdulillah! ${player.getName(AppLanguage.en)} crossed Sirat and reached Jannat al-Firdaus!',
      );
    } else {
      _defeatedPlayer = player;
      soundService.playSinWarning();
      _setLog(
        bn: '⚠️ সতর্কবার্তা! আমলনামায় নেকির ঘাটতি রয়েছে। তওবা ও ইস্তিগফার প্রয়োজন।',
        en: '⚠️ Warning! Insufficient good deeds in the record. Repentance is required.',
      );
    }
    notifyListeners();
  }

  void retryAfterFailure() {
    if (_defeatedPlayer != null) {
      _defeatedPlayer!.position = 40; // Send back to Tawbah tile
      _defeatedPlayer!.addNeki(50);
      _defeatedPlayer!.gunah = 10;
      _defeatedPlayer = null;
      _setLog(
        bn: '${currentPlayer.getName(AppLanguage.bn)} তওবা করে পুনরায় জান্নাতের দিকে এগিয়ে যাচ্ছেন।',
        en: '${currentPlayer.getName(AppLanguage.en)} repented and is advancing toward Jannah again.',
      );
      notifyListeners();
      _finishTurn();
    }
  }

  void _finishTurn() {
    final player = currentPlayer;
    player.decrementShield();

    // Check if rolled 6 for an extra turn
    if (_diceValue == 6 && _winner == null) {
      _setLog(
        bn: '🎲 ছক্কা পড়ায় ${player.getName(AppLanguage.bn)} আবার চাল দেওয়ার সুযোগ পেলেন!',
        en: '🎲 Rolled a 6! ${player.getName(AppLanguage.en)} gets an extra turn!',
      );
      notifyListeners();
      _checkAiTurn();
      return;
    }

    // Switch to next player
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    _setLog(
      bn: 'এখন ${currentPlayer.getName(AppLanguage.bn)} এর চাল।',
      en: 'Now it\'s ${currentPlayer.getName(AppLanguage.en)}\'s turn.',
    );
    notifyListeners();

    _checkAiTurn();
  }

  void _checkAiTurn() {
    if (currentPlayer.isAi && _winner == null && _activeEventTile == null && _activeQuiz == null && !_showTawbahDialog) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        rollDice();
      });
    }
  }

  // ================= DEVELOPER DEBUG HELPERS ================= //
  Future<void> devRollSpecificDice(int value) async {
    if (_isRolling || _isMoving) return;
    _diceValue = value.clamp(1, 6);
    notifyListeners();
    await _moveCurrentPlayer(_diceValue);
  }

  void devSetDiceValue(int value) {
    _diceValue = value.clamp(1, 6);
    notifyListeners();
  }

  Future<void> devJumpToTile(int tileIndex) async {
    if (_players.isEmpty || _isMoving || _isRolling) return;
    final player = currentPlayer;
    player.position = tileIndex.clamp(0, 52);
    _setLog(
      bn: '🛠️ দেব-মোড: ${player.getName(AppLanguage.bn)} সরাসরি $tileIndex নম্বর ঘরে জাম্প করলেন!',
      en: '🛠️ Dev-Mode: ${player.getName(AppLanguage.en)} jumped directly to tile $tileIndex!',
    );
    notifyListeners();
    final landedTile = tiles[player.position];
    await _handleTileLanded(player, landedTile);
  }

  void devAddNeki(int amount) {
    if (_players.isEmpty) return;
    currentPlayer.addNeki(amount);
    _setLog(
      bn: '🛠️ দেব-মোড: ${currentPlayer.getName(AppLanguage.bn)} কে +$amount নেকি দেওয়া হলো।',
      en: '🛠️ Dev-Mode: Awarded +$amount Hasanah to ${currentPlayer.getName(AppLanguage.en)}.',
    );
    notifyListeners();
  }

  void devAddGunah(int amount) {
    if (_players.isEmpty) return;
    currentPlayer.addGunah(amount);
    _setLog(
      bn: '🛠️ দেব-মোড: ${currentPlayer.getName(AppLanguage.bn)} এর গুনাহ +$amount করা হলো।',
      en: '🛠️ Dev-Mode: Added +$amount sins to ${currentPlayer.getName(AppLanguage.en)}.',
    );
    notifyListeners();
  }

  void devClearGunah() {
    if (_players.isEmpty) return;
    currentPlayer.gunah = 0;
    _setLog(
      bn: '🛠️ দেব-মোড: ${currentPlayer.getName(AppLanguage.bn)} এর সমস্ত গুনাহ ক্ষমা করা হলো!',
      en: '🛠️ Dev-Mode: Cleared all sins for ${currentPlayer.getName(AppLanguage.en)}!',
    );
    notifyListeners();
  }

  void devUnlockAllPillars() {
    if (_players.isEmpty) return;
    for (var pillar in PillarType.values) {
      currentPlayer.unlockPillar(pillar);
    }
    currentPlayer.salahShieldTurns = 5;
    _setLog(
      bn: '🛠️ দেব-মোড: ${currentPlayer.getName(AppLanguage.bn)} এর ৫টি স্তম্ভ ও শিল্ড আনলক হলো!',
      en: '🛠️ Dev-Mode: Unlocked all 5 pillars & shield for ${currentPlayer.getName(AppLanguage.en)}!',
    );
    notifyListeners();
  }

  void devToggleShield() {
    if (_players.isEmpty) return;
    if (currentPlayer.hasShield) {
      currentPlayer.salahShieldTurns = 0;
      _setLog(
        bn: '🛠️ দেব-মোড: ${currentPlayer.getName(AppLanguage.bn)} এর শিল্ড নিষ্ক্রিয় করা হলো।',
        en: '🛠️ Dev-Mode: Deactivated shield for ${currentPlayer.getName(AppLanguage.en)}.',
      );
    } else {
      currentPlayer.salahShieldTurns = 5;
      _setLog(
        bn: '🛠️ দেব-মোড: ${currentPlayer.getName(AppLanguage.bn)} এর জন্য ৫ চালের শিল্ড দেওয়া হলো।',
        en: '🛠️ Dev-Mode: Granted 5-turn shield for ${currentPlayer.getName(AppLanguage.en)}.',
      );
    }
    notifyListeners();
  }
}
