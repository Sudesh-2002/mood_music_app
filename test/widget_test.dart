import 'package:flutter_test/flutter_test.dart';
import 'package:mood_music_app/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MoodMusicApp());
    expect(find.text('MoodMusic'), findsOneWidget);
  });
}