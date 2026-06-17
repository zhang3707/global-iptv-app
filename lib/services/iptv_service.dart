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
    
    // 🎯 核心一：借道超能力！让手机去请求那个 100% 能在国内解析成功的 tv 域名！
    // 这样手机底层网卡一看是 tv，1毫秒内秒速拿到那组绝对不卡壳的干净 CF 物理 IP！
    // 强行用 `http://（不带S）彻底降维绕过` TLS 证书不匹配报错（ERR_SSL...）
    var url = Uri.parse("http://tv.zhangjian3707.dpdns.org/fetch?country=$safeCountry");

    final Map<String, String> safeHeaders = {
      // 🎯 核心二：主权完美隔离！
      // 流量拿着 tv 的干净 IP 撞进 Cloudflare 机房后，全凭这个 Host 头，
      // 精准、毫无差错地滑入你 IPTV 的专属 Worker（wandering-snow-7774）里！
      // 绝对不会混用，业务主权百分之百独立！
      "Host": "wandering-snow-7774.zhang37078381.workers.dev",
      
      "User-Agent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36",
      "Accept": "application/json",
    };

    try {
      var response = await http.get(url, headers: safeHeaders);
      
      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body) as List;
        return jsonList.map((e) => Channel.fromJson(e)).toList();
      } else {
        throw Exception("【借道成功：但业务报错】状态码: ${response.statusCode}, 详情: ${response.body}");
      }
    } catch (e, stack) {
      rethrow;
    }
  }

  static String getCountryName(String countryCode) {
    return countryCodes[countryCode] ?? countryCode;
  }
}