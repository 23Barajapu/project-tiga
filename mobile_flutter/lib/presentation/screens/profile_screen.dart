import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Profile Senara', style: TextStyle(color: AppTheme.accentNeonGreen, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.accentNeonGreen),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.accentNeonGreen,
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text('Dadhe', style: Theme.of(context).textTheme.displayMedium),
            const Text('Owner of Senara', style: TextStyle(color: AppTheme.accentNeonGreen)),
            const SizedBox(height: 30),
            
            // Info Brand Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentNeonGreen.withOpacity(0.5), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.eco, color: AppTheme.accentNeonGreen, size: 20),
                      SizedBox(width: 10),
                      Text('TENTANG SENARA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Senara merupakan brand kosmetik inovatif yang memanfaatkan buah nanas sebagai bahan baku utama. Didirikan oleh Bapak Dadhe untuk meningkatkan nilai tambah komoditas lokal Subang.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Selain kosmetik, Senara juga merambah ke sektor kuliner dengan produk seperti saus, jus, dan cuka nanas. Usaha ini hadir sebagai solusi bagi petani lokal dalam mendistribusikan hasil panen secara berkelanjutan.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            _buildProfileItem(Icons.business_center, 'Brand', 'Senara - Pineapple Innovation'),
            _buildProfileItem(Icons.location_on, 'Location', 'Subang, West Java, Indonesia'),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentNeonGreen, size: 20),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
