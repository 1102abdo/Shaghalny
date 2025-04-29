<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class JobFactory extends Factory
{
    public function definition()
    {
        return [
            'title' => $this->faker->jobTitle(),
            'description' => $this->faker->paragraph(),
            'num_workers' => $this->faker->numberBetween(1, 10),
            'salary' => $this->faker->numberBetween(1000, 5000),
            'type' => $this->faker->randomElement(['full-time', 'part-time']),
            'location' => $this->faker->city(),
            'picture' => $this->faker->imageUrl(),
            'users_id' => \App\Models\User::factory(), // إنشاء مستخدم جديد تلقائيًا
        ];
    }
}
