<?php

use Illuminate\Support\Facades\Route;

Route::get('/simulasi-spqc', function () {
    return view('simulasi'); // Ini merujuk ke file resources/views/simulasi.blade.php
});
