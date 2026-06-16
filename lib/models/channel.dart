class Channel {
  final String channel;
  final String title;
  final String url;
  final String userAgent;
  final int delay;
  final int speedKbs;
  final String resolution;

  Channel({
    required this.channel,
    required this.title,
    required this.url,
    required this.userAgent,
    required this.delay,
    required this.speedKbs,
    required this.resolution,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      channel: json['channel'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      userAgent: json['user_agent'] ?? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      delay: json['delay'] ?? 999,
      speedKbs: json['speed_kbs'] ?? 0,
      resolution: json['resolution'] ?? '1080p',
    );
  }
}
