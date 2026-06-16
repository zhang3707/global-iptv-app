import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class IptvService {
  static const String _baseUrl = "https://wandering-snow-7774.zhang37078381.workers.dev/fetch";
  
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
      final gatewayUrl = "$_baseUrl?country=${countryCode.toLowerCase()}";
      final response = await http.get(Uri.parse(gatewayUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
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
