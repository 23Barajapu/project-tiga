<?php
use App\Http\Controllers\Api\PineappleController;
use Illuminate\Support\Facades\Route;

// Endpoint untuk ESP32 & Flutter ambil data terbaru
Route::get('/pineapple/latest', [PineappleController::class, 'getLatest']);

// Endpoint untuk Flutter ambil riwayat
Route::get('/pineapple/history', [PineappleController::class, 'getHistory']);

// Endpoint untuk simulasi (Input 1, 2, 3)
Route::get('/nanas/status', [PineappleController::class, 'setStatus']);

// Endpoint baru untuk Update TSS dari Flutter
Route::post('/pineapple/update-tss/{id}', [PineappleController::class, 'updateTss']);
