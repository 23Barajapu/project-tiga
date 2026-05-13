import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import '../../providers/qc_state_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/history_view.dart';
import 'history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Smart QC Analytics',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        actions: [
          IconButton(
            tooltip: "Refresh Data",
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.accentNeonGreen,
              size: 26,
            ),
            onPressed: () async {
              await context.read<QcStateProvider>().fetchHistoryData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data diperbarui"),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppTheme.accentNeonGreen,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<QcStateProvider>(
        builder: (context, provider, child) {
          double total = (provider.ripeCount + provider.unripeCount).toDouble();
          double qualityRate = total > 0 ? (provider.ripeCount / total) * 100 : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 0. WARNING BANNER ---
                if (provider.historyLogs.any((r) => r.tss == null && !r.isError))
                  _buildWarningBanner(),

                // --- 1. LIVE MONITORING SECTION ---
                _buildLiveHeader(),
                const SizedBox(height: 12),
                _buildLiveStream(),
                
                const SizedBox(height: 25),

                // --- 2. ANALYTICS CARD ---
                _buildAnalyticsCard(context, qualityRate, provider.ripeCount, provider.unripeCount),

                const SizedBox(height: 30),

                // --- 3. RECENT SCANS SECTION (WITH LABELING & PHOTOS) ---
                _buildRecentScansHeader(context),
                const SizedBox(height: 16),

                provider.historyLogs.isEmpty
                    ? _buildEmptyState()
                    : HistoryView(
                        records: provider.historyLogs,
                        onTapRecord: (record) {
                          if (record.recommendation == null && !record.isError) {
                            _showTssInputSheet(context, record, provider);
                          }
                        },
                      ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Input TSS Diperlukan",
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text("Ada beberapa hasil deteksi yang belum diinputkan nilai TSS nya.",
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('LIVE MONITORING',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.2)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: const [
              Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
              SizedBox(width: 4),
              Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStream() {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentNeonGreen.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(color: AppTheme.accentNeonGreen.withOpacity(0.1), blurRadius: 25, spreadRadius: 2)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: Mjpeg(
                isLive: true,
                // Menggunakan IP khusus Emulator untuk akses Laptop
                stream: 'http://10.102.0.222:8888/video_feed',
                fit: BoxFit.cover,
                error: (context, error, stack) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.videocam_off_rounded, color: Colors.white24, size: 50),
                    SizedBox(height: 10),
                    Text("Waiting for AI Stream...", style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.2), Colors.transparent, Colors.black.withOpacity(0.2)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScansHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('RECENT SCANS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
          child: const Text('VIEW ALL',
              style: TextStyle(fontSize: 12, color: AppTheme.accentNeonGreen, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text("No scan data available", style: TextStyle(color: Colors.white24, fontSize: 12)),
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, double rate, int ripe, int unripe) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentNeonGreen.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text("OVERALL QUALITY RATE",
              style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Text("${rate.toStringAsFixed(1)}%",
              style: const TextStyle(color: AppTheme.accentNeonGreen, fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: rate / 100,
              backgroundColor: Colors.white10,
              color: AppTheme.accentNeonGreen,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("MATANG", ripe.toString(), AppTheme.accentNeonGreen),
              Container(width: 1, height: 30, color: Colors.white10),
              _buildStatItem("MENTAH", unripe.toString(), Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showTssInputSheet(BuildContext context, HistoryRecord record, QcStateProvider provider) {
    TextEditingController tssController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text("INPUT NILAI TSS (°Brix)",
                style: TextStyle(color: AppTheme.accentNeonGreen, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: tssController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(filled: true, fillColor: Colors.black26, hintText: "Example: 12.5"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentNeonGreen),
                onPressed: () async {
                  if (tssController.text.isNotEmpty) {
                    final messenger = ScaffoldMessenger.of(context);
                    await provider.updateTss(record.id, double.parse(tssController.text));
                    if (context.mounted) Navigator.pop(context);
                    messenger.showSnackBar(const SnackBar(
                        content: Text("Data Terupdate!"), backgroundColor: AppTheme.accentNeonGreen));
                  }
                },
                child: const Text("SIMPAN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}