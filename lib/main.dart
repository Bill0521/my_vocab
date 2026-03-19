import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:my_vocab/providers/word_provider.dart';
import 'package:my_vocab/screens/home_screen.dart';
import 'package:my_vocab/screens/study_screen.dart';
import 'package:my_vocab/screens/word_list_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN', null);
  runApp(
    ChangeNotifierProvider(
      create: (context) => WordProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyVocab',
      debugShowCheckedModeBanner: false, // 去掉右上角那个丑陋的Debug标签
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'), 
      ],
      locale: const Locale('zh'),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        // 模仿“不背单词”的配色：米白背景 + 深色文字
        scaffoldBackgroundColor: const Color(0xFFF7F8FA), 
        primaryColor: const Color(0xFF2C2C2C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C2C2C),
          primary: const Color(0xFF2C2C2C),
          secondary: const Color(0xFFFF6B6B), // 活力红，用于强调
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8FA),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF2C2C2C), 
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto', // 英文显示更好看
          ),
          iconTheme: IconThemeData(color: Color(0xFF2C2C2C)),
        ),
        cardTheme: CardTheme(
          elevation: 0, // 扁平化
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C2C2C),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/study': (context) => const StudyScreen(),
        '/words': (context) => const WordListScreen(),
      },
    );
  }
}
