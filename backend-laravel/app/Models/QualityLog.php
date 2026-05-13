<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QualityLog extends Model
{
    protected $fillable = [
        'status',
        'confidence_score',
        'weight',
        'gas_value',
        'temperature',
        'tss', // Jika ada kolom TSS
        'tracking_id', // Tambahkan ini
        'image_url'    // Tambahkan ini
    ];
    protected function serializeDate(\DateTimeInterface $date)
    {
        return $date->format('Y-m-d H:i:s');
    }
}
