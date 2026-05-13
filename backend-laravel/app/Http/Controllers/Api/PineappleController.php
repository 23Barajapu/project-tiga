<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QualityLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PineappleController extends Controller
{
    // Ambil status terbaru untuk Dashboard
    public function getLatest()
    {
        $latest = QualityLog::latest()->first();
        return $latest ? response()->json($latest) : response()->json(['status' => 'NONE'], 404);
    }

    // Ambil daftar history lengkap
    public function getHistory()
    {
        $logs = QualityLog::latest()->get();
        return response()->json($logs);
    }

    /**
     * Endpoint Baru: Handle Upload Foto & Data dari AI
     */
    public function uploadFoto(Request $request)
    {
        // 1. Mapping Status (1=MATANG, 3=MENTAH)
        $inputStatus = $request->input('status');
        $map = ['1' => 'RIPE', '2' => 'HALF_RIPE', '3' => 'RAW'];
        $status = $map[$inputStatus] ?? 'UNKNOWN';

        $imagePath = null;

        // 2. Simpan Foto ke Storage
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $filename = ($request->input('pineapple_id') ?? time()) . '.jpg';
            $imagePath = $file->storeAs('nanas', $filename, 'public');
        }

        // 3. Simpan ke Database
        $log = QualityLog::create([
            'tracking_id'      => $request->input('pineapple_id'),
            'status'           => $status,
            'image_url'        => $imagePath,
            'confidence_score' => rand(850, 990) / 10,
            'weight'           => rand(100, 200) / 100,
            'gas_value'        => rand(30, 80),
            'temperature'      => rand(220, 280) / 10,
        ]);

        return response()->json([
            'message' => 'Deteksi AI Berhasil Disimpan',
            'data'    => $log
        ], 200);
    }

    /**
     * Input dari Python (Hasil Deteksi AI - Versi Lama)
     */
    public function setStatus(Request $request)
    {
        // 1. Mapping Status dari Python
        // Python mengirim 'status' (1/3) dan 'pineapple_id'
        $inputStatus = $request->input('status');
        $map = ['1' => 'RIPE', '2' => 'HALF_RIPE', '3' => 'RAW'];
        $status = $map[$inputStatus] ?? 'UNKNOWN';

        $imagePath = null;

        // 2. Handle Upload Foto jika ada
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            // Nama file menggunakan pineapple_id dari Python agar tidak tertukar
            $filename = ($request->input('pineapple_id') ?? time()) . '.jpg';
            // Simpan ke storage/app/public/nanas
            $imagePath = $file->storeAs('nanas', $filename, 'public');
        }

        // 3. Simpan ke Database (Tabel quality_logs)
        $log = QualityLog::create([
            'tracking_id'      => $request->input('pineapple_id'), // Labeling agar tidak tertukar
            'status'           => $status,
            'image_url'        => $imagePath, // Path ke foto
            'confidence_score' => rand(850, 990) / 10,
            'weight'           => rand(100, 200) / 100,
            'gas_value'        => rand(30, 80),
            'temperature'      => rand(220, 280) / 10,
        ]);

        return response()->json([
            'message' => 'Data & Foto Berhasil Disimpan',
            'grade'   => $status,
            'data'    => $log
        ], 200);
    }

    // Update TSS & Rekomendasi dari Flutter
    public function updateTss(Request $request, $id)
    {
        $request->validate([
            'tss' => 'required|numeric'
        ]);

        $log = QualityLog::find($id);
        if (!$log) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $tss = (float)$request->tss;
        $status = $log->status; // Tetap pakai status asli (RIPE/HALF_RIPE/RAW)
        $rekomendasi = "";

        // Logika Rekomendasi berdasarkan TSS
        if ($status == 'RIPE' || $status == 'HALF_RIPE') {
            if ($tss >= 14) {
                $rekomendasi = "Sirup Nanas";
            } else if ($tss >= 11) {
                $rekomendasi = "Saus Nanas";
            } else {
                $rekomendasi = "Selai Nanas";
            }
        } else {
            // Jalur Mentah (RAW)
            if ($tss >= 10) {
                $rekomendasi = "Keripik Nanas";
            } else {
                $rekomendasi = "Cuka Nanas";
            }
        }

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
