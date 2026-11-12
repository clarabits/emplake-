import 'dart:math' as math;

enum Level { easy, medium, advanced, hard }

extension LevelX on Level {
  List<String> get tokens => switch (this) {
        Level.easy => ['+', '-', '*', '/', '(', ')', 'sqrt(', 'cbrt(', '!', '**', 'abs(', 'floor(', 'ceil(', '='],
        Level.medium => ['+', '-', '*', '/', '(', ')', 'sqrt(', 'cbrt(', '!', '**', 'abs(', '='],
        Level.advanced => ['+', '-', '*', '/', '(', ')', 'sqrt(', '!', 'abs(', '='],
        Level.hard => ['+', '-', '*', '/', '(', ')', 'abs(', '='],
      };
  bool get allowFractions => this == Level.easy;
  int get points => const [1, 2, 3, 5][index];
}

enum GameErrorKind { syntax, noEq, divInt, divZero, domain }

class GameError implements Exception {
  final GameErrorKind kind;
  GameError(this.kind);
}

final _digits = RegExp(r'^\d+$');

/// Junta os tokens dos encaixes com os dígitos fixos (dígitos vizinhos se concatenam).
List<String> flatten(List<List<String>> slots, List<String> digits) {
  final out = <String>[];
  void push(String t) {
    if (_digits.hasMatch(t) && out.isNotEmpty && _digits.hasMatch(out.last)) {
      out[out.length - 1] += t;
    } else {
      out.add(t);
    }
  }

  for (var i = 0; i < slots.length; i++) {
    slots[i].forEach(push);
    if (i < digits.length) push(digits[i]);
  }
  return out;
}

bool _isInt(double v) => (v - v.roundToDouble()).abs() < 1e-9;

double _cbrt(double v) {
  final r = v < 0 ? -math.pow(-v, 1 / 3).toDouble() : math.pow(v, 1 / 3).toDouble();
  final rr = r.roundToDouble();
  return (rr * rr * rr - v).abs() < 1e-9 ? rr : r;
}

String fmtNum(double v) =>
    _isInt(v) ? v.round().toString() : v.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '');

// ---------------------------------------------------------------- AST
abstract class Node {
  double eval(Level l);
  String tex();
}

class Num extends Node {
  final String s;
  Num(this.s);
  @override
  double eval(Level l) => double.parse(s);
  @override
  String tex() => s;
}

class Neg extends Node {
  final Node a;
  Neg(this.a);
  @override
  double eval(Level l) => -a.eval(l);
  @override
  String tex() => '-${a.tex()}';
}

class Paren extends Node {
  final Node a;
  Paren(this.a);
  @override
  double eval(Level l) => a.eval(l);
  @override
  String tex() => r'\left(' + a.tex() + r'\right)';
}

class Fact extends Node {
  final Node a;
  Fact(this.a);
  @override
  double eval(Level l) {
    final v = a.eval(l);
    if (!_isInt(v) || v < 0 || v > 170) throw GameError(GameErrorKind.domain);
    var r = 1.0;
    for (var i = 2; i <= v.round(); i++) {
      r *= i;
    }
    return r;
  }

  @override
  String tex() => '{${a.tex()}}!';
}

class Func extends Node {
  final String name;
  final Node a;
  Func(this.name, this.a);
  @override
  double eval(Level l) {
    final v = a.eval(l);
    switch (name) {
      case 'sqrt':
        if (v < 0) throw GameError(GameErrorKind.domain);
        return math.sqrt(v);
      case 'cbrt':
        return _cbrt(v);
      case 'abs':
        return v.abs();
      case 'floor':
        return v.floorToDouble();
      case 'ceil':
        return v.ceilToDouble();
    }
    throw GameError(GameErrorKind.syntax);
  }

  @override
  String tex() => switch (name) {
        'sqrt' => '\\sqrt{${a.tex()}}',
        'cbrt' => '\\sqrt[3]{${a.tex()}}',
        'abs' => '\\left|${a.tex()}\\right|',
        'floor' => '\\left\\lfloor ${a.tex()}\\right\\rfloor',
        _ => '\\left\\lceil ${a.tex()}\\right\\rceil',
      };
}

class Bin extends Node {
  final String op;
  final Node a, b;
  Bin(this.op, this.a, this.b);
  @override
  double eval(Level l) {
    final x = a.eval(l), y = b.eval(l);
    switch (op) {
      case '+':
        return x + y;
      case '-':
        return x - y;
      case '*':
        return x * y;
      case '/':
        if (y == 0) throw GameError(GameErrorKind.divZero);
        final q = x / y;
        if (!l.allowFractions) {
          if (!_isInt(q)) throw GameError(GameErrorKind.divInt);
          return q.roundToDouble();
        }
        return q;
      default: // **
        if (y.abs() > 1000) throw GameError(GameErrorKind.domain);
        final p = math.pow(x, y).toDouble();
        if (p.isNaN || p.isInfinite) throw GameError(GameErrorKind.domain);
        if (!l.allowFractions && !_isInt(p)) throw GameError(GameErrorKind.divInt);
        return p;
    }
  }

  @override
  String tex() => switch (op) {
        '+' => '${a.tex()} + ${b.tex()}',
        '-' => '${a.tex()} - ${b.tex()}',
        '*' => '${a.tex()} \\cdot ${b.tex()}',
        '/' => '\\frac{${a.tex()}}{${b.tex()}}',
        _ => '{${a.tex()}}^{${b.tex()}}',
      };
}

// ---------------------------------------------------------------- Parser
// expr := term (('+'|'-') term)* ; term := unary (('*'|'/') unary)*
// unary := '-' unary | power ; power := postfix ('**' unary)? ; postfix := primary '!'*
class _Parser {
  final List<String> t;
  int i = 0;
  _Parser(this.t);

  String? get _peek => i < t.length ? t[i] : null;
  GameError get _err => GameError(GameErrorKind.syntax);

  Node parse() {
    final n = _expr();
    if (i != t.length) throw _err;
    return n;
  }

  Node _expr() {
    var n = _term();
    while (_peek == '+' || _peek == '-') {
      final op = t[i++];
      n = Bin(op, n, _term());
    }
    return n;
  }

  Node _term() {
    var n = _unary();
    while (_peek == '*' || _peek == '/') {
      final op = t[i++];
      n = Bin(op, n, _unary());
    }
    return n;
  }

  Node _unary() {
    if (_peek == '-') {
      i++;
      return Neg(_unary());
    }
    return _power();
  }

  Node _power() {
    final b = _postfix();
    if (_peek == '**') {
      i++;
      return Bin('**', b, _unary());
    }
    return b;
  }

  Node _postfix() {
    var n = _primary();
    while (_peek == '!') {
      i++;
      n = Fact(n);
    }
    return n;
  }

  void _expect(String s) {
    if (_peek != s) throw _err;
    i++;
  }

  Node _primary() {
    final s = _peek;
    if (s == null) throw _err;
    i++;
    if (_digits.hasMatch(s)) {
      if (s.length > 1 && s.startsWith('0')) throw _err;
      return Num(s);
    }
    if (s == '(') {
      final n = _expr();
      _expect(')');
      return Paren(n);
    }
    if (s.length > 1 && s.endsWith('(')) {
      final n = _expr();
      _expect(')');
      return Func(s.substring(0, s.length - 1), n);
    }
    throw _err;
  }
}

class EqResult {
  final double left, right;
  EqResult(this.left, this.right);
  bool get ok => (left - right).abs() <= 1e-9 * math.max(1, math.max(left.abs(), right.abs()));
}

List<List<String>> _split(List<String> t) {
  final idx = [for (var i = 0; i < t.length; i++) if (t[i] == '=') i];
  if (idx.length != 1) throw GameError(GameErrorKind.noEq);
  final l = t.sublist(0, idx[0]), r = t.sublist(idx[0] + 1);
  if (l.isEmpty || r.isEmpty) throw GameError(GameErrorKind.syntax);
  return [l, r];
}

EqResult evaluateEquation(List<String> tokens, Level level) {
  final s = _split(tokens);
  return EqResult(_Parser(s[0]).parse().eval(level), _Parser(s[1]).parse().eval(level));
}

/// LaTeX da fórmula montada pelo usuário (null se ainda estiver incompleta/inválida).
String? buildLatex(List<String> tokens) {
  try {
    if (!tokens.contains('=')) return _Parser(tokens).parse().tex();
    final s = _split(tokens);
    return '${_Parser(s[0]).parse().tex()} = ${_Parser(s[1]).parse().tex()}';
  } on GameError {
    return null;
  }
}