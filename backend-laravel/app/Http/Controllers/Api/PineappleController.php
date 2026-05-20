<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QualityLog; // Pastikan ini mengarah ke model QualityLog yang benar
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PineappleController extends Controller
{
    /**
     * Ambil status terbaru untuk Dashboard
     * GET /api/nanas/latest atau /api/pineapple/latest
     */
    public function getLatest()
    {
        $latest = QualityLog::latest()->first();
        return $latest ? response()->json($latest) : response()->json(['status' => 'NONE'], 404);
    }

    /**
     * Ambil daftar history lengkap tanpa limit
     * GET /api/pineapple/history
     */
    public function getHistory()
    {
        $logs = QualityLog::latest()->get();
        return response()->json($logs);
    }

    /**
     * Input utama dari Python (Hasil Deteksi AI + Upload Foto)
     * POST /api/nanas/status
     */
    public function setStatus(Request $request)
    {
        // 1. Mapping Status dari Python (1=Matang, 3=Mentah)
        $inputStatus = $request->input('status');
        $map = ['1' => 'RIPE', '2' => 'HALF_RIPE', '3' => 'RAW'];
        $status = $map[$inputStatus] ?? 'UNKNOWN';

        $imagePath = null;

        // 2. Handle Upload Foto ke storage/app/public/nanas
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            // Menamai file dengan pineapple_id unik agar tracking tidak tertukar
            $filename = ($request->input('pineapple_id') ?? time()) . '.jpg';
            $imagePath = $file->storeAs('nanas', $filename, 'public');
        }

        // 3. Simpan ke Database (Memastikan masuk ke tabel quality_logs)
        $log = QualityLog::create([
            'tracking_id'      => $request->input('pineapple_id'), // Labeling unik
            'status'           => $status,
            'image_url'        => $imagePath, // Path gambar relatif
            'confidence_score' => rand(850, 990) / 10,
            'weight'           => rand(100, 200) / 100,
            'gas_value'        => rand(30, 80),
            'temperature'      => rand(220, 280) / 10,
        ]);

        return response()->json([
            'message' => 'Data & Foto Berhasil Disimpan ke Quality Logs',
            'grade'   => $status,
            'data'    => $log
        ], 200);
    }

    /**
     * Update TSS & Rekomendasi Olahan Nanas dari Flutter
     * POST /api/pineapple/update-tss/{id}
     */
    public function updateTss(Request $request, $id)
    {
        $request->validate([
            'tss' => 'required|numeric'
        ]);

        $log = QualityLog::find($id);
        if (!$log) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $tss = (float)$request->tss;
        $status = $log->status; 
        $rekomendasi = "";

        // Logika Rekomendasi berdasarkan tingkat kemanisan (°Brix)
        if ($status == 'RIPE' || $status == 'HALF_RIPE') {
            if ($tss >= 14) {
                $rekomendasi = "Sirup Nanas";
            } else if ($tss >= 11) {
                $rekomendasi = "Saus Nanas";
            } else {
                $rekomendasi = "Selai Nanas";
            }
        } else {
            // Jalur buah Mentah (RAW)
            if ($tss >= 10) {
                $rekomendasi = "Keripik Nanas";
            } else {
                $rekomendasi = "Cuka Nanas";
            }
        }

        // Amankan perubahan ke database
        $log->tss = $tss;
        $log->recommendation = $rekomendasi;
        $log->save();

        return response()->json([
            'message' => 'Update Berhasil',
            'recommendation' => $rekomendasi,
            'data' => $log
        ]);
    }
}