import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_vocab/providers/word_provider.dart';
import 'package:my_vocab/models/word.dart';
import 'package:my_vocab/services/tts_service.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  // Use shared TTSService instead of direct FlutterTts
  final TTSService _ttsService = TTSService();
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    // No explicit init needed as instance does it, but good practice
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final provider = Provider.of<WordProvider>(context, listen: false);
       if (provider.wordsDue.isNotEmpty) {
         _ttsService.speak(provider.wordsDue.first.word);
       }
    });
  }

  Future<void> _speak(String text) async {
    await _ttsService.speak(text);
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('学习中'), 
        // 进度条在顶部：今日已学 / 总需学
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Consumer<WordProvider>(
            builder: (ctx, p, _) {
              // 此处仅示例，需在 Provider 中加个 countTodayDone
              return LinearProgressIndicator(
                value: 0.3, // Mock value
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C2C2C)),
              );
            },
          ),
        ),
      ),
      body: Consumer<WordProvider>(
        builder: (context, provider, child) {
          if (provider.wordsDue.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text('今日任务完成！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回首页'),
                  )
                ],
              ),
            );
          }

          final word = provider.wordsDue.first;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                
                // 单词主显示区
                Center(
                  child: GestureDetector(
                    onTap: () => _speak(word.word), // 点击单词发音
                    child: Column(
                      children: [
                        Text(
                          word.word,
                          style: const TextStyle(
                            fontSize: 42, 
                            fontWeight: FontWeight.w900, 
                            fontFamily: 'Serif', 
                            letterSpacing: 1.2
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // 音标或者是发音图标
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.volume_up_rounded, size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('美音', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 3),

                // 释义区域 (如果不认识，点击哪里显示？还是直接显示？按照百词斩风格，先看图/词，然后选)
                // 这里我们做成 Anki 风格：点击屏幕显示答案
                if (!_showBack) 
                  Center(
                    child: TextButton(
                      onPressed: () {
                         setState(() { _showBack = true; });
                         // 可以在这里播放一下例句 TTS
                      },
                      child: Text(
                        '点击查看释义', 
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ),
                  )
                else ...[
                  // 释义显示
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.definition,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                        ),
                        if (word.example != null && word.example!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            word.example!,
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700], height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                const Spacer(flex: 2),

                // 底部操作栏
                if (!_showBack)
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() { _showBack = true; });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        elevation: 0,
                      ),
                      child: const Text('查看答案', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  Row(
                    children: [
                      // 忘记了
                      Expanded(
                        child: _ReviewButton(
                          color: const Color(0xFFFF6B6B), 
                          label: '忘记', 
                          subLabel: '重来',
                          onTap: () => _handleReview(context, word, 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 模糊
                      Expanded(
                        child: _ReviewButton(
                          color: const Color(0xFFFFB74D), 
                          label: '模糊', 
                          subLabel: '1天后',
                          onTap: () => _handleReview(context, word, 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 认识
                      Expanded(
                        child: _ReviewButton(
                          color: const Color(0xFF4DB6AC), 
                          label: '认识', 
                          subLabel: '4天后',
                          onTap: () => _handleReview(context, word, 3), // Good
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleReview(BuildContext context, Word word, int difficulty) {
    Provider.of<WordProvider>(context, listen: false).reviewWord(word, difficulty);
    setState(() {
      _showBack = false;
      // 这里的逻辑稍微需要在 Provider 里改一下，因为 Provider.reviewWord 会刷新列表
      // 如果刷新了列表，wordsDue.first 就会变，所以我们需要等待刷新
      // 下次循环自动会拿到新的 first
      
      // 可以在这里自动播放下一个词
      WidgetsBinding.instance.addPostFrameCallback((_) {
         final p = Provider.of<WordProvider>(context, listen: false);
         if (p.wordsDue.isNotEmpty) {
           _speak(p.wordsDue.first.word);
         }
      });
    });
  }
}

class _ReviewButton extends StatelessWidget {
  final Color color;
  final String label;
  final String subLabel;
  final VoidCallback onTap;

  const _ReviewButton({
    required this.color,
    required this.label,
    required this.subLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subLabel, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
