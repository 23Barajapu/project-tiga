<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class QualityLogSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $statuses = ['RIPE', 'RAW', 'ROT'];
        for ($i = 0; $i < 10; $i++) {
            \App\Models\QualityLog::create([
                'weight' => rand(100, 200) / 100, // 1.00 - 2.00 kg
                'gas_value' => rand(30, 80), 
                'temperature' => rand(220, 280) / 10, // 22.0 - 28.0 C
                'confidence_score' => rand(800, 990) / 10, // 80.0 - 99.0 %
                'status' => $statuses[array_rand($statuses)],
            ]);
        }
    }
}
