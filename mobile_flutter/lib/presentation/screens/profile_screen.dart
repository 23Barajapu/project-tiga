import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _openMap() async {
    final Uri url = Uri.parse('https://maps.google.com/?q=-6.675639,107.674917');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch map');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Profil Mitra', style: TextStyle(color: AppTheme.accentNeonGreen, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.accentNeonGreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.accentNeonGreen,
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text('Bapak Toto', style: Theme.of(context).textTheme.displayMedium),
            const Text('Pemilik Kebun Nanas Simadu', style: TextStyle(color: AppTheme.accentNeonGreen)),
            const SizedBox(height: 30),
            
            // Info Brand Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentNeonGreen.withValues(alpha: 0.5), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.eco, color: AppTheme.accentNeonGreen, size: 20),
                      SizedBox(width: 10),
                      Text('TENTANG MITRA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mitra dalam pengembangan sistem ini adalah usaha perkebunan nanas milik Bapak Toto yang bergerak di bidang budidaya dan pengelolaan buah nanas, khususnya nanas Simadu. Kebun nanas ini berlokasi di daerah Jalancagak, Kabupaten Subang dengan titik koordinat 6°40\'32.3"S 107°40\'29.7"E. Dalam menjalankan usahanya, mitra bertanggung jawab dalam menjaga kualitas hasil panen, meningkatkan produktivitas kebun, serta memastikan buah nanas yang dihasilkan memiliki kualitas yang baik sebelum dipasarkan kepada konsumen.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sebelum terjun ke bidang pertanian, Bapak Toto memiliki latar belakang di bidang Teknologi Informasi (IT) dengan aktivitas membuka kursus komputer di rumah dan mengajar di beberapa sekolah sekitar. Namun, sejak pandemi COVID-19 tahun 2020 yang membatasi aktivitas tatap muka, beliau mulai mengembangkan usaha di bidang pertanian dengan fokus pada budidaya nanas karena memiliki ketertarikan yang besar terhadap buah tersebut. Dalam proses budidayanya, beliau menemukan bahwa nanas Simadu termasuk jenis nanas yang cukup langka di wilayah Subang. Dari sekitar 90 tanaman nanas yang dibudidayakan, hanya sekitar 5 buah yang berhasil tumbuh menjadi nanas Simadu.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Melalui berbagai percobaan dan penelitian sederhana, Bapak Toto melakukan pengambilan sampel tanah dari tanaman nanas Simadu dan melakukan konsultasi dengan beberapa ahli untuk mengetahui faktor yang memengaruhi kualitas pertumbuhan buah. Dari hasil penelitian tersebut ditemukan kombinasi atau ramuan khusus yang mampu meningkatkan produksi nanas Simadu secara signifikan. Hasilnya, jumlah produksi nanas Simadu meningkat menjadi sekitar 90 buah dari total tanaman yang dibudidayakan. Saat ini, mitra telah memiliki kebun nanas dengan lahan yang cukup luas dan produktif, dengan masa panen tanaman nanas sekitar 7 bulan hingga siap dipanen.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            _buildProfileItem(Icons.business_center, 'Usaha', 'Kebun Nanas Simadu'),
            _buildProfileItem(Icons.location_on, 'Lokasi', 'Jalancagak, Subang, Jawa Barat\n6°40\'32.3"S 107°40\'29.7"E', onTap: _openMap),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value, {VoidCallback? onTap}) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.accentNeonGreen, size: 20),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.map, color: Colors.blue, size: 14),
                      SizedBox(width: 4),
                      Text('Lihat Peta (Gmaps)', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: onTap != null 
          ? InkWell(onTap: onTap, child: content) 
          : content,
    );
  }
}
