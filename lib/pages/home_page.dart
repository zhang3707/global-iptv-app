import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/iptv_service.dart';
import 'player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final IptvService _iptvService = IptvService();
  String _selectedCountry = 'CN';
  List<Channel> _channels = [];
  bool _isLoading = true;
  
  // 1. 黑匣子日志变量
  String debugLog = "尚未加载数据...";
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadChannels(_selectedCountry);
  }

  // 2. 超高容错数据拉取函数
  Future<void> _loadChannels(String countryCode) async {
    try {
      setState(() {
        debugLog = "正在全力撞击网关：https://gjtv.zhangjian3707.dpdns.org/fetch?country=${countryCode.toLowerCase()} ...";
        hasError = false;
        _isLoading = true;
      });

      // 调用请求服务
      final channels = await _iptvService.fetchChannels(countryCode);
      
      setState(() {
        _isLoading = false;
        if (channels == null || channels.isEmpty) {
          debugLog = "⚠️ 警告：网关通了，但返回的数据竟然是空的（List.isEmpty）！\n\n请求URL:\nhttps://gjtv.zhangjian3707.dpdns.org/fetch?country=${countryCode.toLowerCase()}";
          hasError = true;
        } else {
          debugLog = "✅ 成功拉取到 ${channels.length} 个频道！";
          _channels = channels;
        }
      });
    } catch (e, stackTrace) {
      // 🔔 极其高能：捕获任何崩溃，变成文字！
      setState(() {
        _isLoading = false;
        hasError = true;
        debugLog = "🚨 抓到核心崩溃地雷！\n\n【错误原因】:\n$e\n\n【崩溃堆栈】:\n$stackTrace\n\n【请求URL】:\nhttps://gjtv.zhangjian3707.dpdns.org/fetch?country=${countryCode.toLowerCase()}";
      });
    }
  }

  void _onCountryChanged(String countryCode) {
    setState(() {
      _selectedCountry = countryCode;
    });
    _loadChannels(countryCode);
  }

  Color _getCardColor(int delay) {
    if (delay < 500) return Colors.green[900]!;
    if (delay < 1000) return Colors.yellow[900]!;
    if (delay < 2000) return Colors.orange[900]!;
    return Colors.red[900]!;
  }

  Widget buildChannelCard(Channel channel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerPage(channel: channel),
          ),
        );
      },
      child: Card(
        color: _getCardColor(channel.delay),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    channel.resolution,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${channel.delay}ms',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          '${_iptvService.getCountryName(_selectedCountry)} IPTV',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text(
                '亚洲频道',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...IptvService.asianCountries.map((country) {
              return ListTile(
                leading: const Icon(Icons.language, color: Colors.white),
                title: Text(
                  _iptvService.getCountryName(country),
                  style: TextStyle(
                    color: _selectedCountry == country ? Colors.green : Colors.white,
                    fontWeight: _selectedCountry == country ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: _selectedCountry == country,
                selectedTileColor: Colors.green.withOpacity(0.2),
                onTap: () {
                  _onCountryChanged(country);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
      // 3. 黑匣子日志渲染：出错时强行吐出日志
      body: hasError
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                debugLog,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            )
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: _channels.length,
                    itemBuilder: (context, index) {
                      return buildChannelCard(_channels[index]);
                    },
                  ),
                ),
    );
  }
}