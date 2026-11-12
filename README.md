# 🚀 Emplake

Jogo de equações em tema espacial, feito em **Flutter** (web). Cada número de 4 dígitos vira uma rota de **planetas**: o jogador usa operadores matemáticos nas **docas** entre eles para montar uma equação verdadeira.

**Jogue agora:** https://emplake-b6581.web.app

> Trabalho em grupo da disciplina **Desenvolvimento para Dispositivos Móveis** (UFSCar): engenharia reversa do jogo *Emplake*, criado pelo professor **Walter Alexandre Carnielli**, com interface e identidade visuais próprias.

## 🎮 Como jogar

1. Entre com e-mail e senha ou com a conta Google.
2. Você recebe um número de 4 dígitos, por exemplo `8131`. Os dígitos ficam fixos, em ordem, como planetas.
3. Toque numa **doca** (entre dois planetas) e depois num **operador** da paleta para colocá-lo ali.
4. Use o sinal `=` **uma única vez** e monte uma equação verdadeira, como `√(8+1) = 3**1`.
5. A fórmula é renderizada em **LaTeX** logo abaixo. Clique em **Lançar** para verificar.
6. Acertou? O foguete decola, o número é salvo na sua conta e você ganha pontos. Está difícil? Use **Pular**.

Dígitos vizinhos sem operador entre eles formam um número maior (`1` e `2` viram `12`). Funções como `√(` abrem um parêntese, que deve ser fechado com `)`.

### Níveis

| Nível | Operadores | Pontos |
|---|---|---|
| **Fácil** | `+ - * / ( )`, raiz quadrada, raiz cúbica, fatorial, exponencial (`**`), módulo, base e teto. Permite divisão não inteira | 1 |
| **Intermediário** | `+ - * / ( )`, raiz quadrada, raiz cúbica, fatorial, exponencial, módulo | 2 |
| **Avançado** | `+ - * / ( )`, raiz quadrada, fatorial, módulo | 3 |
| **Difícil** | `+ - * / ( )`, módulo | 5 |

Fora do nível Fácil, qualquer divisão não inteira gera erro.

## ✨ Funcionalidades

- **Login** com e-mail/senha e Google (`firebase_ui_auth`), gerenciado pelo Firebase (plano Spark).
- **Progresso na nuvem (Firestore):** guarda pontuação e os números já resolvidos; só sorteia números ainda não resolvidos.
- **Idiomas:** Português 🇧🇷 e Inglês 🇺🇸, com `flutter_localizations` e arquivos `.arb`.
- **Tema personalizável:** claro/escuro (começa com o tema do dispositivo), tamanho e tipo da fonte, cor semente.
- **Barra de navegação curva** (`curved_navigation_bar`) com Jogo, Progresso, Configurações e Ajuda (diálogo).
- **Retoma de onde parou:** a última página é guardada com `SharedPreferences`.
- **Animações:** planetas flutuantes, fichas que voltam à paleta, estrelas cintilantes, estrela cadente e foguete decolando.
- **Som opcional (desligado por padrão):** música ambiente e efeitos sonoros, ambos criados para o projeto.
- **Responsivo:** celular, tablet e desktop.
- **Pular** números difíceis.

## 🧱 Tecnologias

| Uso | Pacote |
|---|---|
| Estado | `flutter_riverpod` |
| Rotas | `go_router` |
| Login | `firebase_auth`, `firebase_ui_auth`, `firebase_ui_oauth_google` |
| Banco de dados | `cloud_firestore` |
| Fórmulas em LaTeX | `flutter_math_fork` |
| Navegação | `curved_navigation_bar` |
| Indicador de progresso | `loading_animation_widget` |
| Fontes | `google_fonts` |
| Persistência local | `shared_preferences` |
| Áudio | `audioplayers` |
| Traduções | `flutter_localizations`, `intl` |

O avaliador de expressões (`lib/engine.dart`) é um analisador recursivo próprio: converte a expressão em uma árvore, calcula o resultado e gera o LaTeX a partir dela.

## 📁 Estrutura

```
lib/
├── main.dart            # inicialização, rotas e tema
├── engine.dart          # parser, avaliador e gerador de LaTeX
├── providers.dart       # estado (Riverpod) e acesso ao Firestore
├── login_page.dart      # tela de login
├── shell.dart           # barra de navegação e diálogo de ajuda
├── game_page.dart       # tela do jogo
├── progress_page.dart   # pontuação e números resolvidos
├── settings_page.dart   # tema, fonte, idioma, música e som
├── widgets.dart         # fundo espacial, loader, seletor de idioma
├── music.dart           # música de fundo
├── sfx.dart             # efeitos sonoros
├── firebase_options.dart
└── l10n/                # traduções (app_pt.arb, app_en.arb)
assets/audio/            # música e efeitos
```

## ▶️ Como rodar

**Pré-requisitos:** Flutter instalado, Chrome e um projeto no Firebase.

```bash
git clone <url-do-repositorio>
cd emplake
flutter pub get
flutter gen-l10n
```

**Executar:**

```bash
flutter run -d chrome
```

## 👥 Integrantes

- Ana Clara Santana Matta

## 🙏 Créditos

- Ideia original do jogo **Emplake**: professor **Walter Alexandre Carnielli**.
- Música e efeitos sonoros sintetizados para este projeto.
- Desenvolvido com apoio de IA, conforme previsto no enunciado do trabalho.

## 📄 Licença

Projeto acadêmico. Os direitos sobre o jogo original pertencem ao professor Walter Alexandre Carnielli; consulte-o antes de qualquer uso comercial.