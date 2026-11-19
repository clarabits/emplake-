// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get groupLabel => 'Integrante: Ana Clara Santana Matta';

  @override
  String get loginTagline => 'Monte equações com os quatro dígitos!';

  @override
  String get language => 'Idioma';

  @override
  String get navGame => 'Jogo';

  @override
  String get navProgress => 'Progresso';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navHelp => 'Ajuda';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelMedium => 'Intermediário';

  @override
  String get levelAdvanced => 'Avançado';

  @override
  String get levelHard => 'Difícil';

  @override
  String get yourNumber => 'Coordenadas do destino';

  @override
  String get formulaLatex => 'Fórmula renderizada';

  @override
  String get latexPending => 'Complete a expressão para ver a fórmula.';

  @override
  String get tapSlotHint =>
      'Toque onde quer inserir (a barrinha piscando mostra o ponto) e escolha uma ficha. Use Apagar para remover.';

  @override
  String get check => 'Lançar';

  @override
  String get skip => 'Pular';

  @override
  String get clear => 'Limpar';

  @override
  String get errSyntax =>
      'Expressão inválida. Confira operadores e parênteses.';

  @override
  String get errNoEq => 'Use exatamente um sinal de =.';

  @override
  String get errDivInt => 'Neste nível, só são permitidas divisões inteiras.';

  @override
  String get errDivZero => 'Divisão por zero.';

  @override
  String get errDomain =>
      'Operação fora do domínio (raiz de negativo, fatorial inválido...).';

  @override
  String notEqual(String left, String right) {
    return 'Não é igual: $left ≠ $right';
  }

  @override
  String correct(int points) {
    return 'Correto! +$points pontos';
  }

  @override
  String get allSolved => 'Você resolveu todos os números! 🎉';

  @override
  String loadError(String error) {
    return 'Erro: $error';
  }

  @override
  String get retry => 'Tentar de novo';

  @override
  String get progressTitle => 'Seu progresso';

  @override
  String scoreLabel(int score) {
    return 'Pontuação: $score';
  }

  @override
  String solvedCount(int count) {
    return 'Números resolvidos: $count';
  }

  @override
  String get noneSolved => 'Nenhum número resolvido ainda.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get fontSize => 'Tamanho da fonte';

  @override
  String get fontFamily => 'Tipo da fonte';

  @override
  String get seedColor => 'Cor do tema';

  @override
  String get sound => 'Som';

  @override
  String get soundDesc => 'Efeitos sonoros (desligado por padrão)';

  @override
  String get signOut => 'Sair da conta';

  @override
  String get helpTitle => 'Como jogar';

  @override
  String get close => 'Fechar';

  @override
  String get helpBody =>
      'Os 4 dígitos do número são planetas fixos, em ordem, na rota.\n\nToque em uma doca (entre os planetas) e depois em um operador para colocá-lo ali. Toque em uma ficha já colocada para removê-la.\n\nUse o sinal = exatamente uma vez. Planetas vizinhos sem operador entre eles formam um número maior (1 e 2 viram 12).\n\nFunções como √( e floor( abrem um parêntese: feche com ).\n\nFácil permite divisão não inteira; nos demais níveis, só divisões exatas.\n\nPontos: Fácil 1, Intermediário 2, Avançado 3, Difícil 5.';

  @override
  String get music => 'Música de fundo';

  @override
  String get musicDesc => 'Trilha ambiente espacial (desligada por padrão)';

  @override
  String get backspace => 'Apagar';

  @override
  String get nextNumber => 'Próximo Número';

  @override
  String get signUpHint =>
      'Primeira vez aqui? Toque em “Inscrever-se” para criar sua conta.';
}
