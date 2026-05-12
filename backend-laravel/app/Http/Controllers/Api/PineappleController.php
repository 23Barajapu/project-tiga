<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QualityLog;
use Illuminate\Http\Request;

class PineappleController extends Controller
{
    // Ambil status terbaru untuk Dashboard
    public function getLatest()
    {
        $latest = QualityLog::latest()->first();
        return $latest ? response()->json($latest) : response()->json(['status' => 'NONE'], 404);
    }

    // Ambil daftar history (Limit 20)
    public function getHistory()
    {
        $logs = QualityLog::latest()->get();
        return response()->json($logs);
    }

    // Input dari Python (Hasil Deteksi AI)
    public function setStatus(Request $request)
    {
        $input = $request->query('status');
        $map = ['1' => 'RIPE', '2' => 'HALF_RIPE', '3' => 'RAW'];
        $status = $map[$input] ?? 'UNKNOWN';

        $log = QualityLog::create([
            'weight' => rand(100, 200) / 100,
            'gas_value' => rand(30, 80),
            'temperature' => rand(220, 280) / 10,
            'confidence_score' => rand(850, 990) / 10,
            'status' => $status,
        ]);

        return response()->json(['message' => 'Success', 'grade' => $status]);
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
        $status = $log->status;
        $rekomendasi = "";

        // Logika Penyederhanaan: RIPE & HALF_RIPE dianggap Matang
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

        // Simpan ke Database
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
