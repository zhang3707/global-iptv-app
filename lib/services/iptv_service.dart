import 'dart:convert';
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

  static Future<List<Channel>> getChannels(String country) async {
    String safeCountry = country.trim().toLowerCase();
    var url = Uri.parse("https://gjtv.zhangjian3707.dpdns.org/fetch?country=$safeCountry");

    final Map<String, String> safeHeaders = {
      "User-Agent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36",
      "Accept": "application/json",
    };

    try {
      var response = await http.get(url, headers: safeHeaders);

      // 🚨 显微镜一号：如果网关回了 [] 空数组，强行物理剥离，抓出最真实的网络特征
      if (response.body == "[]" || response.body.trim() == "[]") {
        throw Exception(
          "【真实日志：网关主动吐空】\n"
          "■ HTTP状态码: ${response.statusCode}\n"
          "■ 网关响应头(Headers):\n${encoder.convert(response.headers)}\n"
          "■ 提示: 说明UA伪装有效，但Worker由于你的手机IP段/TLS指纹，仍然执行了内部拦截！"
        );
      }

      // 🚨 显微镜二号：如果拿到了数据，但是在下面的解析层、强类型转换时崩溃了
      if (response.statusCode == 200) {
        // 打印原始报文前100个字符看看是不是真的拿到了
        print("Raw Body: ${response.body}");
        
        var jsonList = json.decode(response.body);
        if (jsonList is! List) {
          throw Exception("【类型地雷】: 网关返回的不是标准的 List 数组，而是: ${jsonList.runtimeType}");
        }
        
        return jsonList.map((e) => Channel.fromJson(e)).toList();
      } else {
        throw Exception("【网络阻断】: 状态码异常: ${response.statusCode}");
      }
    } catch (e, stack) {
      // 强行把底层的网络报错、格式报错、或者强类型报错全部扔给首页的 try-catch
      rethrow;
    }
  }

  String getCountryName(String countryCode) {
    return countryCodes[countryCode] ?? countryCode;
  }
}

// 极简工具，方便格式化输出 Headers JSON
const JsonEncoder encoder = JsonEncoder.withIndent('  ');