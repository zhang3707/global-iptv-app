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
      
      final response = await http.get(Uri.parse(gatewayUrl));

      print("📥 响应状态码: ${response.statusCode}");
      print("📥 响应体长度: ${response.bodyBytes.length} bytes");

      if (response.statusCode == 200) {
        final String rawBody = utf8.decode(response.bodyBytes);
        print("📥 响应内容预览: ${rawBody.substring(0, rawBody.length > 200 ? 200 : rawBody.length)}");
        
        final List<dynamic> jsonData = json.decode(rawBody);
        print("✅ 解析成功，频道数量: ${jsonData.length}");
        return jsonData.map((item) => Channel.fromJson(item)).toList();
      } else {
        throw Exception("网关应答异常: ${response.statusCode}");
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
