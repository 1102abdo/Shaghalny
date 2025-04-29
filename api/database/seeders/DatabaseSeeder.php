<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\job;
use App\Models\Worker;
use App\Models\Application;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        // User::factory()->create([
        //     'name' => 'Test User',
        //     'email' => 'test@example.com',
        // ]);

        // إنشاء 10 مستخدمين
        User::factory(10)->create();

        // إنشاء 20 وظيفة
        Job::factory(20)->create();

        // إنشاء 30 عامل
        Worker::factory(30)->create();

        // إنشاء 50 طلب
        Application::factory(50)->create();
    }
}
