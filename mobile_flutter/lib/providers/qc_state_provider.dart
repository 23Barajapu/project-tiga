import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../presentation/widgets/history_view.dart';

class QcStateProvider extends ChangeNotifier {
  // IP Laptop kamu - Pastikan Laravel sudah running di IP ini
  final String baseUrl = "http://10.102.0.222:8000/api";

  bool isLedOn = true;
  bool isScanning = false;

  double weight = 0.0;
  double voc = 0.0;
  double temperature = 0.0;
  double humidity = 0.0;

  String aiStatus = 'WAITING...';
  double confidenceScore = 0.0;

  // Hanya tampilkan 2 kategori utama sesuai request
  int ripeCount = 0;
  int unripeCount = 0;

  Timer? _pollingTimer;
  List<HistoryRecord> historyLogs = [];

  QcStateProvider() {
    fetchHistoryData();
    _startPolling();
  }

  Future<void> fetchHistoryData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pineapple/history'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // 1. Mapping SELURUH data dari database tanpa limit
          List<HistoryRecord> allRecords = data.map((item) {
            String statusRaw = item['status'] ?? 'UNKNOWN';
            String gradeText = "";
            bool isError = false;

            if (statusRaw == 'RIPE') {
              gradeText = "Grade A - Matang";
            } else if (statusRaw == 'HALF_RIPE') {
              gradeText = "Grade B - Setengah";
            } else {
              gradeText = "Grade C - Mentah";
              isError = true;
            }

            return HistoryRecord(
              id: item['id'],
              title: gradeText,
              time: item['created_at'].toString().substring(11, 16),
              subtitle: 'Confidence: ${item['confidence_score']}%',
              badgeText: '${item['confidence_score']}% Match',
              isError: isError,
              recommendation: item['recommendation'],
              tss: item['tss'] != null
                  ? double.tryParse(item['tss'].toString())
                  : null,
              imageUrl: item['image_url'] != null
                  ? "${baseUrl.replaceAll('/api', '')}/storage/${item['image_url']}"
                  : null,
            );
          }).toList();

          // 2. TAMPILAN DASHBOARD: Tetap limit 10 agar UI tidak berat/lag
          // Tapi data perhitungan (ripe/unripe) tetap pakai 'data' yang lengkap
          historyLogs = allRecords.take(10).toList();

          // 3. Update Dashboard Stats (Berdasarkan data terbaru/indeks 0)
          var latest = data.first;
          aiStatus = (latest['status'] == 'RIPE' || latest['status'] == 'HALF_RIPE')
                  ? 'MATANG'
                  : 'MENTAH';

          confidenceScore = double.tryParse(latest['confidence_score'].toString()) ?? 0.0;
          weight = double.tryParse(latest['weight'].toString()) ?? 0.0;
          voc = double.tryParse(latest['gas_value'].toString()) ?? 0.0;
          temperature = double.tryParse(latest['temperature'].toString()) ?? 0.0;
          humidity = 65.0; 

          // 4. HITUNG REAL STATS (Dari 757 data database)
          // Ini yang bikin angka di Analytics Card kamu akurat
          ripeCount = data
              .where((item) =>
                  item['status'] == 'RIPE' || item['status'] == 'HALF_RIPE')
              .length;

          unripeCount = data
              .where((item) =>
                  item['status'] != 'RIPE' && item['status'] != 'HALF_RIPE')
              .length;
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error Fetching Data: $e");
    }
  }
  // Fungsi untuk Update TSS dari Flutter
  Future<bool> updateTss(int id, double tssValue) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pineapple/update-tss/$id'),
        body: {'tss': tssValue.toString()},
      );

      if (response.statusCode == 200) {
        // Refresh data agar list history langsung terupdate visualnya
        await fetchHistoryData();
        return true;
      }
      return false;
    } catch (e) {
      print("Error Update TSS: $e");
      return false;
    }
  }

  void _startPolling() {
    // Polling setiap 3 detik untuk sinkronisasi data otomatis
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchHistoryData();
    });
  }

  void toggleLed(bool val) {
    isLedOn = val;
    notifyListeners();
  }

  Future<void> triggerScan() async {
    if (isScanning) return;
    isScanning = true;
    notifyListeners();
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/nanas/status?status=1'));
      if (response.statusCode == 200) {
        await fetchHistoryData();
      }
    } catch (e) {
      aiStatus = 'CONNECTION ERROR';
    } finally {
      isScanning = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
