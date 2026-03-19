import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _useOnline = true;

  Future<void> init() async {
    // 基础TTS初始化，防止离线无法使用
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
  }
  
  // 暴露一个公共的 speak
  Future<void> speak(String word) async {
    // 优先尝试网络发音
    bool success = false;
    if (_useOnline) {
      success = await _playOnline(word);
    }
    
    // 如果网络发音失败（包括网络不通、超时、IPv6问题等），降级为本地TTS
    if (!success) {
      await _flutterTts.speak(word);
    }
  }

  Future<bool> _playOnline(String word) async {
    try {
      // 使用有道词典的真人美音API (type=2)
      // 这个API支持HTTPS，且服务端支持IPv4/IPv6双栈访问
      final url = "https://dict.youdao.com/dictvoice?audio=$word&type=2";
      
      // 先做一次HEAD请求探测，验证网络连通性
      // 如果手机只连了IPv6，只要DNS解析正常，这个请求就能通
      final response = await http.head(Uri.parse(url)).timeout(const Duration(milliseconds: 1500));
      
      if (response.statusCode == 200) {
        await _audioPlayer.play(UrlSource(url));
        return true;
      }
    } catch (e) {
      // 默默捕获异常，方便降级
      // print("Network TTS Error: $e"); 
    }
    return false;
  }
  
  Future<void> stop() async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
  }
}

