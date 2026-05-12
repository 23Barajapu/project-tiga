<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('quality_logs', function (Blueprint $table) {
            $table->id();
            $table->float('weight');
            $table->float('gas_value');
            $table->float('temperature');
            $table->float('confidence_score');
            $table->string('status'); // RIPE, RAW, atau ROT
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('quality_logs');
    }
};
