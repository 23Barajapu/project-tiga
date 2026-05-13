import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HistoryRecord {
  final int id;
  final String title;
  final String time;
  final String subtitle;
  final String badgeText;
  final bool isError;
  final String? recommendation;
  final double? tss; 
  final String? imageUrl; 

  HistoryRecord({
    required this.id,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.badgeText,
    this.isError = false,
    this.recommendation,
    this.tss, 
    this.imageUrl, 
  });
}

class HistoryView extends StatelessWidget {
  final List<HistoryRecord> records;
  final Function(HistoryRecord) onTapRecord;

  const HistoryView({super.key, required this.records, required this.onTapRecord});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        
        // LOCK CLICK: Jika sudah ada rekomendasi, onTap dimatikan (null)
        return InkWell(
          onTap: () => onTapRecord(record),
          borderRadius: BorderRadius.circular(12),
          child: _buildHistoryItem(record),
        );
      },
    );
  }

  Widget _buildHistoryItem(HistoryRecord record) {
    bool hasRec = record.recommendation != null;

    // Prioritas Border: 1. Rekomendasi (Selesai), 2. Error, 3. Belum TSS (Warning), 4. Transparan
    Color borderColor = Colors.transparent;
    if (hasRec) {
      borderColor = AppTheme.accentNeonGreen.withOpacity(0.3);
    } else if (record.isError) {
      borderColor = Colors.red.withOpacity(0.3);
    } else if (record.tss == null) {
      borderColor = Colors.orange.withOpacity(0.5);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _buildIcon(record),
          const SizedBox(width: 16),
          Expanded(child: _buildInfo(record)),
          _buildBadge(record),
        ],
      ),
    );
  }

  Widget _buildIcon(HistoryRecord record) {
    bool isError = record.isError;
    bool needsTss = record.tss == null && !isError;
    
    Color iconColor = isError ? Colors.redAccent : AppTheme.accentNeonGreen;
    if (needsTss) iconColor = Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isError ? Icons.cancel_outlined : (needsTss ? Icons.hourglass_empty_rounded : Icons.check_circle),
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildInfo(HistoryRecord record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        const SizedBox(height: 4),
        Text("Jam: ${record.time}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(record.subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        
        if (record.tss == null && !record.isError) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.edit_note_rounded, color: Colors.orangeAccent, size: 12),
                SizedBox(width: 4),
                Text(
                  "MENUNGGU INPUT TSS",
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],

        if (record.recommendation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentNeonGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "Rekomendasi: ${record.recommendation}",
              style: const TextStyle(color: AppTheme.accentNeonGreen, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ]
      ],
    );
  }

Widget _buildBadge(HistoryRecord record) {
  bool needsTss = record.tss == null && !record.isError;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      // Badge Match % yang sudah ada
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: record.isError 
              ? Colors.red.withOpacity(0.1) 
              : (needsTss ? Colors.orange.withOpacity(0.1) : AppTheme.accentNeonGreen.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8),
          border: needsTss ? Border.all(color: Colors.orange.withOpacity(0.3)) : null,
        ),
        child: Text(
          record.badgeText, 
          style: TextStyle(
            color: record.isError 
                ? Colors.redAccent 
                : (needsTss ? Colors.orangeAccent : AppTheme.accentNeonGreen), 
            fontWeight: FontWeight.bold, 
            fontSize: 11
          )
        ),
      ),
      
      // Tampilkan Nilai TSS jika sudah diinput, jika belum kasih warning teks
      if (record.tss != null) ...[
        const SizedBox(height: 6),
        Text(
          "${record.tss!.toStringAsFixed(1)} °Brix",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5
          ),
        ),
      ] else if (!record.isError) ...[
        const SizedBox(height: 6),
        const Text(
          "TSS: -",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ],
  );
}
}