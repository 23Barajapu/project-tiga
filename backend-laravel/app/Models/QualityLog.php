<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QualityLog extends Model
{
    // 💡 PAKSA LARAVEL MENGGUNAKAN TABEL QUALITY_LOGS (Kunci utama perbaikan error tadi)
    protected $table = 'quality_logs';

    protected $fillable = [
        'status',
        'confidence_score',
        'weight',
        'gas_value',
        'temperature',
        'tss',
        'tracking_id',
        'image_url'
    ];

    protected function serializeDate(\DateTimeInterface $date)
    {
        return $date->format('Y-m-d H:i:s');
    }
}
