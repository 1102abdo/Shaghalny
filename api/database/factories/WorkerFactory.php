<?php

namespace Database\Factories;
use App\Models\Worker;
use Illuminate\Database\Eloquent\Factories\Factory;

class WorkerFactory extends Factory
{
    
    public function definition()
    {
        return [
            'name' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'password' => bcrypt('password'),
            'job' => $this->faker->jobTitle(),
            'ban' => $this->faker->randomElement(['0', '1']),
        ];
    }
}