import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:islamic_game_ludoking/models/player.dart';
import 'package:islamic_game_ludoking/state/game_provider.dart';
import 'package:islamic_game_ludoking/state/settings_provider.dart';
import 'package:islamic_game_ludoking/widgets/result_dialog.dart';

import 'package:flutter/services.dart';
import 'package:islamic_game_ludoking/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers.global'), (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers'), (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (call) async => null);
    SoundService().setMute(true);
  });

  group('Multi-winner Game Logic Tests', () {
    test('2 Players game finishes after 1 winner', () async {
      final game = GameProvider();
      game.startNewGame(playerCount: 2, vsAi: false);

      expect(game.targetWinnersCount, equals(1));
      expect(game.isGameOver, isFalse);
      expect(game.winners.isEmpty, isTrue);

      // Give Player 1 sufficient good deeds & pillars to win
      final p1 = game.players[0];
      p1.addNeki(200);
      p1.unlockPillar(PillarType.namaz);
      p1.unlockPillar(PillarType.roza);

      // Jump to Jannah (tile 52)
      await game.devJumpToTile(52);

      expect(p1.isCompleted, isTrue);
      expect(p1.winnerRank, equals(1));
      expect(game.winners.length, equals(1));
      expect(game.firstWinner, equals(p1));
      expect(game.isGameOver, isTrue);
      expect(game.intermediateWinner, isNull);
    });

    test('3 Players game continues until 2 winners finish', () async {
      final game = GameProvider();
      game.startNewGame(playerCount: 3, vsAi: false);

      expect(game.targetWinnersCount, equals(2));
      expect(game.isGameOver, isFalse);

      final p1 = game.players[0];
      final p2 = game.players[1];
      final p3 = game.players[2];

      // Prepare p1 and p2 to win
      p1.addNeki(200);
      p1.unlockPillar(PillarType.namaz);
      p1.unlockPillar(PillarType.roza);

      p2.addNeki(200);
      p2.unlockPillar(PillarType.namaz);
      p2.unlockPillar(PillarType.roza);

      // Player 1 finishes first
      await game.devJumpToTile(52);

      expect(p1.isCompleted, isTrue);
      expect(p1.winnerRank, equals(1));
      expect(game.winners.length, equals(1));
      expect(game.firstWinner, equals(p1));
      expect(game.intermediateWinner, equals(p1));
      // Game must NOT be over yet!
      expect(game.isGameOver, isFalse);

      // Dismiss intermediate winner dialog and advance turn
      game.continueAfterIntermediateWinner();
      expect(game.intermediateWinner, isNull);

      // Current player should have advanced to p2 (skipping p1)
      expect(game.currentPlayerIndex, equals(1));
      expect(game.currentPlayer, equals(p2));

      // Player 2 finishes second
      await game.devJumpToTile(52);

      expect(p2.isCompleted, isTrue);
      expect(p2.winnerRank, equals(2));
      expect(game.winners.length, equals(2));
      expect(game.firstWinner, equals(p1));
      expect(game.secondWinner, equals(p2));
      // Now 2 winners reached - game MUST be over!
      expect(game.isGameOver, isTrue);
      expect(game.intermediateWinner, isNull);
    });

    test('4 Players game skips completed players and stops at 2 winners', () async {
      final game = GameProvider();
      game.startNewGame(playerCount: 4, vsAi: false);

      expect(game.targetWinnersCount, equals(2));

      final p1 = game.players[0];
      final p2 = game.players[1];
      final p3 = game.players[2];
      final p4 = game.players[3];

      for (var p in [p1, p2, p3, p4]) {
        p.addNeki(150);
        p.unlockPillar(PillarType.namaz);
        p.unlockPillar(PillarType.roza);
      }

      // Player 1 wins 1st
      await game.devJumpToTile(52);
      expect(p1.winnerRank, equals(1));
      expect(game.isGameOver, isFalse);

      game.continueAfterIntermediateWinner();
      expect(game.currentPlayerIndex, equals(1)); // p2

      // Move turn without p2 winning (roll non-winning dice)
      // Player 2 takes turn and lands on normal tile
      await game.devRollSpecificDice(2);
      await game.dismissEventDialog();
      expect(game.currentPlayerIndex, equals(2)); // p3

      // Player 3 takes turn and lands on normal tile
      await game.devRollSpecificDice(3);
      await game.dismissEventDialog();
      expect(game.currentPlayerIndex, equals(3)); // p4

      // Player 4 wins 2nd!
      await game.devJumpToTile(52);
      expect(p4.winnerRank, equals(2));
      expect(game.firstWinner, equals(p1));
      expect(game.secondWinner, equals(p4));
      expect(game.isGameOver, isTrue);
    });
  });

  group('ResultDialog Widget Tests', () {
    testWidgets('ResultDialog displays 1st and 2nd winners in Bangla without text decoration errors', (WidgetTester tester) async {
      final p1 = Player(id: 0, nameBn: 'মুসাফির ১', nameEn: 'Player 1', color: Colors.green);
      p1.winnerRank = 1;
      p1.neki = 120;
      p1.gunah = 10;

      final p2 = Player(id: 1, nameBn: 'মুসাফির ২', nameEn: 'Player 2', color: Colors.blue);
      p2.winnerRank = 2;
      p2.neki = 95;
      p2.gunah = 5;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ResultDialog(
                firstWinner: p1,
                secondWinner: p2,
                winners: [p1, p2],
                isIntermediate: false,
                onPlayAgain: () {},
                onRetryTawbah: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for 1st Winner and 2nd Winner labels
      expect(find.text('🥇 ফার্স্ট উইনার (১ম স্থান)'), findsOneWidget);
      expect(find.text('🥈 সেকেন্ড উইনার (২য় স্থান)'), findsOneWidget);
      expect(find.text('মুসাফির ১'), findsOneWidget);
      expect(find.text('মুসাফির ২'), findsOneWidget);
      expect(find.text('🎉 মাশাআল্লাহ! খেলা সমাপ্ত!'), findsOneWidget);

      // Verify no yellow underline decoration issues
      final texts = find.byType(Text);
      for (final element in texts.evaluate()) {
        final widget = element.widget as Text;
        if (widget.style?.decoration != null) {
          expect(widget.style!.decoration, equals(TextDecoration.none));
        }
      }
    });

    testWidgets('ResultDialog displays intermediate 1st winner with continuation button', (WidgetTester tester) async {
      final p1 = Player(id: 0, nameBn: 'মুসাফির ১', nameEn: 'Player 1', color: Colors.green);
      p1.winnerRank = 1;
      p1.neki = 150;

      bool continued = false;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ResultDialog(
                firstWinner: p1,
                isIntermediate: true,
                onPlayAgain: () {},
                onContinueGame: () {
                  continued = true;
                },
                onRetryTawbah: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('🎉 মাশাআল্লাহ! ফার্স্ট উইনার!'), findsOneWidget);
      expect(find.text('খেলা কন্টিনিউ করুন (২য় বিজয়ী)'), findsOneWidget);

      await tester.tap(find.text('খেলা কন্টিনিউ করুন (২য় বিজয়ী)'));
      expect(continued, isTrue);
    });
  });
}
