<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::table('quality_logs', function (Blueprint $table) {
            $table->string('tracking_id')->nullable()->after('id'); // Contoh: PINE-1715568000
            $table->string('image_url')->nullable()->after('status'); // Path foto
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('quality_logs', function (Blueprint $table) {
            //
        });
    }
};
