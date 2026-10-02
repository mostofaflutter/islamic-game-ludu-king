import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:islamic_game_ludoking/models/board_tile.dart';
import 'package:islamic_game_ludoking/models/player.dart';
import 'package:islamic_game_ludoking/state/settings_provider.dart';
import 'package:islamic_game_ludoking/widgets/event_dialog.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('EventDialog has TextDecoration.none on all text', (WidgetTester tester) async {
    final tile = BoardData.generateBoard()[2];
    final player = Player(id: 0, name: 'মুসাফির ১', color: Colors.green);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: EventDialog(
              tile: tile,
              player: player,
              onDismiss: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Verify all text widgets have decoration == TextDecoration.none or null with default none
    final texts = find.byType(Text);
    expect(texts, findsWidgets);
    for (final element in texts.evaluate()) {
      final widget = element.widget as Text;
      if (widget.style?.decoration != null) {
        expect(widget.style!.decoration, equals(TextDecoration.none));
      }
    }
  });
}
