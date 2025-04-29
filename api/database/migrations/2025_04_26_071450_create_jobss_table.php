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
        Schema::create('jobss', function (Blueprint $table) {
            $table->id();
            $table->string('title')->nullable();
            $table->text('description')->nullable();
            $table->integer('num_workers')->nullable();
            $table->integer('salary')->nullable();
            $table->enum('type', ['full-time', 'part-time'])->nullable();
            $table->string('location')->nullable();
            $table->string('picture')->nullable(); 
            $table->foreignId('users_id')->constrained('users'); 
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jobss');
    }
};
