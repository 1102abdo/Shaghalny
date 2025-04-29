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
        Schema::create('create_jobs_has_workers_tables', function (Blueprint $table) {
            $table->foreignId('jobs_id')->constrained('jobss');
            $table->foreignId('workers_id')->constrained('workers');
            $table->primary(['jobs_id', 'workers_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('create_jobs_has_workers_tables');
    }
};
