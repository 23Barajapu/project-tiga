import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qc_state_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QcStateProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SPQC DEVICE #01', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Row(
                  children: [
                    Icon(Icons.circle, color: provider.isScanning ? Colors.orange : const Color(0xFF00FF85), size: 10),
                    const SizedBox(width: 5),
                    Text(
                      provider.isScanning ? 'SCANNING...' : 'SYSTEM ONLINE', 
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        color: provider.isScanning ? Colors.orange : const Color(0xFF00FF85)
                      )
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
              const CircleAvatar(backgroundColor: Colors.amber, radius: 15),
              const SizedBox(width: 15),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- LIVE CAMERA FEED ---
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/400x200'), // Nanti ganti stream
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 15, left: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            'STATUS: ${provider.aiStatus}', 
                            style: const TextStyle(color: Color(0xFF00FF85), fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // --- DETECTION SUMMARY ---
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Matang', 
                        provider.ripeCount.toString(), 
                        const Color(0xFF00FF85)
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Mentah', 
                        provider.unripeCount.toString(), 
                        Colors.redAccent
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // --- SENSOR GRID ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.5,
                  children: [
                    _buildSensorCard('Weight', provider.weight.toString(), Icons.monitor_weight, 'gr'),
                    _buildSensorCard('Gas Value', provider.voc.toString(), Icons.air, 'ppm'),
                    _buildSensorCard('Temp', provider.temperature.toString(), Icons.thermostat, '°C'),
                    _buildSensorCard('Humidity', provider.humidity.toString(), Icons.water_drop, '%'),
                  ],
                ),
                
                const SizedBox(height: 25),
                const Text('Analysis Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                // --- ANALYSIS BOX ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2C21),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00FF85).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, color: Color(0xFF00FF85), size: 40),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vision Transformer Analysis', style: TextStyle(color: Colors.grey)),
                          Text(
                            'Confidence Score: ${provider.confidenceScore}%', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // --- TRIGGER BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF85),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: provider.isScanning ? null : () => provider.triggerScan(),
                    child: Text(
                      provider.isScanning ? 'SCANNING...' : 'START DETECTION',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2C21),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value, 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String label, String value, IconData icon, String unit) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2C21),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00FF85), size: 20),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}