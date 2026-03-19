import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_vocab/providers/word_provider.dart';
import 'package:my_vocab/screens/settings_screen.dart';
import 'package:my_vocab/screens/word_list_screen.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _now = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 首次加载，获取数据，确保数字是正确的
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WordProvider>(context, listen: false).loadWords();
    });
    // 时钟
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 简单的“今日打卡”逻辑（需要持久化，这里先模拟）
    // 实际上应该存入 SharedPrefs
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部行：日期 + 设置
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         DateFormat('EEEE', 'zh_CN').format(_now), // 星期几
                         style: TextStyle(
                           fontSize: 14, 
                           color: Colors.grey[600],
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                       Text(
                         DateFormat('M月d日').format(_now), // 日期
                         style: const TextStyle(
                           fontSize: 24, 
                           fontWeight: FontWeight.bold,
                           color: Color(0xFF2C2C2C),
                         ),
                       ),
                     ],
                   ),
                   IconButton(
                     onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                     icon: const Icon(Icons.settings_outlined, size: 28),
                   ),
                ],
              ),
              const SizedBox(height: 48),

              // 核心仪表盘
              Consumer<WordProvider>(
                builder: (context, provider, child) {
                  int due = provider.wordsDue.length; // 今日需复习
                  int total = provider.words.length; // 总词库
                  // 计算某种即使还没开始也很酷的“可复习量”
                  
                  return Center(
                    child: Column(
                      children: [
                        // 大圆圈或者是大数字
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$due',
                                style: const TextStyle(
                                  fontSize: 64, 
                                  fontWeight: FontWeight.w900, // 像百词斩那种大粗字体
                                  color: Color(0xFF2C2C2C),
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                due > 0 ? '今日待复习' : '今日已完成',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: due > 0 ? const Color(0xFFFF6B6B) : Colors.green, // 红色紧迫感，绿色成就感
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // 两个小数据块
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                             GestureDetector(
                               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WordListScreen())),
                               child: _buildInfoItem('总词汇量', '$total'),
                             ),
                             _buildInfoItem('累计坚持', '1 天'), // 这个以后做
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),
              
              // 底部巨大按钮
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/study'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C), // 纯黑高级感
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                    shadowColor: const Color(0x33000000),
                  ),
                  child: const Text(
                    '开始背单词', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }
}
