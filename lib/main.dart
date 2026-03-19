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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('zh'), // Chinese
      ],
      locale: const Locale('zh'), // Default to Chinese
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF00695C), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          secondary: const Color(0xFFFF7043),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      home: const HomeScreen(),
      routes: {
        '/study': (context) => const StudyScreen(),
        '/words': (context) => const WordListScreen(),
      },
    );
  }
}
