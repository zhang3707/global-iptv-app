import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class IptvService {
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

  static Future<List<Channel>> getChannels(String country) async {
    String safeCountry = country.trim().toLowerCase();
    
    // 🎯 物理直连亲手复活、全网免封锁的黄金二级域名
    var url = Uri.parse("https://gjtv.zhangjian3707.dpdns.org/fetch?country=$safeCountry");

    final Map<String, String> safeHeaders = {
      "User-Agent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36",
      "Accept": "application/json",
    };

    try {
      var response = await http.get(url, headers: safeHeaders);
      
      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body) as List;
        return jsonList.map((e) => Channel.fromJson(e)).toList();
      } else {
        throw Exception("【网关异常】状态码: ${response.statusCode}, 内容: ${response.body}");
      }
    } catch (e, stack) {
      rethrow;
    }
  }

  static String getCountryName(String countryCode) {
    return countryCodes[countryCode] ?? countryCode;
  }
}