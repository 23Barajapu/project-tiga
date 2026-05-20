/// Konfigurasi jaringan — sesuaikan IP jika laptop/ESP berubah.
class AppConfig {
  static const String laptopIp = '192.168.137.123';
  static const String espCamIp = '192.168.137.156';
  /// ESP32 servo — samakan dengan SERVO_ESP_IP di main.py
  static const String espServoIp = '192.168.137.155';
  static const int laravelPort = 8001;
  static const int aiStreamPort = 8888;

  static String get apiBaseUrl => 'http://$laptopIp:$laravelPort/api';
  static String get storageBaseUrl => 'http://$laptopIp:$laravelPort';
  static String get videoStreamUrl =>
      'http://$laptopIp:$aiStreamPort/video_feed';
}
