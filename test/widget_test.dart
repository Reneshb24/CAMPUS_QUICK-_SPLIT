import 'package:flutter_test/flutter_test.dart';

import 'package:campus_quick_split/app/app.dart';
import 'package:campus_quick_split/providers/theme_controller.dart';

void main() {
  testWidgets('Campus Quick Split app loads', (WidgetTester tester) async {
    final ThemeController themeController = ThemeController();

    await tester.pumpWidget(
      CampusQuickSplitApp(
        themeController: themeController,
      ),
    );

    expect(find.text('Home'), findsWidgets);
  });
}
