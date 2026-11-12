import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Emplake'**
  String get appTitle;

  /// No description provided for @groupLabel.
  ///
  /// In pt, this message translates to:
  /// **'Integrante: Ana Clara Santana Matta'**
  String get groupLabel;

  /// No description provided for @loginTagline.
  ///
  /// In pt, this message translates to:
  /// **'Monte equações com os quatro dígitos!'**
  String get loginTagline;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @navGame.
  ///
  /// In pt, this message translates to:
  /// **'Jogo'**
  String get navGame;

  /// No description provided for @navProgress.
  ///
  /// In pt, this message translates to:
  /// **'Progresso'**
  String get navProgress;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @navHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get navHelp;

  /// No description provided for @levelEasy.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get levelEasy;

  /// No description provided for @levelMedium.
  ///
  /// In pt, this message translates to:
  /// **'Intermediário'**
  String get levelMedium;

  /// No description provided for @levelAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get levelAdvanced;

  /// No description provided for @levelHard.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get levelHard;

  /// No description provided for @yourNumber.
  ///
  /// In pt, this message translates to:
  /// **'Coordenadas do destino'**
  String get yourNumber;

  /// No description provided for @formulaLatex.
  ///
  /// In pt, this message translates to:
  /// **'Fórmula renderizada'**
  String get formulaLatex;

  /// No description provided for @latexPending.
  ///
  /// In pt, this message translates to:
  /// **'Complete a expressão para ver a fórmula.'**
  String get latexPending;

  /// No description provided for @tapSlotHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque em uma doca entre os planetas e depois em um operador.'**
  String get tapSlotHint;

  /// No description provided for @check.
  ///
  /// In pt, this message translates to:
  /// **'Lançar'**
  String get check;

  /// No description provided for @skip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get skip;

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @errSyntax.
  ///
  /// In pt, this message translates to:
  /// **'Expressão inválida. Confira operadores e parênteses.'**
  String get errSyntax;

  /// No description provided for @errNoEq.
  ///
  /// In pt, this message translates to:
  /// **'Use exatamente um sinal de =.'**
  String get errNoEq;

  /// No description provided for @errDivInt.
  ///
  /// In pt, this message translates to:
  /// **'Neste nível, só são permitidas divisões inteiras.'**
  String get errDivInt;

  /// No description provided for @errDivZero.
  ///
  /// In pt, this message translates to:
  /// **'Divisão por zero.'**
  String get errDivZero;

  /// No description provided for @errDomain.
  ///
  /// In pt, this message translates to:
  /// **'Operação fora do domínio (raiz de negativo, fatorial inválido...).'**
  String get errDomain;

  /// No description provided for @notEqual.
  ///
  /// In pt, this message translates to:
  /// **'Não é igual: {left} ≠ {right}'**
  String notEqual(String left, String right);

  /// No description provided for @correct.
  ///
  /// In pt, this message translates to:
  /// **'Correto! +{points} pontos'**
  String correct(int points);

  /// No description provided for @allSolved.
  ///
  /// In pt, this message translates to:
  /// **'Você resolveu todos os números! 🎉'**
  String get allSolved;

  /// No description provided for @loadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro: {error}'**
  String loadError(String error);

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get retry;

  /// No description provided for @progressTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu progresso'**
  String get progressTitle;

  /// No description provided for @scoreLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pontuação: {score}'**
  String scoreLabel(int score);

  /// No description provided for @solvedCount.
  ///
  /// In pt, this message translates to:
  /// **'Números resolvidos: {count}'**
  String solvedCount(int count);

  /// No description provided for @noneSolved.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum número resolvido ainda.'**
  String get noneSolved;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @themeMode.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @fontSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho da fonte'**
  String get fontSize;

  /// No description provided for @fontFamily.
  ///
  /// In pt, this message translates to:
  /// **'Tipo da fonte'**
  String get fontFamily;

  /// No description provided for @seedColor.
  ///
  /// In pt, this message translates to:
  /// **'Cor do tema'**
  String get seedColor;

  /// No description provided for @sound.
  ///
  /// In pt, this message translates to:
  /// **'Som'**
  String get sound;

  /// No description provided for @soundDesc.
  ///
  /// In pt, this message translates to:
  /// **'Efeitos sonoros (desligado por padrão)'**
  String get soundDesc;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get signOut;

  /// No description provided for @helpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como jogar'**
  String get helpTitle;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @helpBody.
  ///
  /// In pt, this message translates to:
  /// **'Os 4 dígitos do número são planetas fixos, em ordem, na rota.\n\nToque em uma doca (entre os planetas) e depois em um operador para colocá-lo ali. Toque em uma ficha já colocada para removê-la.\n\nUse o sinal = exatamente uma vez. Planetas vizinhos sem operador entre eles formam um número maior (1 e 2 viram 12).\n\nFunções como √( e floor( abrem um parêntese: feche com ).\n\nFácil permite divisão não inteira; nos demais níveis, só divisões exatas.\n\nPontos: Fácil 1, Intermediário 2, Avançado 3, Difícil 5.'**
  String get helpBody;

  /// No description provided for @music.
  ///
  /// In pt, this message translates to:
  /// **'Música de fundo'**
  String get music;

  /// No description provided for @musicDesc.
  ///
  /// In pt, this message translates to:
  /// **'Trilha ambiente espacial (desligada por padrão)'**
  String get musicDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
