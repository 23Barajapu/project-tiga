# Project Tiga - Smart Pineapple Quality Control (SPQC)

Sistem kontrol kualitas nanas otomatis menggunakan ESP32, Laravel, Flutter, dan AI Vision Transformer (ViT).

## 📋 Overview

Project ini terdiri dari 4 komponen utama:
1. **Backend Laravel** - API server dan database
2. **Mobile Flutter** - Aplikasi mobile untuk monitoring
3. **ESP32 Code** - Hardware untuk kamera dan servo
4. **AI Interface** - Python Flask dengan YOLOv11 untuk deteksi kualitas nanas

## 🔧 Prerequisites

### Software yang dibutuhkan:
- **PHP 8.1+** dan **Composer** (untuk Laravel)
- **Node.js 18+** dan **npm** (untuk Laravel frontend)
- **Python 3.8+** dan **pip** (untuk AI Interface)
- **Flutter SDK** (untuk mobile app)
- **Arduino IDE** atau **PlatformIO** (untuk ESP32)
- **MySQL** atau **MariaDB** (untuk database)
- **Git** (untuk version control)

### Hardware yang dibutuhkan:
- 2x ESP32 (1 untuk kamera, 1 untuk servo)
- ESP32-CAM module
- Servo motor
- Kabel USB untuk programming

## 📝 Konfigurasi IP

### File yang harus diubah IP-nya:

#### 1. **mobile_flutter/lib/config/app_config.dart**
```dart
class AppConfig {
  static const String laptopIp = '192.168.137.123';  // ← Ganti dengan IP laptop Anda
  static const String espCamIp = '192.168.137.42';   // ← Ganti dengan IP ESP32 Camera
  static const String espServoIp = '192.168.137.242'; // ← Ganti dengan IP ESP32 Servo
  static const int laravelPort = 8001;
  static const int aiStreamPort = 8888;
}
```

#### 2. **esp32-code/index/index.ino** (ESP32 Servo)
```cpp
const char* ssid = "aruuu";              // ← Ganti dengan nama WiFi Anda
const char* password = "alva123asd";     // ← Ganti dengan password WiFi Anda
const String url = "http://192.168.137.123:8001/api/pineapple/latest"; // ← Ganti dengan IP laptop
```

#### 3. **esp32-code/cam/cam.ino** (ESP32 Camera)
```cpp
const char* ssid = "aruuu";              // ← Ganti dengan nama WiFi Anda
const char* password = "alva123asd";     // ← Ganti dengan password WiFi Anda
```

#### 4. **ai-interface/main.py**
```python
ESP32_IP = "192.168.137.42"              # ← Ganti dengan IP ESP32 Camera
LAPTOP_IP = "192.168.137.123"           # ← Ganti dengan IP laptop Anda
SERVO_ESP_IP = "192.168.137.242"        # ← Ganti dengan IP ESP32 Servo
```

#### 5. **backend-laravel/.env**
```env
DB_HOST=127.0.0.1                        # ← Ganti jika database di server lain
DB_PORT=3306
DB_DATABASE=project-3                    # ← Sesuaikan nama database
DB_USERNAME=root                         # ← Ganti dengan username MySQL Anda
DB_PASSWORD=                             # ← Ganti dengan password MySQL Anda
```

**Catatan:** Tambahkan juga baris berikut di `.env` jika belum ada:
```env
SERVO_ESP_URL=http://192.168.137.242     # ← Ganti dengan IP ESP32 Servo
```

#### 6. **backend-laravel/resources/views/webcam.blade.php**
```javascript
fetch(`http://192.168.137.123:8001/api/nanas/status?status=${grade}`) // ← Ganti dengan IP laptop
```

#### 7. **backend-laravel/public/ai.html**
```javascript
fetch(`http://192.168.137.123:8001/api/nanas/status?status=${grade}`) // ← Ganti dengan IP laptop
```

#### 8. **mobile_flutter/android/app/src/main/res/xml/network_security_config.xml**
```xml
<domain includeSubdomains="true">192.168.137.123</domain> <!-- ← Ganti dengan IP laptop -->
<domain includeSubdomains="true">192.168.137.42</domain> <!-- ← Ganti dengan IP ESP32 Camera -->
```

## 🚀 Cara Menjalankan Project

### Step 1: Setup Database

1. Buka MySQL/MariaDB (bisa via phpMyAdmin atau terminal)
2. Buat database baru:
```sql
CREATE DATABASE `project-3`;
```

3. Import file SQL:
```bash
# Via terminal MySQL
mysql -u root -p project-3 < "projek-tiga (1).sql"

# Atau via phpMyAdmin: pilih database project-3 → Import → pilih file SQL
```

### Step 2: Setup Backend Laravel

```bash
cd backend-laravel

# Install dependencies
composer install
npm install

# Copy file environment
cp .env.example .env

# Generate application key
php artisan key:generate

# Konfigurasi database di file .env (lihat bagian Konfigurasi IP di atas)

# Run migrations (jika diperlukan)
php artisan migrate

# Link storage (untuk upload gambar)
php artisan storage:link

# Jalankan server Laravel di port 8001
php artisan serve --host=0.0.0.0 --port=8001
```

Backend akan berjalan di: `http://localhost:8001` atau `http://192.168.137.123:8001`

### Step 3: Setup AI Interface (Python)

```bash
cd ai-interface

# Buat virtual environment (opsional tapi disarankan)
python -m venv venv

# Aktifkan virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install opencv-python requests ultralytics flask

# Pastikan file best.pt (model YOLO) sudah ada di folder ini
# Jalankan AI server
python main.py
```

AI Interface akan berjalan di: `http://localhost:8888` atau `http://192.168.137.123:8888`

### Step 4: Setup ESP32 Hardware

#### ESP32 Camera (cam.ino)
1. Buka Arduino IDE
2. Install ESP32 board support jika belum:
   - File → Preferences → Additional Board Manager URLs
   - Tambahkan: `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
3. Tools → Board → Boards Manager → cari "ESP32" → Install
4. Buka file `esp32-code/cam/cam.ino`
5. Pilih board: "AI Thinker ESP32-CAM"
6. Pilih COM port yang sesuai
7. Upload sketch
8. Buka Serial Monitor (baud rate: 115200)
9. Catat IP address yang muncul (contoh: `192.168.137.42`)
10. Update IP ini di file konfigurasi lainnya

#### ESP32 Servo (index.ino)
1. Buka Arduino IDE
2. Buka file `esp32-code/index/index.ino`
3. Pilih board: "ESP32 Dev Module"
4. Pilih COM port yang sesuai
5. Upload sketch
6. Buka Serial Monitor (baud rate: 115200)
7. Catat IP address yang muncul (contoh: `192.168.137.242`)
8. Update IP ini di file konfigurasi lainnya

### Step 5: Setup Mobile Flutter

```bash
cd mobile_flutter

# Install dependencies
flutter pub get

# Untuk Android:
flutter run

# Untuk iOS (hanya di Mac):
flutter run

# Atau build APK:
flutter build apk
```

Pastikan device/emulator terhubung ke WiFi yang sama dengan laptop dan ESP32.

## 🧪 Testing

### 1. Test Backend Laravel
Buka browser:
- `http://localhost:8001/api/pineapple/latest` - harus mengembalikan data JSON
- `http://localhost:8001/api/pineapple/history` - harus mengembalikan history data

### 2. Test AI Interface
Buka browser:
- `http://localhost:8888` - harus menampilkan live stream dari ESP32 Camera dengan bounding box AI

### 3. Test ESP32 Camera
Buka browser:
- `http://192.168.137.42/mjpeg` - harus menampilkan stream MJPEG dari kamera (ganti IP dengan IP ESP32 Camera Anda)

### 4. Test ESP32 Servo
Buka browser:
- `http://192.168.137.242/move?status=1` - servo harus bergerak ke posisi "matang"
- `http://192.168.137.242/move?status=3` - servo harus bergerak ke posisi "mentah"

### 5. Test Mobile App
- Buka aplikasi Flutter
- Pastikan bisa connect ke API Laravel
- Pastikan bisa melihat live stream dari kamera
- Pastikan bisa melihat data sensor dan history

## 🔍 Troubleshooting

### Backend Laravel tidak jalan
- Pastikan PHP dan Composer terinstall dengan benar
- Cek konfigurasi database di `.env`
- Pastikan MySQL service berjalan
- Cek port 8001 tidak dipakai aplikasi lain

### AI Interface tidak bisa connect ke ESP32 Camera
- Pastikan ESP32 Camera dan laptop di WiFi yang sama
- Cek IP ESP32 Camera di Serial Monitor
- Pastikan firewall tidak memblokir port 8888
- Coba ping ke IP ESP32 Camera dari terminal

### ESP32 tidak connect ke WiFi
- Pastikan SSID dan password WiFi benar
- Coba restart ESP32
- Pastikan ESP32 dalam range WiFi yang baik
- Cek Serial Monitor untuk error message

### Flutter app tidak connect ke backend
- Pastikan laptop dan device di WiFi yang sama
- Cek IP laptop di `app_config.dart`
- Pastikan Laravel server berjalan
- Cek firewall laptop

### Servo tidak bergerak
- Pastikan ESP32 Servo connect ke WiFi
- Cek IP ESP32 Servo di Serial Monitor
- Pastikan servo terhubung ke pin yang benar (GPIO 27)
- Cek power supply servo (mungkin butuh external power)

## 📊 Arsitektur Sistem

```
┌─────────────────┐
│  Flutter Mobile │
│   (Monitoring)  │
└────────┬────────┘
         │ HTTP
         ↓
┌─────────────────┐
│  Laravel API    │
│  (Port 8001)    │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ↓         ↓
┌──────────┐ ┌──────────────┐
│ MySQL DB │ │ AI Interface │
└──────────┘ │  (Port 8888) │
             └──────┬───────┘
                    │ MJPEG Stream
                    ↓
             ┌──────────────┐
             │ ESP32 Camera │
             │ (192.168.xxx)│
             └──────────────┘
                    │
                    ↓ HTTP Trigger
             ┌──────────────┐
             │ ESP32 Servo  │
             │ (192.168.xxx)│
             └──────────────┘
```

## 📝 Catatan Penting

1. **Semua device harus di jaringan WiFi yang sama** (laptop, ESP32 Camera, ESP32 Servo, mobile device)
2. **IP address bisa berubah** jika router me-restart atau device reconnect ke WiFi
3. **Selalu cek IP ESP32 di Serial Monitor** setelah upload sketch
4. **Pastikan model YOLO (best.pt) ada** di folder `ai-interface/`
5. **Database harus di-import** sebelum menjalankan Laravel
6. **Port yang digunakan:**
   - Laravel: 8001
   - AI Interface: 8888
   - ESP32 Camera: 80
   - ESP32 Servo: 80

## 🆘 Bantuan

Jika mengalami masalah:
1. Cek Serial Monitor ESP32 untuk error
2. Cek log Laravel di `storage/logs/laravel.log`
3. Cek terminal AI Interface untuk error Python
4. Pastikan semua IP address sudah benar dan konsisten
5. Pastikan semua service berjalan (Laravel, AI Interface, ESP32)

## 📄 Lisensi

Project ini dibuat untuk tujuan edukasi dan penelitian.

---

**Selamat menggunakan Project Tiga! 🍍**
