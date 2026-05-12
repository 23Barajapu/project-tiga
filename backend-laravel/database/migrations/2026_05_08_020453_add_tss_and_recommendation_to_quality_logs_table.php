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
            $table->float('tss')->nullable()->after('status');
            $table->string('recommendation')->nullable()->after('tss');
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
