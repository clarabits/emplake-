// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get groupLabel => 'Member: Ana Clara Santana Matta';

  @override
  String get loginTagline => 'Build equations with the four digits!';

  @override
  String get language => 'Language';

  @override
  String get navGame => 'Game';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get navHelp => 'Help';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelMedium => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelHard => 'Hard';

  @override
  String get yourNumber => 'Destination coordinates';

  @override
  String get formulaLatex => 'Rendered formula';

  @override
  String get latexPending => 'Complete the expression to see the formula.';

  @override
  String get tapSlotHint =>
      'Tap where you want to insert (the blinking bar shows the spot) and pick a token. Use Delete to remove.';

  @override
  String get check => 'Launch';

  @override
  String get skip => 'Skip';

  @override
  String get clear => 'Clear';

  @override
  String get errSyntax =>
      'Invalid expression. Check operators and parentheses.';

  @override
  String get errNoEq => 'Use exactly one = sign.';

  @override
  String get errDivInt => 'At this level, only integer division is allowed.';

  @override
  String get errDivZero => 'Division by zero.';

  @override
  String get errDomain =>
      'Operation out of domain (root of a negative, invalid factorial...).';

  @override
  String notEqual(String left, String right) {
    return 'Not equal: $left ≠ $right';
  }

  @override
  String correct(int points) {
    return 'Correct! +$points points';
  }

  @override
  String get allSolved => 'You solved every number! 🎉';

  @override
  String loadError(String error) {
    return 'Error: $error';
  }

  @override
  String get retry => 'Try again';

  @override
  String get progressTitle => 'Your progress';

  @override
  String scoreLabel(int score) {
    return 'Score: $score';
  }

  @override
  String solvedCount(int count) {
    return 'Solved numbers: $count';
  }

  @override
  String get noneSolved => 'No solved numbers yet.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontFamily => 'Font family';

  @override
  String get seedColor => 'Theme color';

  @override
  String get sound => 'Sound';

  @override
  String get soundDesc => 'Sound effects (off by default)';

  @override
  String get signOut => 'Sign out';

  @override
  String get helpTitle => 'How to play';

  @override
  String get close => 'Close';

  @override
  String get helpBody =>
      'The 4 digits of the number are fixed planets, in order, along the route.\n\nTap a dock (between the planets), then tap an operator to place it there. Tap a placed token to remove it.\n\nUse the = sign exactly once. Neighboring planets with no operator between them form a larger number (1 and 2 become 12).\n\nFunctions like √( and floor( open a parenthesis: close it with ).\n\nEasy allows non-integer division; other levels allow exact division only.\n\nPoints: Easy 1, Intermediate 2, Advanced 3, Hard 5.';

  @override
  String get music => 'Background music';

  @override
  String get musicDesc => 'Space ambient soundtrack (off by default)';

  @override
  String get backspace => 'Delete';

  @override
  String get nextNumber => 'Next Number';

  @override
  String get signUpHint =>
      'First time here? Tap “Register” to create your account.';
}
