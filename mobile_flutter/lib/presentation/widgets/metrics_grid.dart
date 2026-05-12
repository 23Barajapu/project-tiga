import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MetricsGrid extends StatelessWidget {
  final double weight;
  final double voc;
  final double temperature;
  final double humidity;

  const MetricsGrid({
    super.key,
    required this.weight,
    required this.voc,
    required this.temperature,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSensorCard('WEIGHT', weight.toStringAsFixed(2), Icons.scale, 'kg'),
        _buildSensorCard('GAS/VOC', voc.toStringAsFixed(0), Icons.air, 'ppm'),
        _buildSensorCard('INT. TEMP', temperature.toStringAsFixed(1), Icons.thermostat, '°C'),
        _buildSensorCard('HUMIDITY', humidity.toStringAsFixed(0), Icons.water_drop, '%'),
      ],
    );
  }

  Widget _buildSensorCard(String label, String value, IconData icon, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.accentNeonGreen, size: 20),
          const Spacer(),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
