import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class IptvService {
  static const String _baseUrl = "https://gjtv.zhangjian3707.dpdns.org/fetch";
  
  static const Map<String, String> countryCodes = {
    'CN': '中国',
    'HK': '香港',
    'TW': '台湾',
    'MO': '澳门',
    'SG': '新加坡',
    'MY': '马来西亚',
    'TH': '泰国',
    'VN': '越南',
    'ID': '印度尼西亚',
    'PH': '菲律宾',
    'MM': '缅甸',
    'IN': '印度',
  };

  static const List<String> asianCountries = [
    'CN', 'HK', 'TW', 'MO', 'SG', 'MY', 'TH', 'VN', 'ID', 'PH', 'MM', 'IN'
  ];

  Future<List<Channel>> fetchChannels(String countryCode) async {
    try {
      // 🔔 工业级容错：强行去除两端空格，并全量转换为纯小写！确保和 Worker 完美咬合！
      final safeCountry = countryCode.trim().toLowerCase();
      final gatewayUrl = "$_baseUrl?country=$safeCountry";
      
      // 📡 打印完整请求URL，方便调试
      print("🌐 正在请求: $gatewayUrl");
      print("📦 原始国家代码: '$countryCode' → 安全转换后: '$safeCountry'");
      
      // 🛠️ 强行焊上顶级浏览器伪装，把 Dart 字样彻底抹除！突破网关熔断防护！
      final Map<String, String> safeHeaders = {
        "User-Agent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36",
        "Accept": "application/json",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
      };
      
      // 发起带有顶级伪装的网络撞击
      final response = await http.get(Uri.parse(gatewayUrl), headers: safeHeaders);

      print("📥 响应状态码: ${response.statusCode}");
      print("📥 响应体长度: ${response.bodyBytes.length} bytes");

      if (response.statusCode == 200) {
        final String rawBody = utf8.decode(response.bodyBytes);
        print("📥 响应内容预览: ${rawBody.substring(0, rawBody.length > 200 ? 200 : rawBody.length)}");
        
        // 🔔 极其硬核的真机日志雷达：如果返回的数据为空数组或空，强行抛出异常！
        if (rawBody == "[]" || rawBody.isEmpty) {
          throw Exception("🚨 网关确实回了空数组！\n状态码: ${response.statusCode}\n原始响应头: ${response.headers}\n响应体: '$rawBody'");
        }
        
        final List<dynamic> jsonData = json.decode(rawBody);
        print("✅ 解析成功，频道数量: ${jsonData.length}");
        return jsonData.map((item) => Channel.fromJson(item)).toList();
      } else {
        throw Exception("HTTP 请求失败，状态码: ${response.statusCode}");
      }
    } catch (e) {
      print("📡 网关并网失败: $e");
      return [];
    }
  }

  Future<List<Channel>> loadChannelsFromLocal(String countryCode) async {
    try {
      final String filePath;
      if (Uri.base.scheme == 'file') {
        filePath = '../global-iptv-engine/output/api_${countryCode.toLowerCase()}.json';
      } else {
        filePath = '/data/data/com.example.global_iptv_app/files/api_${countryCode.toLowerCase()}.json';
      }
      
      final file = await http.get(Uri.file(filePath));
      if (file.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(file.bodyBytes));
        return jsonData.map((item) => Channel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("📁 本地加载失败: $e");
      return [];
    }
  }

  String getCountryName(String countryCode) {
    return countryCodes[countryCode] ?? countryCode;
  }
}
