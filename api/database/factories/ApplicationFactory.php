<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class ApplicationFactory extends Factory
{
    public function definition()
    {
        return [
            'name' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'phone' => $this->faker->phoneNumber(),
            'experience' => $this->faker->numberBetween(1, 10) . ' years',
            'skills' => implode(', ', $this->faker->randomElements(['PHP', 'Laravel', 'MySQL', 'JavaScript'], 3)),
            'CV' => $this->faker->url(),
            'bin' => $this->faker->randomElement(['0', '1']),
            'jobs_id' => \App\Models\Job::factory(), // إنشاء وظيفة جديدة تلقائيًا
            'workers_id' => \App\Models\Worker::factory(), // إنشاء عامل جديد تلقائيًا
        ];
    }
}
