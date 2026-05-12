import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ControlPanel extends StatelessWidget {
  final bool isScanning;
  final bool isLedOn;
  final VoidCallback onTriggerScan;
  final ValueChanged<bool> onLedToggled;

  const ControlPanel({
    super.key,
    required this.isScanning,
    required this.isLedOn,
    required this.onTriggerScan,
    required this.onLedToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentNeonGreen.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MANUAL CONTROLS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 16),
          
          // Trigger Scan Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: isScanning ? null : onTriggerScan,
              style: ElevatedButton.styleFrom(
                shadowColor: AppTheme.accentNeonGreen.withOpacity(0.5),
                elevation: 8,
              ),
              child: isScanning 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.primaryBackground, strokeWidth: 3)),
                      SizedBox(width: 12),
                      Text('ANALYZING...', style: TextStyle(letterSpacing: 1.2)),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.document_scanner),
                      SizedBox(width: 12),
                      Text('SCAN NOW', style: TextStyle(letterSpacing: 2.0, fontSize: 16)),
                    ],
                  ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // LED Chamber Control
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: isLedOn ? Colors.amber : Colors.white54),
                const SizedBox(width: 12),
                const Text('Chamber LED', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                Switch(
                  value: isLedOn,
                  onChanged: onLedToggled,
                  activeColor: Colors.amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
