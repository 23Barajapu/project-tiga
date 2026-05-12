<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QualityLog extends Model
{
    protected $fillable = [
        'weight',
        'gas_value',
        'temperature',
        'confidence_score',
        'status',
        'tss',            // Tambahkan ini
        'recommendation'  // Tambahkan ini
    ];
    protected function serializeDate(\DateTimeInterface $date)
    {
        return $date->format('Y-m-d H:i:s');
    }
}
