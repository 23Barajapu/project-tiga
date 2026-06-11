import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/qc_state_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/history_view.dart';
import '../widgets/custom_bottom_nav.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentPage = 1;
  static const int _pageSize = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('All Scan History', style: TextStyle(color: AppTheme.accentNeonGreen, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.accentNeonGreen),
      ),
      body: RefreshIndicator(
        color: AppTheme.accentNeonGreen,
        onRefresh: () async {
          await context.read<QcStateProvider>().fetchHistoryData();
          setState(() {
            _currentPage = 1; // Reset to page 1 on manual refresh
          });
        },
        child: Consumer<QcStateProvider>(
          builder: (context, provider, child) {
            final logs = provider.historyLogs;
            if (logs.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('No scan history found.', style: TextStyle(color: Colors.white54))),
                ],
              );
            }

            final int totalItems = logs.length;
            final int totalPages = (totalItems / _pageSize).ceil();

            if (_currentPage > totalPages) {
              _currentPage = totalPages > 0 ? totalPages : 1;
            }

            final int startIndex = (_currentPage - 1) * _pageSize;
            int endIndex = startIndex + _pageSize;
            if (endIndex > totalItems) {
              endIndex = totalItems;
            }

            final pageLogs = logs.sublist(startIndex, endIndex);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  if (logs.any((r) => r.tss == null && !r.isError))
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Beberapa data deteksi memerlukan input nilai TSS untuk memproses rekomendasi.",
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Menampilkan ${startIndex + 1} - $endIndex dari $totalItems data",
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        Text(
                          "Halaman $_currentPage / $totalPages",
                          style: const TextStyle(color: AppTheme.accentNeonGreen, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  HistoryView(
                    records: pageLogs,
                    onTapRecord: (record) => _showTssInputSheet(context, record, provider),
                  ),

                  const SizedBox(height: 20),

                  if (totalPages > 1)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accentNeonGreen.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentPage > 1 ? AppTheme.accentNeonGreen.withValues(alpha: 0.1) : Colors.transparent,
                              foregroundColor: _currentPage > 1 ? AppTheme.accentNeonGreen : Colors.white24,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: _currentPage > 1 ? AppTheme.accentNeonGreen.withValues(alpha: 0.3) : Colors.white10,
                                ),
                              ),
                            ),
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                            label: const Text("PREV", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),

                          Text(
                            "$_currentPage",
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentPage < totalPages ? AppTheme.accentNeonGreen.withValues(alpha: 0.1) : Colors.transparent,
                              foregroundColor: _currentPage < totalPages ? AppTheme.accentNeonGreen : Colors.white24,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: _currentPage < totalPages ? AppTheme.accentNeonGreen.withValues(alpha: 0.3) : Colors.white10,
                                ),
                              ),
                            ),
                            onPressed: _currentPage < totalPages
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                : null,
                            icon: const Text("NEXT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            label: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),

            if (record.imageUrl != null)
              Container(
                width: double.infinity, height: 200,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentNeonGreen.withValues(alpha: 0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.network(
                    record.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const Center(
                      child: Icon(Icons.broken_image_rounded, color: Colors.white24, size: 40),
                    ),
                  ),
                ),
              ),

            Text(record.title.toUpperCase(), style: const TextStyle(color: AppTheme.accentNeonGreen, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(record.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 20),

            if (record.recommendation == null && !record.isError) ...[
              const Text("INPUT NILAI TSS (°Brix)", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 12),
              TextField(
                controller: tssController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true, fillColor: Colors.black26, hintText: "0.0 - 32.0",
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentNeonGreen.withValues(alpha: 0.3))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentNeonGreen)),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentNeonGreen),
                  onPressed: () async {
                    if (tssController.text.isNotEmpty) {
                      final messenger = ScaffoldMessenger.of(context);
                      await provider.updateTss(record.id, double.parse(tssController.text));
                      if (context.mounted) Navigator.pop(context);
                      messenger.showSnackBar(const SnackBar(content: Text("Berhasil Perbarui Rekomendasi!"), backgroundColor: AppTheme.accentNeonGreen));
                    }
                  },
                  child: const Text("PROSES REKOMENDASI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else if (record.recommendation != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentNeonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text("REKOMENDASI PENGOLAHAN", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 8),
                    Text(record.recommendation!,
                        style: const TextStyle(color: AppTheme.accentNeonGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}