import 'dart:math';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const String _githubRepoUrl = 'https://github.com/ry2050/myopen-app-game-tictactoe';
const String _youtubeVideoUrl = 'https://www.youtube.com/watch?v=your-video-id';
const String _youtubeChannelUrl = 'https://www.youtube.com/@CodeTo2050';
const String _githubRepoLicenseUrl = 'https://github.com/ry2050/myopen-app-game-tictactoe?tab=MIT-1-ov-file#readme';
const String _authorName = 'Robert Yang - Myopen.app';

late PackageInfo pkgInfo;

Future<void> _openExternalLink(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final launched = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('無法開啟連結')),
    );
  }
}

Widget _linkText(BuildContext context, String url, {String? label}) {
  final colorScheme = Theme.of(context).colorScheme;
  return InkWell(
    onTap: () => _openExternalLink(context, url),
    child: Text(
      label ?? url,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pkgInfo = await PackageInfo.fromPlatform();

  // 預先載入 App 版本資訊
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '井字遊戲',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _board = List.filled(9, '');
  final Random _random = Random();

  String _winner = '';
  bool _isPlayerTurn = true;
  int _level = 0;

  void _resetGame() {
    setState(() {
      for (var i = 0; i < _board.length; i++) {
        _board[i] = '';
      }
      _winner = '';
      _isPlayerTurn = true;
    });
  }

  void _onTapCell(int index) {
    if (!_isPlayerTurn || _winner.isNotEmpty || _board[index].isNotEmpty) {
      return;
    }

    setState(() {
      _board[index] = 'O';
      _winner = _checkWinner();
      if (_winner.isEmpty && _isBoardFull()) {
        _winner = 'draw';
      }
      if (_winner.isEmpty) {
        _isPlayerTurn = false;
      }
    });

    if (_winner.isEmpty) {
      _computerMove();
    }
  }

  void _computerMove() {
    final moveIndex = _level == 0 ? _randomMove() : _smartMove();
    if (moveIndex == null) {
      return;
    }
    setState(() {
      _board[moveIndex] = 'X';
      _winner = _checkWinner();
      if (_winner.isEmpty && _isBoardFull()) {
        _winner = 'draw';
      }
      _isPlayerTurn = true;
    });
  }

  bool _isBoardFull() {
    return _board.every((cell) => cell.isNotEmpty);
  }

  int? _randomMove() {
    final emptyIndexes = <int>[];
    for (var i = 0; i < _board.length; i++) {
      if (_board[i].isEmpty) {
        emptyIndexes.add(i);
      }
    }
    if (emptyIndexes.isEmpty) {
      return null;
    }
    return emptyIndexes[_random.nextInt(emptyIndexes.length)];
  }

  int? _smartMove() {
    final winIndex = _findWinningMove('X');
    if (winIndex != null) {
      return winIndex;
    }
    final blockIndex = _findWinningMove('O');
    if (blockIndex != null) {
      return blockIndex;
    }
    return _randomMove();
  }

  int? _findWinningMove(String symbol) {
    for (var i = 0; i < _board.length; i++) {
      if (_board[i].isNotEmpty) {
        continue;
      }
      _board[i] = symbol;
      final result = _checkWinner();
      _board[i] = '';
      if (result == symbol) {
        return i;
      }
    }
    return null;
  }

  String _checkWinner() {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final line in lines) {
      final a = _board[line[0]];
      final b = _board[line[1]];
      final c = _board[line[2]];
      if (a.isNotEmpty && a == b && b == c) {
        return a;
      }
    }
    return '';
  }

  String _statusText() {
    if (_winner == 'O') {
      return 'You Win!';
    }
    if (_winner == 'X') {
      return 'You Lose!';
    }
    if (_winner == 'draw') {
      return '平手！';
    }
    return _isPlayerTurn ? '輪到你 (O)' : '手機回合 (X)';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boardSize = (size.width * 0.8).clamp(0, size.height * 0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('井字遊戲'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            tooltip: '關於本程式',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              '模式',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _winner.isEmpty
                      ? () {
                          setState(() {
                            _level = 0;
                          });
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        _level == 0 ? Colors.teal.shade100 : null,
                  ),
                  child: const Text('亂數不思考的手機'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _winner.isEmpty
                      ? () {
                          setState(() {
                            _level = 1;
                          });
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        _level == 1 ? Colors.teal.shade100 : null,
                  ),
                  child: const Text('認真思考的手機'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 32,
              child: Center(
                child: Text(
                  _statusText(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: boardSize.toDouble(),
                  height: boardSize.toDouble(),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _onTapCell(index),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.teal.shade700,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _board[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(color: Colors.teal.shade900),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => _openExternalLink(context, _githubRepoUrl),
                    child: const Text('GitHub Repo'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => _openExternalLink(context, _youtubeVideoUrl),
                    child: const Text('YouTube 影片'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: Center(
                child: Visibility(
                  visible: _winner.isNotEmpty,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: ElevatedButton(
                    onPressed: _resetGame,
                    child: const Text('再玩一次'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    String fullVersion = 'v${pkgInfo.version}+${pkgInfo.buildNumber}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('關於本程式'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'MyOpen.app - 井字遊戲',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            '這是用 Flutter 程式語言開發跨 iOS / Android 的一頁式井字遊戲範例。',
          ),
          const SizedBox(height: 24),
          Text(
            'YouTube 教學影片',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _linkText(context, _youtubeVideoUrl),
          const SizedBox(height: 16),
          Text(
            'GitHub 原始程式碼網址',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _linkText(context, _githubRepoUrl),
          const SizedBox(height: 16),
          Text(
            'MyOpen.app - YouTube 頻道',
            style: Theme.of(context).textTheme.titleMedium,
          ),          
          const SizedBox(height: 8),
          _linkText(context, _youtubeChannelUrl),
          const SizedBox(height: 24),
          Text(
            '版權宣告',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _linkText(context, _githubRepoLicenseUrl, label: 'MIT License'),
          const SizedBox(height: 24),
          Text(
            '使用技術',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Flutter / Dart'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              showLicensePage(
                context: context,
                applicationName: '井字遊戲',
                applicationVersion: fullVersion
              );
            },
            child: const Text('查看 Flutter 授權'),
          ),
          const SizedBox(height: 24),
          Text(
            '作者',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(_authorName),
          const SizedBox(height: 16),
          Text(
            '版本',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(fullVersion),
        ],
      ),
    );
  }
}
